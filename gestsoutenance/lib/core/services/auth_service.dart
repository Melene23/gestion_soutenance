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
  String? _lastError;

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

  String? get lastError => _lastError;

  Future<bool> login(String email, String password) async {
    _lastError = null;
    final client = http.Client();
    
    try {
      final url = Uri.parse('${ApiConfig.effectiveBaseUrl}${ApiConfig.loginEndpoint}');
      
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔐 TENTATIVE DE CONNEXION');
      debugPrint('URL: $url');
      debugPrint('Email: $email');
      debugPrint('Headers: ${ApiConfig.headers}');
      debugPrint('═══════════════════════════════════════');
      
      final response = await client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(ApiConfig.timeout);
      
      debugPrint('📥 RÉPONSE REÇUE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      
      String responseBody = utf8.decode(response.bodyBytes);
      debugPrint('Body: $responseBody');
      
      dynamic data;
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        _lastError = 'Réponse invalide du serveur. Vérifiez que le serveur est bien démarré.';
        debugPrint('❌ Erreur de décodage JSON: $e');
        debugPrint('Réponse brute: $responseBody');
        return false;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data']['user'];
        
        debugPrint('✅ CONNEXION RÉUSSIE');
        debugPrint('User ID: ${user['id']}');
        debugPrint('Email: ${user['email']}');
        
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
        _lastError = data['message'] ?? 'Email ou mot de passe incorrect';
        debugPrint('❌ Erreur de connexion: $_lastError');
        return false;
      }
    } catch (e) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ ERREUR LORS DE LA CONNEXION');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Message: $e');
      debugPrint('URL tentée: ${ApiConfig.effectiveBaseUrl}${ApiConfig.loginEndpoint}');
      debugPrint('═══════════════════════════════════════');
      
      String errorString = e.toString();
      
      if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
        _lastError = '⏱️ Délai d\'attente dépassé.\n\nVérifiez:\n- Votre connexion internet\n- Que le serveur est bien démarré (Apache dans XAMPP)\n- Que le port 80 n\'est pas bloqué';
      } else if (errorString.contains('SocketException') || 
                 errorString.contains('Failed host lookup') ||
                 errorString.contains('Failed to fetch') ||
                 errorString.contains('ClientException') ||
                 errorString.contains('XMLHttpRequest') ||
                 errorString.contains('NetworkError')) {
        _lastError = '🌐 Impossible de se connecter au serveur.\n\nVérifications:\n1. ✅ Apache est démarré dans XAMPP\n2. ✅ MySQL est démarré dans XAMPP\n3. ✅ Testez l\'URL dans votre navigateur:\n   ${ApiConfig.effectiveBaseUrl}test.php\n4. 🔍 Ouvrez F12 > Console pour voir les erreurs CORS\n\nURL utilisée: ${ApiConfig.effectiveBaseUrl}${ApiConfig.loginEndpoint}';
      } else if (errorString.contains('CORS') || errorString.contains('Access-Control')) {
        _lastError = '🚫 Erreur CORS détectée.\n\nVérifiez que les en-têtes CORS sont bien configurés dans:\n- api/auth/login.php\n- api/auth/register.php\n\nOuvrez F12 > Network > cliquez sur la requête > Headers';
      } else {
        _lastError = '❌ Erreur: ${e.toString()}\n\nURL: ${ApiConfig.effectiveBaseUrl}${ApiConfig.loginEndpoint}';
      }
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    _lastError = null;
    try {
      final url = Uri.parse('${ApiConfig.effectiveBaseUrl}${ApiConfig.registerEndpoint}');
      
      debugPrint('Tentative d\'inscription vers: $url');
      debugPrint('Headers: ${ApiConfig.headers}');
      
      // Pour Flutter Web, utiliser Client avec des options spéciales
      final client = http.Client();
      try {
        final response = await client.post(
          url,
          headers: ApiConfig.headers,
          body: jsonEncode({
            'nom': nom,
            'prenom': prenom,
            'email': email,
            'password': password,
          }),
        ).timeout(ApiConfig.timeout);
        
        debugPrint('Code de statut: ${response.statusCode}');
        debugPrint('Headers de réponse: ${response.headers}');

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
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ ERREUR LORS DE L\'INSCRIPTION');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Message: $e');
      debugPrint('URL tentée: ${ApiConfig.effectiveBaseUrl}${ApiConfig.registerEndpoint}');
      debugPrint('═══════════════════════════════════════');
      
      String errorString = e.toString();
      
      if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
        _lastError = '⏱️ Délai d\'attente dépassé.\n\nVérifiez:\n- Votre connexion internet\n- Que le serveur est bien démarré (Apache dans XAMPP)';
      } else if (errorString.contains('SocketException') || 
                 errorString.contains('Failed host lookup') ||
                 errorString.contains('Failed to fetch') ||
                 errorString.contains('ClientException') ||
                 errorString.contains('NetworkError') ||
                 errorString.contains('XMLHttpRequest')) {
        _lastError = '🌐 Impossible de se connecter au serveur.\n\nVérifications:\n1. ✅ Apache est démarré dans XAMPP\n2. ✅ MySQL est démarré dans XAMPP\n3. ✅ Testez l\'URL: ${ApiConfig.effectiveBaseUrl}test.php\n4. 🔍 Ouvrez F12 > Console pour voir les erreurs\n\nURL: ${ApiConfig.effectiveBaseUrl}${ApiConfig.registerEndpoint}';
      } else if (errorString.contains('CORS') || errorString.contains('Access-Control')) {
        _lastError = '🚫 Erreur CORS détectée.\n\nVérifiez les en-têtes CORS dans:\n- api/auth/register.php\n\nOuvrez F12 > Network > Headers';
      } else {
        _lastError = '❌ Erreur: ${e.toString()}\n\nURL: ${ApiConfig.effectiveBaseUrl}${ApiConfig.registerEndpoint}';
      }
      
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
      _lastError = null;

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
