import 'package:flutter/material.dart';
import '../models/memoire.dart';
import '../core/services/database_service.dart';

class MemoireProvider with ChangeNotifier {
  List<Memoire> _memoires = [];
  bool _isLoading = false;
  String? _error;

  List<Memoire> get memoires => _memoires;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MemoireProvider() {
    loadMemoires();
  }

  Future<void> loadMemoires() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final database = DatabaseService();
      _memoires = await database.getMemoires();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des mémoires: $e';
      print('Erreur loadMemoires: $e'); // Debug
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemoire(Memoire memoire) async {
    try {
      _memoires.add(memoire);
      final database = DatabaseService();
      await database.saveMemoires(_memoires);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMemoire(Memoire memoire) async {
    try {
      final index = _memoires.indexWhere((m) => m.id == memoire.id);
      if (index != -1) {
        _memoires[index] = memoire;
        final database = DatabaseService();
        await database.saveMemoires(_memoires);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMemoire(String id) async {
    try {
      _memoires.removeWhere((m) => m.id == id);
      final database = DatabaseService();
      await database.saveMemoires(_memoires);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  // CORRECTION ICI : Retourne null si non trouvé au lieu de lancer une exception
  Memoire? getMemoireById(String id) {
    try {
      return _memoires.firstWhere((m) => m.id == id);
    } catch (e) {
      return null; // Retourne null si non trouvé
    }
  }

  // NOUVELLE MÉTHODE : Pour obtenir les mémoires disponibles pour soutenance
  List<Memoire> getMemoiresDisponiblesPourSoutenance({String? excludeId}) {
    return _memoires.where((m) {
      // Inclure tous les mémoires sauf ceux déjà validés
      // ou inclure celui en cours d'édition (excludeId)
      return m.etat != EtatMemoire.valide || 
             (excludeId != null && m.id == excludeId);
    }).toList();
  }

  // Pour compatibilité (utilisé par getMemoiresByEtat)
  List<Memoire> getMemoiresByEtat(int etatIndex) {
    if (etatIndex >= 0 && etatIndex < EtatMemoire.values.length) {
      final etat = EtatMemoire.values[etatIndex];
      return _memoires.where((m) => m.etat == etat).toList();
    }
    return [];
  }

  List<Memoire> getMemoiresByEtudiant(String etudiantId) {
    return _memoires.where((m) => m.etudiantId == etudiantId).toList();
  }
  
  // NOUVELLE MÉTHODE : Vérifier si un mémoire existe
  bool hasMemoire(String id) {
    return _memoires.any((m) => m.id == id);
  }
}