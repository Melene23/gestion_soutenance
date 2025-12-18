import 'package:flutter/material.dart';
import '../models/soutenance.dart';
import '../core/services/api_service.dart'; // ← CHANGÉ : ApiService au lieu de DatabaseService

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
      // ✅ CORRECTION : Utiliser ApiService pour charger depuis MySQL
      final apiService = ApiService();
      _soutenances = await apiService.getSoutenances();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des soutenances: $e';
      // En cas d'erreur, garder liste vide
      _soutenances = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSoutenance(Soutenance soutenance) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour envoyer à MySQL
      final apiService = ApiService();
      final createdSoutenance = await apiService.createSoutenance(soutenance);
      
      _soutenances.add(createdSoutenance);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSoutenance(Soutenance soutenance) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour mettre à jour dans MySQL
      final apiService = ApiService();
      final updatedSoutenance = await apiService.updateSoutenance(soutenance);
      
      final index = _soutenances.indexWhere((s) => s.id == soutenance.id);
      if (index != -1) {
        _soutenances[index] = updatedSoutenance;
      }
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSoutenance(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour supprimer de MySQL
      final apiService = ApiService();
      await apiService.deleteSoutenance(id);
      
      _soutenances.removeWhere((s) => s.id == id);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Soutenance? getSoutenanceById(String id) {
    try {
      return _soutenances.firstWhere((s) => s.id == id);
    } catch (e) {
      return null; // Retourne null si non trouvé
    }
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

  // ✅ NOUVELLES MÉTHODES AJOUTÉES :
  
  // Méthode pour vider les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Méthode pour rafraîchir les données
  Future<void> refresh() async {
    await loadSoutenances();
  }

  // Méthode pour obtenir les soutenances à venir
  List<Soutenance> getSoutenancesAVenir() {
    final now = DateTime.now();
    return _soutenances.where((s) => s.dateHeure.isAfter(now)).toList();
  }

  // Méthode pour obtenir les soutenances passées
  List<Soutenance> getSoutenancesPassees() {
    final now = DateTime.now();
    return _soutenances.where((s) => s.dateHeure.isBefore(now)).toList();
  }

  // Méthode pour obtenir les soutenances du mois
  List<Soutenance> getSoutenancesDuMois() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return _soutenances.where((s) => 
      s.dateHeure.isAfter(startOfMonth) && 
      s.dateHeure.isBefore(endOfMonth)
    ).toList();
  }

  // Méthode pour obtenir les soutenances par salle
  List<Soutenance> getSoutenancesBySalle(String salleId) {
    return _soutenances.where((s) => s.salleId == salleId).toList();
  }

  // Méthode pour obtenir les soutenances par mémoire
  List<Soutenance> getSoutenancesByMemoire(String memoireId) {
    return _soutenances.where((s) => s.memoireId == memoireId).toList();
  }

  // Méthode pour vérifier la disponibilité d'une salle à une heure précise
  bool isSalleDisponibleAvecPrecision(String salleId, DateTime dateHeure, Duration duree, {String? excludeId}) {
    final heureFin = dateHeure.add(duree);
    
    return !_soutenances.any((s) {
      if (excludeId != null && s.id == excludeId) return false;
      if (s.salleId != salleId) return false;
      
      final sHeureFin = s.dateHeure.add(const Duration(hours: 2)); // Durée par défaut
      
      // Vérifier si les créneaux se chevauchent
      final chevauchement = 
        (dateHeure.isBefore(sHeureFin) && heureFin.isAfter(s.dateHeure));
      
      return chevauchement;
    });
  }

  // Méthode pour trier les soutenances par date
  List<Soutenance> getSoutenancesTrieesParDate({bool croissant = true}) {
    final sorted = List<Soutenance>.from(_soutenances);
    sorted.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return croissant ? sorted : sorted.reversed.toList();
  }
}