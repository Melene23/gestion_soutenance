class Salle {
  final String id;
  final String nom;
  final int capacite;
  final List<String> equipements;
  final bool disponible;

  Salle({
    required this.id,
    required this.nom,
    required this.capacite,
    required this.equipements,
    this.disponible = true,
  });

  String get equipementsDisplay => equipements.join(', ');

  Salle copyWith({
    String? id,
    String? nom,
    int? capacite,
    List<String>? equipements,
    bool? disponible,
  }) {
    return Salle(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      capacite: capacite ?? this.capacite,
      equipements: equipements ?? this.equipements,
      disponible: disponible ?? this.disponible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'capacite': capacite,
      'equipements': equipements,
      'disponible': disponible,
    };
  }

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      id: json['id'],
      nom: json['nom'],
      capacite: json['capacite'],
      equipements: List<String>.from(json['equipements']),
      disponible: json['disponible'],
    );
  }

  @override
  String toString() {
    return 'Salle(id: $id, nom: $nom, capacite: $capacite)';
  }
}