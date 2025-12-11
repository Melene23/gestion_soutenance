import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class MetadataService {
  static final MetadataService _instance = MetadataService._internal();
  factory MetadataService() => _instance;
  MetadataService._internal();

  // Cache pour éviter les appels répétés
  Map<String, dynamic>? _cachedMetadata;
  List<Map<String, dynamic>>? _cachedFilieres;
  List<Map<String, dynamic>>? _cachedNiveaux;
  List<Map<String, dynamic>>? _cachedEncadreurs;

  // Récupérer toutes les métadonnées
  Future<Map<String, dynamic>> getAllMetadata({bool forceRefresh = false}) async {
    if (_cachedMetadata != null && !forceRefresh) {
      return _cachedMetadata!;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.metadataEndpoint}'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          _cachedMetadata = Map<String, dynamic>.from(data['data']);
          
          debugPrint('✅ getAllMetadata: ${_cachedMetadata!.length} catégories chargées');
          return _cachedMetadata!;
        } else {
          debugPrint('⚠️ getAllMetadata: API retourne success=false');
        }
      } else {
        debugPrint('❌ getAllMetadata: Status ${response.statusCode}');
      }
      
      return _getDefaultMetadata();
    } catch (e) {
      debugPrint('❌ Erreur getAllMetadata: $e');
      return _getDefaultMetadata();
    }
  }

  // Récupérer uniquement les filières
  Future<List<Map<String, dynamic>>> getFilieres({bool forceRefresh = false}) async {
    if (_cachedFilieres != null && !forceRefresh) {
      return _cachedFilieres!;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.filieresEndpoint}'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          _cachedFilieres = List<Map<String, dynamic>>.from(data['data']);
          
          debugPrint('✅ getFilieres: ${_cachedFilieres!.length} filières chargées');
          return _cachedFilieres!;
        } else {
          debugPrint('⚠️ getFilieres: API retourne success=false');
        }
      } else {
        debugPrint('❌ getFilieres: Status ${response.statusCode}');
      }
      
      return _getDefaultMetadata()['filieres'] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('❌ Erreur getFilieres: $e');
      return _getDefaultMetadata()['filieres'] as List<Map<String, dynamic>>;
    }
  }

  // Récupérer uniquement les niveaux
  Future<List<Map<String, dynamic>>> getNiveaux({bool forceRefresh = false}) async {
    if (_cachedNiveaux != null && !forceRefresh) {
      return _cachedNiveaux!;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.niveauxEndpoint}'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          _cachedNiveaux = List<Map<String, dynamic>>.from(data['data']);
          
          debugPrint('✅ getNiveaux: ${_cachedNiveaux!.length} niveaux chargés');
          return _cachedNiveaux!;
        } else {
          debugPrint('⚠️ getNiveaux: API retourne success=false');
        }
      } else {
        debugPrint('❌ getNiveaux: Status ${response.statusCode}');
      }
      
      return _getDefaultMetadata()['niveaux'] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('❌ Erreur getNiveaux: $e');
      return _getDefaultMetadata()['niveaux'] as List<Map<String, dynamic>>;
    }
  }

  // Récupérer les encadreurs
  Future<List<Map<String, dynamic>>> getEncadreurs({bool forceRefresh = false}) async {
    if (_cachedEncadreurs != null && !forceRefresh) {
      return _cachedEncadreurs!;
    }

    try {
      final metadata = await getAllMetadata(forceRefresh: forceRefresh);
      final encadreurs = metadata['encadreurs'];
      
      if (encadreurs is List) {
        _cachedEncadreurs = List<Map<String, dynamic>>.from(encadreurs);
        debugPrint('✅ getEncadreurs: ${_cachedEncadreurs!.length} encadreurs chargés');
        return _cachedEncadreurs!;
      } else {
        debugPrint('⚠️ getEncadreurs: Format encadreurs incorrect');
      }
      
      return _getDefaultMetadata()['encadreurs'] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('❌ Erreur getEncadreurs: $e');
      return _getDefaultMetadata()['encadreurs'] as List<Map<String, dynamic>>;
    }
  }

  // Méthode utilitaire pour récupérer filières ET niveaux en un seul appel
  Future<Map<String, List<Map<String, dynamic>>>> getFilieresEtNiveaux() async {
    try {
      final [filieres, niveaux] = await Future.wait([
        getFilieres(),
        getNiveaux(),
      ]);
      
      return {
        'filieres': filieres,
        'niveaux': niveaux,
      };
    } catch (e) {
      debugPrint('❌ Erreur getFilieresEtNiveaux: $e');
      return {
        'filieres': _getDefaultMetadata()['filieres'] as List<Map<String, dynamic>>,
        'niveaux': _getDefaultMetadata()['niveaux'] as List<Map<String, dynamic>>,
      };
    }
  }

  // Métadonnées par défaut avec les VRAIES données - version typée
  Map<String, dynamic> _getDefaultMetadata() {
    return {
      'filieres': <Map<String, dynamic>>[
        {'id': 1, 'nom': 'Informatique de gestion', 'code': 'INFO_GEST'},
        {'id': 2, 'nom': 'Planification des projets', 'code': 'PLAN_PROJ'},
        {'id': 3, 'nom': 'Gestion de Banque et Assurance', 'code': 'BANQUE_ASS'},
        {'id': 4, 'nom': 'Gestion Commerciale', 'code': 'GEST_COM'},
        {'id': 5, 'nom': 'Gestion des Transports & Logistiques', 'code': 'TRANS_LOG'},
        {'id': 6, 'nom': 'Gestion des Ressources Humaines (GRH)', 'code': 'GRH'},
        {'id': 7, 'nom': 'Statistiques', 'code': 'STAT'},
      ],
      'niveaux': <Map<String, dynamic>>[
        {'id': 1, 'nom': 'Licence 2 (L2)', 'code': 'L2'},
        {'id': 2, 'nom': 'Licence 3 (L3)', 'code': 'L3'},
        {'id': 3, 'nom': 'Master 2 (M2)', 'code': 'M2'},
      ],
      'encadreurs': <Map<String, dynamic>>[
        {'id': 1, 'nom': 'Dr. Jean Martin', 'specialite': 'Informatique de gestion'},
        {'id': 2, 'nom': 'Dr. Marie Dupont', 'specialite': 'Planification'},
        {'id': 3, 'nom': 'Dr. Pierre Dubois', 'specialite': 'Gestion financière'},
      ],
    };
  }

  // Nettoyer le cache
  void clearCache() {
    _cachedMetadata = null;
    _cachedFilieres = null;
    _cachedNiveaux = null;
    _cachedEncadreurs = null;
    debugPrint('🧹 Cache MetadataService nettoyé');
  }

  // Statistiques du cache (pour debug)
  void printCacheStats() {
    debugPrint('📊 Statistiques du cache MetadataService:');
    debugPrint('   • Metadata: ${_cachedMetadata != null ? "chargé" : "vide"}');
    debugPrint('   • Filières: ${_cachedFilieres?.length ?? 0} éléments');
    debugPrint('   • Niveaux: ${_cachedNiveaux?.length ?? 0} éléments');
    debugPrint('   • Encadreurs: ${_cachedEncadreurs?.length ?? 0} éléments');
  }
}