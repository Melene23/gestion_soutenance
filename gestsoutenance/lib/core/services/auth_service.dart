// Service d'authentification avec PHP MySQL
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUser;
  String? _userNom;
  String? _userPrenom;
  String? _userId;

  // Clés pour SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserNom = 'user_nom';
  static const String _keyUserPrenom = 'user_prenom';

  // Initialiser depuis SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userId = prefs.getString(_keyUserId);
      _currentUser = prefs.getString(_keyUserEmail);
      _userNom = prefs.getString(_keyUserNom);
      _userPrenom = prefs.getString(_keyUserPrenom);
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _lastError = null;
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.timeout);

      String responseBody = utf8.decode(response.bodyBytes);
      dynamic data;
      
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        _lastError = 'Réponse invalide du serveur. Vérifiez que le serveur est bien démarré.';
        debugPrint('Erreur de décodage JSON: $e');
        debugPrint('Réponse du serveur: $responseBody');
        return false;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data']['user'];
        
        _isLoggedIn = true;
        _userId = user['id'].toString();
        _currentUser = user['email'];
        _userNom = user['nom'];
        _userPrenom = user['prenom'];

        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, _userId!);
        await prefs.setString(_keyUserEmail, _currentUser!);
        await prefs.setString(_keyUserNom, _userNom!);
        await prefs.setString(_keyUserPrenom, _userPrenom!);

        return true;
      } else {
        _lastError = data['message'] ?? 'Erreur de connexion';
        debugPrint('Erreur de connexion: $_lastError');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        _lastError = 'Délai d\'attente dépassé. Vérifiez votre connexion internet et que le serveur est bien démarré.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        _lastError = 'Impossible de se connecter au serveur. Vérifiez que le serveur est bien démarré et que l\'URL est correcte.';
      } else {
        _lastError = 'Erreur de connexion: ${e.toString()}';
      }
      debugPrint('Erreur lors de la connexion: $e');
      return false;
    }
  }

  String? _lastError;

  String? get lastError => _lastError;

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    _lastError = null;
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.timeout);

      // Vérifier si la réponse est un JSON valide
      String responseBody = utf8.decode(response.bodyBytes);
      dynamic data;
      
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        _lastError = 'Réponse invalide du serveur. Vérifiez que le serveur est bien démarré.';
        debugPrint('Erreur de décodage JSON: $e');
        debugPrint('Réponse du serveur: $responseBody');
        return false;
      }

      if ((response.statusCode == 201 || response.statusCode == 200) && data['success'] == true) {
        final user = data['data']['user'];
        
        _isLoggedIn = true;
        _userId = user['id'].toString();
        _currentUser = user['email'];
        _userNom = user['nom'];
        _userPrenom = user['prenom'];

        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, _userId!);
        await prefs.setString(_keyUserEmail, _currentUser!);
        await prefs.setString(_keyUserNom, _userNom!);
        await prefs.setString(_keyUserPrenom, _userPrenom!);

        return true;
      } else {
        // Récupérer le message d'erreur du serveur
        _lastError = data['message'] ?? 'Erreur lors de l\'inscription';
        
        // Si il y a des erreurs détaillées, les ajouter
        if (data['data'] != null && data['data']['errors'] != null) {
          final errors = data['data']['errors'] as List;
          if (errors.isNotEmpty) {
            _lastError = errors.join(', ');
          }
        }
        
        debugPrint('Erreur d\'inscription: $_lastError');
        debugPrint('Code de statut: ${response.statusCode}');
        debugPrint('Réponse complète: $data');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        _lastError = 'Délai d\'attente dépassé. Vérifiez votre connexion internet et que le serveur est bien démarré.';
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('Failed to fetch') ||
                 e.toString().contains('ClientException')) {
        _lastError = 'Impossible de se connecter au serveur. Vérifiez que:\n- Apache est démarré dans XAMPP\n- L\'URL est correcte: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}\n- Les permissions réseau sont activées';
      } else {
        _lastError = 'Erreur de connexion: ${e.toString()}';
      }
      debugPrint('Erreur lors de l\'inscription: $e');
      debugPrint('URL tentée: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Optionnel: appeler l'endpoint de déconnexion côté serveur
      // final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}');
      // await http.post(url, headers: ApiConfig.headers).timeout(ApiConfig.timeout);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    } finally {
      _isLoggedIn = false;
      _currentUser = null;
      _userNom = null;
      _userPrenom = null;
      _userId = null;

      // Supprimer de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserNom);
      await prefs.remove(_keyUserPrenom);
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get userNom => _userNom;
  String? get userPrenom => _userPrenom;
  String? get userId => _userId;
}