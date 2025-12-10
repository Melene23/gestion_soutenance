import 'package:flutter/material.dart';
import '../models/soutenance.dart';
import '../core/services/api_service.dart';

class SoutenanceProvider with ChangeNotifier {
  List<Soutenance> _soutenances = [];
  bool _isLoading = false;
  String? _error;

  List<Soutenance> get soutenances => _soutenances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SoutenanceProvider() {
    loadSoutenances();
  }

  Future<void> loadSoutenances() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final api = ApiService();
      _soutenances = await api.getSoutenances();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des soutenances: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSoutenance(Soutenance soutenance) async {
    try {
      final api = ApiService();
      final created = await api.createSoutenance(soutenance);
      _soutenances.add(created);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSoutenance(Soutenance soutenance) async {
    try {
      final api = ApiService();
      final updated = await api.updateSoutenance(soutenance);
      final index = _soutenances.indexWhere((s) => s.id == soutenance.id);
      if (index != -1) {
        _soutenances[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSoutenance(String id) async {
    try {
      final api = ApiService();
      await api.deleteSoutenance(id);
      _soutenances.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      rethrow;
    }
  }

  Soutenance? getSoutenanceById(String id) {
    return _soutenances.firstWhere((s) => s.id == id);
  }

  List<Soutenance> getSoutenancesByDate(DateTime date) {
    return _soutenances.where((s) => 
      s.dateHeure.year == date.year &&
      s.dateHeure.month == date.month &&
      s.dateHeure.day == date.day
    ).toList();
  }

  bool hasSalleConflict(String salleId, DateTime dateHeure, {String? excludeId}) {
    return _soutenances.any((s) {
      if (excludeId != null && s.id == excludeId) return false;
      
      final sameSalle = s.salleId == salleId;
      final sameTime = s.dateHeure.difference(dateHeure).abs() < const Duration(hours: 2);
      
      return sameSalle && sameTime;
    });
  }

  bool hasMemoireConflict(String memoireId, DateTime dateHeure, {String? excludeId}) {
    return _soutenances.any((s) {
      if (excludeId != null && s.id == excludeId) return false;
      
      final sameMemoire = s.memoireId == memoireId;
      final sameTime = s.dateHeure.difference(dateHeure).abs() < const Duration(days: 1);
      
      return sameMemoire && sameTime;
    });
  }
}