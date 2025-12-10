import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../core/services/api_service.dart';

class EtudiantProvider with ChangeNotifier {
  List<Etudiant> _etudiants = [];
  bool _isLoading = false;
  String? _error;

  List<Etudiant> get etudiants => _etudiants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EtudiantProvider() {
    loadEtudiants();
  }

  Future<void> loadEtudiants() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final api = ApiService();
      _etudiants = await api.getEtudiants();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des étudiants: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEtudiant(Etudiant etudiant) async {
    try {
      final api = ApiService();
      final created = await api.createEtudiant(etudiant);
      _etudiants.add(created);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEtudiant(Etudiant etudiant) async {
    try {
      final api = ApiService();
      final updated = await api.updateEtudiant(etudiant);
      final index = _etudiants.indexWhere((e) => e.id == etudiant.id);
      if (index != -1) {
        _etudiants[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEtudiant(String id) async {
    try {
      final api = ApiService();
      await api.deleteEtudiant(id);
      _etudiants.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  Etudiant? getEtudiantById(String id) {
    return _etudiants.firstWhere((e) => e.id == id);
  }

  List<Etudiant> searchEtudiants(String query) {
    if (query.isEmpty) return _etudiants;
    
    return _etudiants.where((etudiant) {
      final searchLower = query.toLowerCase();
      return etudiant.nom.toLowerCase().contains(searchLower) ||
             etudiant.prenom.toLowerCase().contains(searchLower) ||
             etudiant.email.toLowerCase().contains(searchLower) ||
             etudiant.filiere.toLowerCase().contains(searchLower);
    }).toList();
  }
}