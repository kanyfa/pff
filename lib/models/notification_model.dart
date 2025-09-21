import 'package:flutter/material.dart';

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

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? annonceId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      annonceId: annonceId ?? this.annonceId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


