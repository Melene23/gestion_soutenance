// lib/models/etudiant.dart
import 'dart:convert';

class Etudiant {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String filiere;
  final String niveau;
  final String encadreur;
  final DateTime dateInscription; // AJOUTÉ

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.filiere,
    required this.niveau,
    required this.encadreur,
    DateTime? dateInscription, // OPTIONNEL
  }) : dateInscription = dateInscription ?? DateTime.now();

  // Getter pour nomComplet
  String get nomComplet => '$nom $prenom';

  // Méthode toJson (pour database_service)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'filiere': filiere,
      'niveau': niveau,
      'encadreur': encadreur,
      'dateInscription': dateInscription.toIso8601String(),
    };
  }

  // Méthode fromJson (pour database_service)
  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      filiere: json['filiere'] ?? '',
      niveau: json['niveau'] ?? '',
      encadreur: json['encadreur'] ?? '',
      dateInscription: json['dateInscription'] != null
          ? DateTime.parse(json['dateInscription'])
          : DateTime.now(),
    );
  }

  // Méthode pour convertir en Map (alias de toJson)
  Map<String, dynamic> toMap() => toJson();

  // Méthode pour créer depuis un Map (alias de fromJson)
  factory Etudiant.fromMap(Map<String, dynamic> map) => Etudiant.fromJson(map);

  // Méthode pour créer une copie
  Etudiant copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? filiere,
    String? niveau,
    String? encadreur,
    DateTime? dateInscription,
  }) {
    return Etudiant(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      filiere: filiere ?? this.filiere,
      niveau: niveau ?? this.niveau,
      encadreur: encadreur ?? this.encadreur,
      dateInscription: dateInscription ?? this.dateInscription,
    );
  }
}