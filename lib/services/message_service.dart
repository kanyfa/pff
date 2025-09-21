import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Envoyer un message
  Future<void> envoyerMessage({
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    String? annonceId,
  }) async {
    try {
      final message = Message(
        id: '',
        expediteurId: expediteurId,
        destinataireId: destinataireId,
        contenu: contenu,
        date: DateTime.now(),
        annonceId: annonceId,
      );

      await _firestore.collection('messages').add(message.toMap());
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }

  // Récupérer les messages d'un utilisateur
  Stream<List<Message>> getMessagesUtilisateur(String userId) {
    return _firestore
        .collection('messages')
        .where('destinataireId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer la conversation entre deux utilisateurs
  Stream<List<Message>> getConversation(String userId1, String userId2) {
    return _firestore
        .collection('messages')
        .where('expediteurId', whereIn: [userId1, userId2])
        .where('destinataireId', whereIn: [userId1, userId2])
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Marquer un message comme lu
  Future<void> marquerCommeLu(String messageId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .update({'lu': true});
      notifyListeners();
    } catch (e) {
      print('Erreur lors du marquage du message comme lu: $e');
    }
  }

  // Récupérer le nombre de messages non lus
  Stream<int> getNombreMessagesNonLus(String userId) {
    return _firestore
        .collection('messages')
        .where('destinataireId', isEqualTo: userId)
        .where('lu', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}


