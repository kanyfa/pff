import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String expediteurId;
  final String destinataireId;
  final String contenu;
  final DateTime date;
  final bool lu;
  final String? annonceId; // Optionnel, pour lier le message à une annonce

  Message({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    required this.contenu,
    required this.date,
    this.lu = false,
    this.annonceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'expediteurId': expediteurId,
      'destinataireId': destinataireId,
      'contenu': contenu,
      'date': date.toIso8601String(),
      'lu': lu,
      'annonceId': annonceId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      expediteurId: map['expediteurId'] ?? '',
      destinataireId: map['destinataireId'] ?? '',
      contenu: map['contenu'] ?? '',
      date: DateTime.parse(map['date']),
      lu: map['lu'] ?? false,
      annonceId: map['annonceId'],
    );
  }
}


