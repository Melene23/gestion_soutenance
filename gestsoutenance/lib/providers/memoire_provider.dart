import 'package:flutter/material.dart';
import '../models/memoire.dart';
import '../core/services/api_service.dart';

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
      final api = ApiService();
      _memoires = await api.getMemoires();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des mémoires: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemoire(Memoire memoire) async {
    try {
      final api = ApiService();
      final created = await api.createMemoire(memoire);
      _memoires.add(created);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMemoire(Memoire memoire) async {
    try {
      final api = ApiService();
      final updated = await api.updateMemoire(memoire);
      final index = _memoires.indexWhere((m) => m.id == memoire.id);
      if (index != -1) {
        _memoires[index] = updated;
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
      final api = ApiService();
      await api.deleteMemoire(id);
      _memoires.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  Memoire? getMemoireById(String id) {
    return _memoires.firstWhere((m) => m.id == id);
  }

  List<Memoire> getMemoiresByEtat(int etatIndex) {
    final etat = EtatMemoire.values[etatIndex];
    return _memoires.where((m) => m.etat == etat).toList();
  }

  List<Memoire> getMemoiresByEtudiant(String etudiantId) {
    return _memoires.where((m) => m.etudiantId == etudiantId).toList();
  }
}