import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/historique.dart';

class HistoriqueService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une action à l'historique
  Future<void> ajouterAction({
    required String userId,
    required TypeAction action,
    required String description,
    Map<String, dynamic>? details,
  }) async {
    try {
      final historique = Historique(
        id: '', // Sera généré par Firestore
        userId: userId,
        action: action,
        description: description,
        dateAction: DateTime.now(),
        details: details,
      );

      await _firestore.collection('historique').add(historique.toMap());
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'action à l\'historique: $e');
    }
  }

  // Récupérer l'historique d'un utilisateur
  Future<List<Historique>> getHistoriqueUtilisateur(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('historique')
          .where('userId', isEqualTo: userId)
          .orderBy('dateAction', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => Historique.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Récupérer toutes les actions (pour les admins)
  Future<List<Historique>> getAllHistorique() async {
    try {
      final querySnapshot = await _firestore
          .collection('historique')
          .orderBy('dateAction', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => Historique.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de tout l\'historique: $e');
      return [];
    }
  }

  // Récupérer les statistiques d'utilisation
  Future<Map<String, dynamic>> getStatistiques() async {
    try {
      final annoncesSnapshot = await _firestore.collection('annonces').get();
      final usersSnapshot = await _firestore.collection('users').get();
      final historiqueSnapshot = await _firestore.collection('historique').get();

      // Compter les annonces par statut
      final annoncesPerdues = annoncesSnapshot.docs
          .where((doc) => doc.data()['statut'] == 'perdu')
          .length;
      final annoncesTrouvees = annoncesSnapshot.docs
          .where((doc) => doc.data()['statut'] == 'trouve')
          .length;

      // Compter les utilisateurs actifs (connectés dans les 30 derniers jours)
      final trenteJoursAgo = DateTime.now().subtract(const Duration(days: 30));
      final utilisateursActifs = historiqueSnapshot.docs
          .where((doc) {
            final date = DateTime.parse(doc.data()['dateAction']);
            return date.isAfter(trenteJoursAgo) && 
                   doc.data()['action'] == 'connexion';
          })
          .map((doc) => doc.data()['userId'])
          .toSet()
          .length;

      return {
        'totalAnnonces': annoncesSnapshot.docs.length,
        'annoncesPerdues': annoncesPerdues,
        'annoncesTrouvees': annoncesTrouvees,
        'totalUtilisateurs': usersSnapshot.docs.length,
        'utilisateursActifs': utilisateursActifs,
        'totalActions': historiqueSnapshot.docs.length,
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }
}


