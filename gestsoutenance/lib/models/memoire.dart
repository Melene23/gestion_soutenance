// lib/models/memoire.dart
import 'dart:convert';
import 'package:flutter/material.dart'; // IMPORT AJOUTÉ

enum EtatMemoire {
  enPreparation,
  soumis,
  valide,
}

// Extension pour obtenir le nom d'affichage
extension EtatMemoireExtension on EtatMemoire {
  String get displayName {
    switch (this) {
      case EtatMemoire.enPreparation:
        return 'En préparation';
      case EtatMemoire.soumis:
        return 'Soumis';
      case EtatMemoire.valide:
        return 'Validé';
    }
  }

  // Méthode pour obtenir la couleur selon l'état
  Color get color {
    switch (this) {
      case EtatMemoire.enPreparation:
        return Colors.orange;
      case EtatMemoire.soumis:
        return Colors.blue;
      case EtatMemoire.valide:
        return Colors.green;
    }
  }
}

class Memoire {
  final String id;
  final String etudiantId;
  final String theme;
  final String description;
  final String encadreur;
  final EtatMemoire etat;
  final DateTime dateDebut;
  final DateTime? dateSoutenance;

  Memoire({
    required this.id,
    required this.etudiantId,
    required this.theme,
    required this.description,
    required this.encadreur,
    required this.etat,
    required this.dateDebut,
    this.dateSoutenance,
  });

  // Méthode toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'etudiantId': etudiantId,
      'theme': theme,
      'description': description,
      'encadreur': encadreur,
      'etat': etat.index,
      'dateDebut': dateDebut.toIso8601String(),
      'dateSoutenance': dateSoutenance?.toIso8601String(),
    };
  }

  // Méthode fromJson
  factory Memoire.fromJson(Map<String, dynamic> json) {
    return Memoire(
      id: json['id'] ?? '',
      etudiantId: json['etudiantId'] ?? '',
      theme: json['theme'] ?? '',
      description: json['description'] ?? '',
      encadreur: json['encadreur'] ?? '',
      etat: EtatMemoire.values[json['etat'] ?? 0],
      dateDebut: DateTime.parse(json['dateDebut'] ?? DateTime.now().toIso8601String()),
      dateSoutenance: json['dateSoutenance'] != null
          ? DateTime.parse(json['dateSoutenance'])
          : null,
    );
  }

  // Méthode copyWith
  Memoire copyWith({
    String? id,
    String? etudiantId,
    String? theme,
    String? description,
    String? encadreur,
    EtatMemoire? etat,
    DateTime? dateDebut,
    DateTime? dateSoutenance,
  }) {
    return Memoire(
      id: id ?? this.id,
      etudiantId: etudiantId ?? this.etudiantId,
      theme: theme ?? this.theme,
      description: description ?? this.description,
      encadreur: encadreur ?? this.encadreur,
      etat: etat ?? this.etat,
      dateDebut: dateDebut ?? this.dateDebut,
      dateSoutenance: dateSoutenance ?? this.dateSoutenance,
    );
  }
}