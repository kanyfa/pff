import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TypeAction {
  creationAnnonce,
  modificationAnnonce,
  suppressionAnnonce,
  recherche,
  contact,
  connexion,
  inscription,
  modificationProfil;

  String get label {
    switch (this) {
      case TypeAction.creationAnnonce:
        return 'Création d\'annonce';
      case TypeAction.modificationAnnonce:
        return 'Modification d\'annonce';
      case TypeAction.suppressionAnnonce:
        return 'Suppression d\'annonce';
      case TypeAction.recherche:
        return 'Recherche';
      case TypeAction.contact:
        return 'Contact établi';
      case TypeAction.connexion:
        return 'Connexion';
      case TypeAction.inscription:
        return 'Inscription';
      case TypeAction.modificationProfil:
        return 'Modification du profil';
    }
  }

  IconData get icon {
    switch (this) {
      case TypeAction.creationAnnonce:
        return Icons.add;
      case TypeAction.modificationAnnonce:
        return Icons.edit;
      case TypeAction.suppressionAnnonce:
        return Icons.delete;
      case TypeAction.recherche:
        return Icons.search;
      case TypeAction.contact:
        return Icons.contact_phone;
      case TypeAction.connexion:
        return Icons.login;
      case TypeAction.inscription:
        return Icons.person_add;
      case TypeAction.modificationProfil:
        return Icons.person;
    }
  }
}

class Historique {
  final String id;
  final String userId;
  final TypeAction action;
  final String description;
  final DateTime dateAction;
  final Map<String, dynamic>? details;

  Historique({
    required this.id,
    required this.userId,
    required this.action,
    required this.description,
    required this.dateAction,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'action': action.name,
      'description': description,
      'dateAction': dateAction.toIso8601String(),
      'details': details,
    };
  }

  factory Historique.fromMap(Map<String, dynamic> map, String id) {
    return Historique(
      id: id,
      userId: map['userId'] ?? '',
      action: TypeAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => TypeAction.connexion,
      ),
      description: map['description'] ?? '',
      dateAction: DateTime.parse(map['dateAction']),
      details: map['details'],
    );
  }
}
