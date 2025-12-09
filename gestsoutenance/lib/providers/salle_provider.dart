import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../core/services/database_service.dart';

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
      final database = DatabaseService();
      _salles = await database.getSalles();
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
      _salles.add(salle);
      final database = DatabaseService();
      await database.saveSalles(_salles);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSalle(Salle salle) async {
    try {
      final index = _salles.indexWhere((s) => s.id == salle.id);
      if (index != -1) {
        _salles[index] = salle;
        final database = DatabaseService();
        await database.saveSalles(_salles);
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
      _salles.removeWhere((s) => s.id == id);
      final database = DatabaseService();
      await database.saveSalles(_salles);
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