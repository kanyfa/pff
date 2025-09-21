import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as app_user;
import '../models/annonce.dart';

class AdminService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les utilisateurs
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => app_user.User.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      return [];
    }
  }

  // Modifier le rôle d'un utilisateur
  Future<void> modifierRoleUtilisateur(String userId, String nouveauRole) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': nouveauRole});
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la modification du rôle: $e');
      rethrow;
    }
  }

  // Supprimer un utilisateur
  Future<void> supprimerUtilisateur(String userId) async {
    try {
      // Supprimer toutes les annonces de l'utilisateur
      final annoncesSnapshot = await _firestore
          .collection('annonces')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in annoncesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Supprimer l'utilisateur
      await _firestore.collection('users').doc(userId).delete();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
      rethrow;
    }
  }

  // Supprimer une annonce (admin)
  Future<void> supprimerAnnonceAdmin(String annonceId) async {
    try {
      await _firestore.collection('annonces').doc(annonceId).delete();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression de l\'annonce: $e');
      rethrow;
    }
  }

  // Valider une annonce
  Future<void> validerAnnonce(String annonceId) async {
    try {
      await _firestore
          .collection('annonces')
          .doc(annonceId)
          .update({'validee': true, 'dateValidation': DateTime.now().toIso8601String()});
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la validation de l\'annonce: $e');
      rethrow;
    }
  }

  // Récupérer les statistiques détaillées
  Future<Map<String, dynamic>> getStatistiquesDetaillees() async {
    try {
      final annoncesSnapshot = await _firestore.collection('annonces').get();
      final usersSnapshot = await _firestore.collection('users').get();
      final historiqueSnapshot = await _firestore.collection('historique').get();

      // Statistiques des annonces
      final annoncesPerdues = annoncesSnapshot.docs
          .where((doc) => doc.data()['statut'] == 'perdu')
          .length;
      final annoncesTrouvees = annoncesSnapshot.docs
          .where((doc) => doc.data()['statut'] == 'trouve')
          .length;
      final annoncesEnRecherche = annoncesSnapshot.docs
          .where((doc) => doc.data()['statut'] == 'enRecherche')
          .length;

      // Statistiques des utilisateurs
      final totalUtilisateurs = usersSnapshot.docs.length;
      final utilisateursAdmin = usersSnapshot.docs
          .where((doc) => doc.data()['role'] == 'admin')
          .length;
      final utilisateursNormaux = totalUtilisateurs - utilisateursAdmin;

      // Statistiques par type de document
      final typesDocuments = <String, int>{};
      for (var doc in annoncesSnapshot.docs) {
        final type = doc.data()['typeDocument'] ?? 'autre';
        typesDocuments[type] = (typesDocuments[type] ?? 0) + 1;
      }

      // Statistiques temporelles (7 derniers jours)
      final septJoursAgo = DateTime.now().subtract(const Duration(days: 7));
      final annoncesRecentes = annoncesSnapshot.docs
          .where((doc) {
            final date = DateTime.parse(doc.data()['dateCreation']);
            return date.isAfter(septJoursAgo);
          })
          .length;

      return {
        'annonces': {
          'total': annoncesSnapshot.docs.length,
          'perdues': annoncesPerdues,
          'trouvees': annoncesTrouvees,
          'enRecherche': annoncesEnRecherche,
          'recentes': annoncesRecentes,
          'parType': typesDocuments,
        },
        'utilisateurs': {
          'total': totalUtilisateurs,
          'admins': utilisateursAdmin,
          'normaux': utilisateursNormaux,
        },
        'activite': {
          'totalActions': historiqueSnapshot.docs.length,
        },
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques détaillées: $e');
      return {};
    }
  }

  // Récupérer les annonces en attente de validation
  Future<List<Annonce>> getAnnoncesEnAttente() async {
    try {
      final querySnapshot = await _firestore
          .collection('annonces')
          .where('validee', isEqualTo: false)
          .orderBy('dateCreation', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Annonce.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des annonces en attente: $e');
      return [];
    }
  }
}


