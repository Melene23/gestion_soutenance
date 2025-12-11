import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class MetadataProvider with ChangeNotifier {
  // Changé de List<String> à List<Map<String, dynamic>>
  List<Map<String, dynamic>> _filieres = [];
  List<Map<String, dynamic>> _niveaux = [];
  List<Map<String, dynamic>> _encadreurs = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters avec les bons types
  List<Map<String, dynamic>> get filieres => _filieres;
  List<Map<String, dynamic>> get niveaux => _niveaux;
  List<Map<String, dynamic>> get encadreurs => _encadreurs;
  
  // Getters pour les noms seulement (utile pour les dropdowns)
  List<String> get filiereNoms => _filieres.map((f) => f['nom'] as String).toList();
  List<String> get niveauNoms => _niveaux.map((n) => n['nom'] as String).toList();
  List<String> get encadreurNoms => _encadreurs.map((e) => e['nom'] as String).toList();
  
  // Getters pour les IDs
  List<String> get filiereIds => _filieres.map((f) => f['id'].toString()).toList();
  List<String> get niveauIds => _niveaux.map((n) => n['id'].toString()).toList();
  List<String> get encadreurIds => _encadreurs.map((e) => e['id'].toString()).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  MetadataProvider() {
    loadMetadata();
  }

  Future<void> loadMetadata() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final api = ApiService();
      final metadata = await api.getMetadata();
      
      // Extraire les données avec le bon type
      _filieres = metadata['filieres'] ?? [];
      _niveaux = metadata['niveaux'] ?? [];
      _encadreurs = metadata['encadreurs'] ?? [];
      
      _error = null;
      
      debugPrint('✅ Métadonnées chargées avec succès:');
      debugPrint('   - ${_filieres.length} filières');
      debugPrint('   - ${_niveaux.length} niveaux');
      debugPrint('   - ${_encadreurs.length} encadreurs');
      
    } catch (e) {
      _error = 'Erreur lors du chargement des métadonnées: $e';
      debugPrint('❌ Erreur MetadataProvider: $e');
      
      // Valeurs par défaut si l'API échoue
      _filieres = [
        {'id': 1, 'nom': 'Informatique de gestion'},
        {'id': 2, 'nom': 'Planification des projets'},
        {'id': 3, 'nom': 'Gestion de Banque et Assurance'},
        {'id': 4, 'nom': 'Gestion Commerciale'},
        {'id': 5, 'nom': 'Gestion des Transports & Logistiques'},
        {'id': 6, 'nom': 'Gestion des Ressources Humaines (GRH)'},
        {'id': 7, 'nom': 'Statistiques'},
      ];
      
      _niveaux = [
        {'id': 1, 'nom': 'Licence 2 (L2)'},
        {'id': 2, 'nom': 'Licence 3 (L3)'},
        {'id': 3, 'nom': 'Master 2 (M2)'},
      ];
      
      _encadreurs = [
        {'id': 1, 'nom': 'Dr. Jean Martin'},
        {'id': 2, 'nom': 'Dr. Marie Dupont'},
        {'id': 3, 'nom': 'Dr. Pierre Dubois'},
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthodes utilitaires pour trouver des éléments
  String? getFiliereNomById(String id) {
    try {
      return _filieres.firstWhere(
        (filiere) => filiere['id'].toString() == id,
        orElse: () => {'nom': 'Inconnu'},
      )['nom'] as String?;
    } catch (e) {
      return null;
    }
  }

  String? getNiveauNomById(String id) {
    try {
      return _niveaux.firstWhere(
        (niveau) => niveau['id'].toString() == id,
        orElse: () => {'nom': 'Inconnu'},
      )['nom'] as String?;
    } catch (e) {
      return null;
    }
  }

  String? getEncadreurNomById(String id) {
    try {
      return _encadreurs.firstWhere(
        (encadreur) => encadreur['id'].toString() == id,
        orElse: () => {'nom': 'Inconnu'},
      )['nom'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Méthode pour rafraîchir
  Future<void> refresh() async {
    await loadMetadata();
  }

  // Méthodes d'ajout (optionnelles)
  void addFiliere(Map<String, dynamic> filiere) {
    if (!_filieres.any((f) => f['id'] == filiere['id'])) {
      _filieres.add(filiere);
      notifyListeners();
    }
  }

  void addNiveau(Map<String, dynamic> niveau) {
    if (!_niveaux.any((n) => n['id'] == niveau['id'])) {
      _niveaux.add(niveau);
      notifyListeners();
    }
  }

  void addEncadreur(Map<String, dynamic> encadreur) {
    if (!_encadreurs.any((e) => e['id'] == encadreur['id'])) {
      _encadreurs.add(encadreur);
      notifyListeners();
    }
  }

  // Méthode pour réinitialiser
  void clear() {
    _filieres.clear();
    _niveaux.clear();
    _encadreurs.clear();
    _error = null;
    notifyListeners();
  }
}