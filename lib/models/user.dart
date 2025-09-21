class User {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String telephone;
  final DateTime dateCreation;
  final String role;
  final String? photo;

  User({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.dateCreation,
    this.role = 'user',
    this.photo,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'dateCreation': dateCreation.toIso8601String(),
      'role': role,
      'photo': photo,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      telephone: map['telephone'] ?? '',
      dateCreation: DateTime.parse(map['dateCreation']),
      role: map['role'] ?? 'user',
      photo: map['photo'],
    );
  }
}
