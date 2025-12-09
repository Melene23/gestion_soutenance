import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/etudiant.dart';
import '../../models/memoire.dart';
import '../../models/salle.dart';
import '../../models/soutenance.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _etudiantsKey = 'etudiants';
  static const String _memoiresKey = 'memoires';
  static const String _sallesKey = 'salles';
  static const String _soutenancesKey = 'soutenances';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Étudiants
  Future<List<Etudiant>> getEtudiants() async {
    final prefs = await _prefs;
    final data = prefs.getString(_etudiantsKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Etudiant.fromJson(json)).toList();
  }

  Future<void> saveEtudiants(List<Etudiant> etudiants) async {
    final prefs = await _prefs;
    final jsonList = etudiants.map((e) => e.toJson()).toList();
    await prefs.setString(_etudiantsKey, jsonEncode(jsonList));
  }

  // Mémoires
  Future<List<Memoire>> getMemoires() async {
    final prefs = await _prefs;
    final data = prefs.getString(_memoiresKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Memoire.fromJson(json)).toList();
  }

  Future<void> saveMemoires(List<Memoire> memoires) async {
    final prefs = await _prefs;
    final jsonList = memoires.map((m) => m.toJson()).toList();
    await prefs.setString(_memoiresKey, jsonEncode(jsonList));
  }

  // Salles
  Future<List<Salle>> getSalles() async {
    final prefs = await _prefs;
    final data = prefs.getString(_sallesKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Salle.fromJson(json)).toList();
  }

  Future<void> saveSalles(List<Salle> salles) async {
    final prefs = await _prefs;
    final jsonList = salles.map((s) => s.toJson()).toList();
    await prefs.setString(_sallesKey, jsonEncode(jsonList));
  }

  // Soutenances
  Future<List<Soutenance>> getSoutenances() async {
    final prefs = await _prefs;
    final data = prefs.getString(_soutenancesKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Soutenance.fromJson(json)).toList();
  }

  Future<void> saveSoutenances(List<Soutenance> soutenances) async {
    final prefs = await _prefs;
    final jsonList = soutenances.map((s) => s.toJson()).toList();
    await prefs.setString(_soutenancesKey, jsonEncode(jsonList));
  }

  // Méthode pour initialiser des données de test
  Future<void> initializeTestData() async {
    final etudiants = await getEtudiants();
    if (etudiants.isEmpty) {
      await saveEtudiants([
        Etudiant(
          id: '1',
          nom: 'Dupont',
          prenom: 'Jean',
          email: 'jean.dupont@email.com',
          telephone: '0612345678',
          filiere: 'Informatique',
          niveau: 'Master 2',
          encadreur: 'Prof. Martin',
        ),
      ]);
    }
    
    final salles = await getSalles();
    if (salles.isEmpty) {
      await saveSalles([
        Salle(
          id: '1',
          nom: 'Amphithéâtre A',
          capacite: 100,
          equipements: ['Projecteur', 'Tableau', 'Micro'],
        ),
      ]);
    }
    
    debugPrint('Données de test initialisées');
  }
}