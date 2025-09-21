import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;

class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les utilisateurs
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return app_user.User(
          id: doc.id,
          email: data['email'] ?? '',
          nom: data['nom'] ?? '',
          prenom: data['prenom'] ?? '',
          telephone: data['telephone'] ?? '',
          role: data['role'] ?? 'user',
          dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  // Récupérer un utilisateur par ID
  Future<app_user.User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return app_user.User(
          id: doc.id,
          email: data['email'] ?? '',
          nom: data['nom'] ?? '',
          prenom: data['prenom'] ?? '',
          telephone: data['telephone'] ?? '',
          role: data['role'] ?? 'user',
          dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'dateModification': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rôle: $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      // Vérifier d'abord si l'utilisateur a des annonces
      final annoncesQuery = await _firestore
          .collection('annonces')
          .where('userId', isEqualTo: userId)
          .get();
      
      // Supprimer toutes les annonces de l'utilisateur
      for (final doc in annoncesQuery.docs) {
        await doc.reference.delete();
      }
      
      // Supprimer l'utilisateur
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Rechercher des utilisateurs
  Future<List<app_user.User>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('nom', isGreaterThanOrEqualTo: query)
          .where('nom', isLessThan: query + '\uf8ff')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return app_user.User(
          id: doc.id,
          email: data['email'] ?? '',
          nom: data['nom'] ?? '',
          prenom: data['prenom'] ?? '',
          telephone: data['telephone'] ?? '',
          role: data['role'] ?? 'user',
          dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'utilisateurs: $e');
    }
  }

  // Obtenir les statistiques des utilisateurs
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final usersQuery = await _firestore.collection('users').get();
      final totalUsers = usersQuery.docs.length;
      
      final adminUsers = usersQuery.docs
          .where((doc) => doc.data()['role'] == 'admin')
          .length;
      
      final regularUsers = totalUsers - adminUsers;
      
      // Utilisateurs créés ce mois
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final usersThisMonth = usersQuery.docs
          .where((doc) {
            final dateCreation = (doc.data()['dateCreation'] as Timestamp?)?.toDate();
            return dateCreation != null && dateCreation.isAfter(startOfMonth);
          })
          .length;
      
      return {
        'totalUsers': totalUsers,
        'adminUsers': adminUsers,
        'regularUsers': regularUsers,
        'usersThisMonth': usersThisMonth,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
