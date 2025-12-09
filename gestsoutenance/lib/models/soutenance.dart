class Soutenance {
  final String id;
  final String memoireId;
  final String salleId;
  final DateTime dateHeure;
  final List<String> jury;
  final String? notes;

  Soutenance({
    required this.id,
    required this.memoireId,
    required this.salleId,
    required this.dateHeure,
    required this.jury,
    this.notes,
  });

  String get juryDisplay => jury.join(', ');

  Soutenance copyWith({
    String? id,
    String? memoireId,
    String? salleId,
    DateTime? dateHeure,
    List<String>? jury,
    String? notes,
  }) {
    return Soutenance(
      id: id ?? this.id,
      memoireId: memoireId ?? this.memoireId,
      salleId: salleId ?? this.salleId,
      dateHeure: dateHeure ?? this.dateHeure,
      jury: jury ?? this.jury,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memoireId': memoireId,
      'salleId': salleId,
      'dateHeure': dateHeure.toIso8601String(),
      'jury': jury,
      'notes': notes,
    };
  }

  factory Soutenance.fromJson(Map<String, dynamic> json) {
    return Soutenance(
      id: json['id'],
      memoireId: json['memoireId'],
      salleId: json['salleId'],
      dateHeure: DateTime.parse(json['dateHeure']),
      jury: List<String>.from(json['jury']),
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    return 'Soutenance(id: $id, date: $dateHeure, salle: $salleId)';
  }
}