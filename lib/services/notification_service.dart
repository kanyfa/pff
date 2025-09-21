import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? annonceId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        annonceId: annonceId,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .add(notification.toMap());
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la création de la notification: $e');
    }
  }

  // Récupérer les notifications d'un utilisateur
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des notifications: $e');
      return [];
    }
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du marquage de la notification: $e');
    }
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du marquage de toutes les notifications: $e');
    }
  }

  // Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression de la notification: $e');
    }
  }

  // Compter les notifications non lues
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Erreur lors du comptage des notifications: $e');
      return 0;
    }
  }

  // Créer une notification pour une nouvelle annonce proche
  Future<void> notifyNewAnnonceNearby({
    required String userId,
    required String annonceId,
    required String documentType,
    required String location,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Nouvelle annonce proche',
      message: 'Une annonce de $documentType a été publiée près de $location',
      type: NotificationType.newAnnonce,
      annonceId: annonceId,
      data: {
        'documentType': documentType,
        'location': location,
      },
    );
  }

  // Créer une notification pour un message reçu
  Future<void> notifyNewMessage({
    required String userId,
    required String annonceId,
    required String senderName,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Nouveau message',
      message: '$senderName a laissé un message sur votre annonce',
      type: NotificationType.message,
      annonceId: annonceId,
      data: {
        'senderName': senderName,
      },
    );
  }

  // Créer une notification pour une annonce validée
  Future<void> notifyAnnonceValidated({
    required String userId,
    required String annonceId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Annonce validée',
      message: 'Votre annonce a été validée par l\'équipe',
      type: NotificationType.validation,
      annonceId: annonceId,
    );
  }

  // Créer une notification pour un document retrouvé
  Future<void> notifyDocumentFound({
    required String userId,
    required String annonceId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Document retrouvé !',
      message: 'Félicitations ! Votre document a été retrouvé',
      type: NotificationType.success,
      annonceId: annonceId,
    );
  }

  // Créer une notification de rappel
  Future<void> notifyReminder({
    required String userId,
    required String message,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Rappel',
      message: message,
      type: NotificationType.reminder,
    );
  }
}

// Modèle de notification
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? annonceId;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.annonceId,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'annonceId': annonceId,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.info,
      ),
      annonceId: map['annonceId'],
      data: map['data'],
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Types de notifications
enum NotificationType {
  info,
  newAnnonce,
  message,
  validation,
  success,
  warning,
  reminder,
}

extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.newAnnonce:
        return Icons.location_on;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.validation:
        return Icons.check_circle;
      case NotificationType.success:
        return Icons.celebration;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.reminder:
        return Icons.schedule;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.newAnnonce:
        return Colors.green;
      case NotificationType.message:
        return Colors.orange;
      case NotificationType.validation:
        return Colors.purple;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.red;
      case NotificationType.reminder:
        return Colors.blue;
    }
  }
}


