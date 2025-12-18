import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../core/services/api_service.dart'; // ← CHANGÉ : ApiService au lieu de DatabaseService

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
      // ✅ CORRECTION : Utiliser ApiService pour charger depuis MySQL
      final apiService = ApiService();
      _salles = await apiService.getSalles();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des salles: $e';
      // En cas d'erreur, garder liste vide
      _salles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSalle(Salle salle) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour envoyer à MySQL
      final apiService = ApiService();
      final createdSalle = await apiService.createSalle(salle);
      
      _salles.add(createdSalle);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSalle(Salle salle) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour mettre à jour dans MySQL
      final apiService = ApiService();
      final updatedSalle = await apiService.updateSalle(salle);
      
      final index = _salles.indexWhere((s) => s.id == salle.id);
      if (index != -1) {
        _salles[index] = updatedSalle;
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

  Future<void> deleteSalle(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour supprimer de MySQL
      final apiService = ApiService();
      await apiService.deleteSalle(id);
      
      _salles.removeWhere((s) => s.id == id);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Salle? getSalleById(String id) {
    try {
      return _salles.firstWhere((s) => s.id == id);
    } catch (e) {
      return null; // Retourne null si non trouvé
    }
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

  // ✅ NOUVELLES MÉTHODES AJOUTÉES :
  
  // Méthode pour vider les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Méthode pour rafraîchir les données
  Future<void> refresh() async {
    await loadSalles();
  }

  // Méthode pour filtrer par disponibilité
  List<Salle> filterByDisponibilite(bool disponible) {
    return _salles.where((s) => s.disponible == disponible).toList();
  }

  // Méthode pour rechercher des salles par nom
  List<Salle> searchSalles(String query) {
    if (query.isEmpty) return _salles;
    
    final searchLower = query.toLowerCase();
    return _salles.where((salle) {
      return salle.nom.toLowerCase().contains(searchLower) ||
             salle.equipements.any((equipement) => 
               equipement.toLowerCase().contains(searchLower));
    }).toList();
  }

  // Méthode pour obtenir les salles avec une capacité minimum
  List<Salle> getSallesByCapaciteMin(int capaciteMin) {
    return _salles.where((s) => s.capacite >= capaciteMin).toList();
  }

  // Méthode pour obtenir les salles avec un équipement spécifique
  List<Salle> getSallesWithEquipement(String equipement) {
    final equipementLower = equipement.toLowerCase();
    return _salles.where((s) => 
      s.equipements.any((e) => e.toLowerCase().contains(equipementLower))
    ).toList();
  }
}