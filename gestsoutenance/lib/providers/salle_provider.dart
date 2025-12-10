import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../core/services/api_service.dart';

class SalleProvider with ChangeNotifier {
  List<Salle> _salles = [];
  bool _isLoading = false;
  String? _error;

  List<Salle> get salles => _salles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SalleProvider() {
    loadSalles();
  }

  Future<void> loadSalles() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final api = ApiService();
      _salles = await api.getSalles();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des salles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSalle(Salle salle) async {
    try {
      final api = ApiService();
      final created = await api.createSalle(salle);
      _salles.add(created);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSalle(Salle salle) async {
    try {
      final api = ApiService();
      final updated = await api.updateSalle(salle);
      final index = _salles.indexWhere((s) => s.id == salle.id);
      if (index != -1) {
        _salles[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSalle(String id) async {
    try {
      final api = ApiService();
      await api.deleteSalle(id);
      _salles.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  Salle? getSalleById(String id) {
    return _salles.firstWhere((s) => s.id == id);
  }

  List<Salle> getSallesDisponibles() {
    return _salles.where((s) => s.disponible).toList();
  }

  bool isSalleDisponible(String salleId, DateTime dateHeure) {
    final salle = getSalleById(salleId);
    if (salle == null || !salle.disponible) return false;
    
    // Vérifier les conflits (à implémenter avec le provider de soutenances)
    return true;
  }
}