import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class MetadataProvider with ChangeNotifier {
  List<String> _filieres = [];
  List<String> _niveaux = [];
  bool _isLoading = false;
  String? _error;

  List<String> get filieres => _filieres;
  List<String> get niveaux => _niveaux;
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
      _filieres = metadata['filieres'] ?? [];
      _niveaux = metadata['niveaux'] ?? [];
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des métadonnées: $e';
      // Valeurs par défaut si l'API échoue
      _filieres = ['Informatique', 'Gestion', 'Comptabilité', 'Marketing'];
      _niveaux = ['Licence 1', 'Licence 2', 'Licence 3', 'Master 1', 'Master 2'];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addFiliere(String filiere) {
    if (!_filieres.contains(filiere)) {
      _filieres.add(filiere);
      _filieres.sort();
      notifyListeners();
    }
  }

  void addNiveau(String niveau) {
    if (!_niveaux.contains(niveau)) {
      _niveaux.add(niveau);
      _niveaux.sort();
      notifyListeners();
    }
  }
}

