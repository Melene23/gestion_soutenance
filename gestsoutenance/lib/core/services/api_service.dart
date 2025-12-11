import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../../models/etudiant.dart';
import '../../models/memoire.dart';
import '../../models/salle.dart';
import '../../models/soutenance.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Étudiants
  Future<List<Etudiant>> getEtudiants() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.etudiantsEndpoint}');
      final response = await http.get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          return jsonList.map((json) => _etudiantFromApi(json)).toList();
        }
      }
      // Retourner une liste vide au lieu de throw pour éviter les boutons "Réessayer"
      debugPrint('Aucun étudiant trouvé ou erreur mineure');
      return [];
    } catch (e) {
      debugPrint('Erreur getEtudiants: $e');
      // Retourner liste vide au lieu de rethrow
      return [];
    }
  }

  Future<Etudiant> createEtudiant(Etudiant etudiant) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.etudiantsEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_etudiantToApi(etudiant)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _etudiantFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la création de l\'étudiant');
    } catch (e) {
      debugPrint('Erreur createEtudiant: $e');
      rethrow;
    }
  }

  Future<Etudiant> updateEtudiant(Etudiant etudiant) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.etudiantsEndpoint}/${etudiant.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_etudiantToApi(etudiant)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _etudiantFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la mise à jour de l\'étudiant');
    } catch (e) {
      debugPrint('Erreur updateEtudiant: $e');
      rethrow;
    }
  }

  Future<void> deleteEtudiant(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.etudiantsEndpoint}/$id');
      final response = await http.delete(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression de l\'étudiant');
      }
    } catch (e) {
      debugPrint('Erreur deleteEtudiant: $e');
      rethrow;
    }
  }

  // Mémoires
  Future<List<Memoire>> getMemoires() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.memoiresEndpoint}');
      final response = await http.get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          return jsonList.map((json) => _memoireFromApi(json)).toList();
        }
      }
      // Retourner liste vide au lieu de throw
      debugPrint('Aucun mémoire trouvé ou erreur mineure');
      return [];
    } catch (e) {
      debugPrint('Erreur getMemoires: $e');
      return [];
    }
  }

  Future<Memoire> createMemoire(Memoire memoire) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.memoiresEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_memoireToApi(memoire)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _memoireFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la création du mémoire');
    } catch (e) {
      debugPrint('Erreur createMemoire: $e');
      rethrow;
    }
  }

  Future<Memoire> updateMemoire(Memoire memoire) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.memoiresEndpoint}/${memoire.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_memoireToApi(memoire)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _memoireFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la mise à jour du mémoire');
    } catch (e) {
      debugPrint('Erreur updateMemoire: $e');
      rethrow;
    }
  }

  Future<void> deleteMemoire(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.memoiresEndpoint}/$id');
      final response = await http.delete(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du mémoire');
      }
    } catch (e) {
      debugPrint('Erreur deleteMemoire: $e');
      rethrow;
    }
  }

  // Salles
  Future<List<Salle>> getSalles() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sallesEndpoint}');
      final response = await http.get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          return jsonList.map((json) => _salleFromApi(json)).toList();
        }
      }
      // Retourner liste vide au lieu de throw
      debugPrint('Aucune salle trouvée ou erreur mineure');
      return [];
    } catch (e) {
      debugPrint('Erreur getSalles: $e');
      return [];
    }
  }

  Future<Salle> createSalle(Salle salle) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sallesEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_salleToApi(salle)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _salleFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la création de la salle');
    } catch (e) {
      debugPrint('Erreur createSalle: $e');
      rethrow;
    }
  }

  Future<Salle> updateSalle(Salle salle) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sallesEndpoint}/${salle.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_salleToApi(salle)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _salleFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la mise à jour de la salle');
    } catch (e) {
      debugPrint('Erreur updateSalle: $e');
      rethrow;
    }
  }

  Future<void> deleteSalle(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sallesEndpoint}/$id');
      final response = await http.delete(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression de la salle');
      }
    } catch (e) {
      debugPrint('Erreur deleteSalle: $e');
      rethrow;
    }
  }

  // Soutenances
  Future<List<Soutenance>> getSoutenances() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.soutenancesEndpoint}');
      final response = await http.get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          return jsonList.map((json) => _soutenanceFromApi(json)).toList();
        }
      }
      // Retourner liste vide au lieu de throw
      debugPrint('Aucune soutenance trouvée ou erreur mineure');
      return [];
    } catch (e) {
      debugPrint('Erreur getSoutenances: $e');
      return [];
    }
  }

  Future<Soutenance> createSoutenance(Soutenance soutenance) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.soutenancesEndpoint}');
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_soutenanceToApi(soutenance)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _soutenanceFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la création de la soutenance');
    } catch (e) {
      debugPrint('Erreur createSoutenance: $e');
      rethrow;
    }
  }

  Future<Soutenance> updateSoutenance(Soutenance soutenance) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.soutenancesEndpoint}/${soutenance.id}');
      final response = await http.put(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(_soutenanceToApi(soutenance)),
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return _soutenanceFromApi(data['data']);
        }
      }
      throw Exception('Erreur lors de la mise à jour de la soutenance');
    } catch (e) {
      debugPrint('Erreur updateSoutenance: $e');
      rethrow;
    }
  }

  Future<void> deleteSoutenance(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.soutenancesEndpoint}/$id');
      final response = await http.delete(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression de la soutenance');
      }
    } catch (e) {
      debugPrint('Erreur deleteSoutenance: $e');
      rethrow;
    }
  }

  // Métadonnées pour filières et niveaux
  Future<Map<String, List<Map<String, dynamic>>>> getMetadata() async {
    try {
      // Charger filières
      final filieresUrl = Uri.parse('${ApiConfig.baseUrl}filieres/list.php');
      final filieresResponse = await http.get(filieresUrl, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      // Charger niveaux
      final niveauxUrl = Uri.parse('${ApiConfig.baseUrl}niveaux/list.php');
      final niveauxResponse = await http.get(niveauxUrl, headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);
      
      List<Map<String, dynamic>> filieres = [];
      List<Map<String, dynamic>> niveaux = [];
      
      if (filieresResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(filieresResponse.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          filieres = List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      if (niveauxResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(niveauxResponse.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          niveaux = List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      return {
        'filieres': filieres,
        'niveaux': niveaux,
      };
    } catch (e) {
      debugPrint('Erreur getMetadata: $e');
      return {
        'filieres': [
          {'id': 1, 'nom': 'Informatique'},
          {'id': 2, 'nom': 'Mathématiques'},
          {'id': 3, 'nom': 'Physique'},
        ],
        'niveaux': [
          {'id': 1, 'nom': 'Licence 1'},
          {'id': 2, 'nom': 'Licence 2'},
          {'id': 3, 'nom': 'Licence 3'},
          {'id': 4, 'nom': 'Master 1'},
          {'id': 5, 'nom': 'Master 2'},
        ],
      };
    }
  }

  // Helpers pour convertir entre modèles Flutter et API
  Etudiant _etudiantFromApi(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      filiere: json['filiere']?.toString() ?? '',
      niveau: json['niveau']?.toString() ?? '',
      encadreur: json['encadreur'] ?? '',
      dateInscription: json['date_inscription'] != null
          ? DateTime.parse(json['date_inscription'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _etudiantToApi(Etudiant etudiant) {
    return {
      'id': etudiant.id,
      'nom': etudiant.nom,
      'prenom': etudiant.prenom,
      'email': etudiant.email,
      'telephone': etudiant.telephone,
      'filiere': etudiant.filiere,
      'niveau': etudiant.niveau,
      'encadreur': etudiant.encadreur,
    };
  }

  Memoire _memoireFromApi(Map<String, dynamic> json) {
    return Memoire(
      id: json['id']?.toString() ?? '',
      etudiantId: json['etudiant_id']?.toString() ?? '',
      theme: json['theme'] ?? '',
      description: json['description'] ?? '',
      encadreur: json['encadreur'] ?? '',
      etat: _parseEtatMemoire(json['etat'] ?? 'enPreparation'),
      dateDebut: json['date_debut'] != null
          ? DateTime.parse(json['date_debut'])
          : DateTime.now(),
      dateSoutenance: json['date_soutenance'] != null
          ? DateTime.parse(json['date_soutenance'])
          : null,
    );
  }

  Map<String, dynamic> _memoireToApi(Memoire memoire) {
    return {
      'id': memoire.id,
      'etudiant_id': memoire.etudiantId,
      'theme': memoire.theme,
      'description': memoire.description,
      'encadreur': memoire.encadreur,
      'etat': _etatMemoireToString(memoire.etat),
      'date_debut': memoire.dateDebut.toIso8601String(),
      'date_soutenance': memoire.dateSoutenance?.toIso8601String(),
    };
  }

  Salle _salleFromApi(Map<String, dynamic> json) {
    return Salle(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      capacite: int.tryParse(json['capacite'].toString()) ?? 0,
      equipements: json['equipements'] != null
          ? List<String>.from(json['equipements'])
          : [],
      disponible: json['disponible'] == 1 || json['disponible'] == true,
    );
  }

  Map<String, dynamic> _salleToApi(Salle salle) {
    return {
      'id': salle.id,
      'nom': salle.nom,
      'capacite': salle.capacite,
      'equipements': salle.equipements,
      'disponible': salle.disponible,
    };
  }

  Soutenance _soutenanceFromApi(Map<String, dynamic> json) {
    // Combiner date_soutenance, heure_debut pour créer dateHeure
    DateTime dateHeure = DateTime.parse(json['date_soutenance'] ?? DateTime.now().toIso8601String());
    if (json['heure_debut'] != null) {
      final timeParts = json['heure_debut'].toString().split(':');
      if (timeParts.length >= 2) {
        dateHeure = DateTime(
          dateHeure.year,
          dateHeure.month,
          dateHeure.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
    }
    
    return Soutenance(
      id: json['id']?.toString() ?? '',
      memoireId: json['memoire_id']?.toString() ?? '',
      salleId: json['salle_id']?.toString() ?? '',
      dateHeure: dateHeure,
      jury: json['jury'] != null ? List<String>.from(json['jury']) : [],
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> _soutenanceToApi(Soutenance soutenance) {
    return {
      'id': soutenance.id,
      'memoire_id': soutenance.memoireId,
      'salle_id': soutenance.salleId,
      'date_soutenance': soutenance.dateHeure.toIso8601String(),
      'heure_debut': '${soutenance.dateHeure.hour.toString().padLeft(2, '0')}:${soutenance.dateHeure.minute.toString().padLeft(2, '0')}:00',
      'jury': soutenance.jury,
      'notes': soutenance.notes ?? '',
    };
  }

  EtatMemoire _parseEtatMemoire(String etat) {
    switch (etat) {
      case 'enPreparation':
        return EtatMemoire.enPreparation;
      case 'soumis':
        return EtatMemoire.soumis;
      case 'valide':
        return EtatMemoire.valide;
      default:
        return EtatMemoire.enPreparation;
    }
  }

  String _etatMemoireToString(EtatMemoire etat) {
    switch (etat) {
      case EtatMemoire.enPreparation:
        return 'enPreparation';
      case EtatMemoire.soumis:
        return 'soumis';
      case EtatMemoire.valide:
        return 'valide';
    }
  }
}