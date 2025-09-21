import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/annonce.dart';
import '../models/historique.dart';
import 'historique_service.dart';
// import 'package:js/js.dart';

class AnnonceService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createAnnonce(Annonce annonce, File? photoFile) async {
    try {
      String? photoUrl;
      
      if (photoFile != null) {
        final ref = _storage.ref().child('annonces/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(photoFile);
        photoUrl = await ref.getDownloadURL();
      }

      final annonceWithPhoto = Annonce(
        id: annonce.id,
        userId: annonce.userId,
        titre: annonce.titre,
        description: annonce.description,
        typeDocument: annonce.typeDocument,
        statut: annonce.statut,
        datePerte: annonce.datePerte,
        lieuPerte: annonce.lieuPerte,
        nomInscrit: annonce.titre, // Utiliser le titre comme nom inscrit
        photoUrl: photoUrl,
        dateCreation: annonce.dateCreation,
        position: annonce.position,
      );

      final docRef = await _firestore.collection('annonces').add(annonceWithPhoto.toMap());
      
      // Ajouter l'action à l'historique
      try {
        final historiqueService = HistoriqueService();
        await historiqueService.ajouterAction(
          userId: annonce.userId,
          action: TypeAction.creationAnnonce,
          description: 'Annonce créée: ${annonce.titre}',
          details: {'annonceId': docRef.id, 'typeDocument': annonce.typeDocument.name},
        );
      } catch (e) {
        print('Erreur lors de l\'ajout de l\'action à l\'historique: $e');
      }
      
      notifyListeners();
      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création de l\'annonce: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnonce(String annonceId) async {
    try {
      // Récupérer l'annonce avant de la supprimer pour l'historique
      final annonceDoc = await _firestore.collection('annonces').doc(annonceId).get();
      if (annonceDoc.exists) {
        final annonce = Annonce.fromMap(annonceDoc.data()!, annonceId);
        
        // Ajouter l'action à l'historique
        try {
          final historiqueService = HistoriqueService();
          await historiqueService.ajouterAction(
            userId: annonce.userId,
            action: TypeAction.suppressionAnnonce,
            description: 'Annonce supprimée: ${annonce.titre}',
            details: {'annonceId': annonceId, 'typeDocument': annonce.typeDocument.name},
          );
        } catch (e) {
          print('Erreur lors de l\'ajout de l\'action à l\'historique: $e');
        }
      }
      
      await _firestore.collection('annonces').doc(annonceId).delete();
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'annonce: $e');
    }
  }

  Future<List<Annonce>> getAllAnnonces() async {
    try {
      final querySnapshot = await _firestore
          .collection('annonces')
          .orderBy('dateCreation', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Annonce.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des annonces: $e');
      return [];
    }
  }

  Future<List<Annonce>> getAnnoncesByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('annonces')
          .where('userId', isEqualTo: userId)
          .orderBy('dateCreation', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Annonce.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des annonces utilisateur: $e');
      return [];
    }
  }

  Future<Annonce?> getAnnonceById(String id) async {
    try {
      final doc = await _firestore.collection('annonces').doc(id).get();
      if (doc.exists) {
        return Annonce.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'annonce: $e');
      return null;
    }
  }

  Future<List<Annonce>> searchAnnonces({
    String? query,
    TypeDocument? typeDocument,
    StatutAnnonce? statut,
  }) async {
    try {
      Query queryRef = _firestore.collection('annonces');

      if (query != null && query.isNotEmpty) {
        queryRef = queryRef.where('titre', isGreaterThanOrEqualTo: query)
            .where('titre', isLessThan: query + '\uf8ff');
      }

      if (typeDocument != null) {
        queryRef = queryRef.where('typeDocument', isEqualTo: typeDocument.name);
      }

      if (statut != null) {
        queryRef = queryRef.where('statut', isEqualTo: statut.name);
      }

      final querySnapshot = await queryRef.orderBy('dateCreation', descending: true).get();

      return querySnapshot.docs
          .map((doc) => Annonce.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'annonces: $e');
      return [];
    }
  }

  Future<void> updateAnnonce(Annonce annonce) async {
    try {
      await _firestore
          .collection('annonces')
          .doc(annonce.id)
          .update(annonce.toMap());
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'annonce: $e');
      rethrow;
    }
  }

}
