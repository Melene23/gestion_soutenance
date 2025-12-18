import 'package:flutter/material.dart';
import '../models/memoire.dart';
import '../core/services/api_service.dart'; // ← CHANGÉ : ApiService au lieu de DatabaseService

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
      // ✅ CORRECTION : Utiliser ApiService pour charger depuis MySQL
      final apiService = ApiService();
      _memoires = await apiService.getMemoires();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des mémoires: $e';
      print('Erreur loadMemoires: $e');
      // En cas d'erreur, garder liste vide
      _memoires = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemoire(Memoire memoire) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour envoyer à MySQL
      final apiService = ApiService();
      final createdMemoire = await apiService.createMemoire(memoire);
      
      _memoires.add(createdMemoire);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMemoire(Memoire memoire) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour mettre à jour dans MySQL
      final apiService = ApiService();
      final updatedMemoire = await apiService.updateMemoire(memoire);
      
      final index = _memoires.indexWhere((m) => m.id == memoire.id);
      if (index != -1) {
        _memoires[index] = updatedMemoire;
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

  Future<void> deleteMemoire(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // ✅ CORRECTION : Utiliser ApiService pour supprimer de MySQL
      final apiService = ApiService();
      await apiService.deleteMemoire(id);
      
      _memoires.removeWhere((m) => m.id == id);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CORRECTION ICI : Retourne null si non trouvé au lieu de lancer une exception
  Memoire? getMemoireById(String id) {
    try {
      return _memoires.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Pour obtenir les mémoires disponibles pour soutenance
  List<Memoire> getMemoiresDisponiblesPourSoutenance({String? excludeId}) {
    return _memoires.where((m) {
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
  
  // Vérifier si un mémoire existe
  bool hasMemoire(String id) {
    return _memoires.any((m) => m.id == id);
  }

  // ✅ NOUVELLES MÉTHODES AJOUTÉES :
  
  // Méthode pour vider les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Méthode pour rafraîchir les données
  Future<void> refresh() async {
    await loadMemoires();
  }

  // Méthode pour filtrer par état (version améliorée)
  List<Memoire> filterByEtat(EtatMemoire etat) {
    return _memoires.where((m) => m.etat == etat).toList();
  }
}