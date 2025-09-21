import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TypeDocument {
  carteIdentite,
  passeport,
  permisConduire,
  carteVitale,
  carteEtudiant,
  autre;

  String get typeDocumentLabel {
    switch (this) {
      case TypeDocument.carteIdentite:
        return 'Carte d\'identité';
      case TypeDocument.passeport:
        return 'Passeport';
      case TypeDocument.permisConduire:
        return 'Permis de conduire';
      case TypeDocument.carteVitale:
        return 'Carte Vitale';
      case TypeDocument.carteEtudiant:
        return 'Carte étudiant';
      case TypeDocument.autre:
        return 'Autre';
    }
  }
}

enum StatutAnnonce {
  perdu,
  trouve,
  enRecherche;

  String get statutLabel {
    switch (this) {
      case StatutAnnonce.perdu:
        return 'Perdu';
      case StatutAnnonce.trouve:
        return 'Trouvé';
      case StatutAnnonce.enRecherche:
        return 'En recherche';
    }
  }

  Color get statutColor {
    switch (this) {
      case StatutAnnonce.perdu:
        return Colors.red;
      case StatutAnnonce.trouve:
        return Colors.green;
      case StatutAnnonce.enRecherche:
        return Colors.orange;
    }
  }
}

class Annonce {
  final String id;
  final String userId;
  final String titre;
  final String description;
  final TypeDocument typeDocument;
  final StatutAnnonce statut;
  final DateTime datePerte;
  final String lieuPerte;
  final String nomInscrit;
  final String? photoUrl;
  final DateTime dateCreation;
  final GeoPoint? position;

  Annonce({
    required this.id,
    required this.userId,
    required this.titre,
    required this.description,
    required this.typeDocument,
    required this.statut,
    required this.datePerte,
    required this.lieuPerte,
    required this.nomInscrit,
    this.photoUrl,
    required this.dateCreation,
    this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'titre': titre,
      'description': description,
      'typeDocument': typeDocument.name,
      'statut': statut.name,
      'datePerte': datePerte.toIso8601String(),
      'lieuPerte': lieuPerte,
      'nomInscrit': nomInscrit,
      'photoUrl': photoUrl,
      'dateCreation': dateCreation.toIso8601String(),
      'position': position,
    };
  }

  factory Annonce.fromMap(Map<String, dynamic> map, String id) {
    return Annonce(
      id: id,
      userId: map['userId'] ?? '',
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      typeDocument: TypeDocument.values.firstWhere(
        (e) => e.name == map['typeDocument'],
        orElse: () => TypeDocument.autre,
      ),
      statut: StatutAnnonce.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutAnnonce.perdu,
      ),
      datePerte: DateTime.parse(map['datePerte']),
      lieuPerte: map['lieuPerte'] ?? '',
      nomInscrit: map['nomInscrit'] ?? '',
      photoUrl: map['photoUrl'],
      dateCreation: DateTime.parse(map['dateCreation']),
      position: map['position'],
    );
  }
}
