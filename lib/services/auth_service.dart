import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart' as app_user;
import '../models/historique.dart';
import 'historique_service.dart';
// import 'package:js/js.dart';

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  app_user.User? _user;

  app_user.User? get currentUser => _user;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) {
    if (firebaseUser != null) {
      _loadUserData(firebaseUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = app_user.User.fromMap(doc.data()!, doc.id);
        notifyListeners();
      } else {
        // Si l'utilisateur n'existe pas dans Firestore, créer un utilisateur par défaut
        print('Utilisateur non trouvé dans Firestore, création d\'un utilisateur par défaut');
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          // Vérifier si c'est le premier utilisateur (admin par défaut)
          final usersSnapshot = await _firestore.collection('users').get();
          final isFirstUser = usersSnapshot.docs.isEmpty;
          
          final defaultUser = app_user.User(
            id: uid,
            email: firebaseUser.email ?? 'user@example.com',
            nom: 'Utilisateur',
            prenom: 'Test',
            telephone: '0123456789',
            dateCreation: DateTime.now(),
            role: isFirstUser ? 'admin' : 'user', // Premier utilisateur = admin
          );
          
          // Sauvegarder dans Firestore
          await _firestore.collection('users').doc(uid).set(defaultUser.toMap());
          
          _user = defaultUser;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = app_user.User(
          id: credential.user!.uid,
          email: email,
          nom: nom,
          prenom: prenom,
          telephone: telephone,
          dateCreation: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toMap());

        _user = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Charger les données utilisateur immédiatement après la connexion
        await _loadUserData(credential.user!.uid);
        
        // Ajouter l'action de connexion à l'historique
        try {
          final historiqueService = HistoriqueService();
          await historiqueService.ajouterAction(
            userId: credential.user!.uid,
            action: TypeAction.connexion,
            description: 'Connexion réussie',
          );
        } catch (e) {
          print('Erreur lors de l\'ajout de l\'action à l\'historique: $e');
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> updateProfile({
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    if (_user != null) {
      try {
        final updatedUser = app_user.User(
          id: _user!.id,
          email: _user!.email,
          nom: nom,
          prenom: prenom,
          telephone: telephone,
          dateCreation: _user!.dateCreation,
        );

        await _firestore
            .collection('users')
            .doc(_user!.id)
            .update(updatedUser.toMap());

        _user = updatedUser;
        notifyListeners();
      } catch (e) {
        print('Erreur lors de la mise à jour du profil: $e');
      }
    }
  }
}
