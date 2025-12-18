import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../core/services/api_service.dart'; // ← IMPORTANT : Utiliser ApiService, pas DatabaseService

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
      // ✅ CORRECTION : Utiliser ApiService pour charger depuis MySQL
      final apiService = ApiService();
      _etudiants = await apiService.getEtudiants();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des étudiants: $e';
      // En cas d'erreur, on garde la liste vide plutôt que de planter
      _etudiants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEtudiant(Etudiant etudiant) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour envoyer à MySQL
      final apiService = ApiService();
      final createdEtudiant = await apiService.createEtudiant(etudiant);
      
      // Ajouter l'étudiant créé (avec les données du serveur)
      _etudiants.add(createdEtudiant);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEtudiant(Etudiant etudiant) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour mettre à jour dans MySQL
      final apiService = ApiService();
      final updatedEtudiant = await apiService.updateEtudiant(etudiant);
      
      final index = _etudiants.indexWhere((e) => e.id == etudiant.id);
      if (index != -1) {
        _etudiants[index] = updatedEtudiant;
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

  Future<void> deleteEtudiant(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour supprimer de MySQL
      final apiService = ApiService();
      await apiService.deleteEtudiant(id);
      
      _etudiants.removeWhere((e) => e.id == id);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Etudiant? getEtudiantById(String id) {
    try {
      return _etudiants.firstWhere((e) => e.id == id);
    } catch (e) {
      return null; // Retourne null si non trouvé
    }
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

  // Méthode pour vider les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Méthode pour rafraîchir les données
  Future<void> refresh() async {
    await loadEtudiants();
  }
}