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
  String? _userRole = 'etudiant'; // Par défaut étudiant
  String? _lastError;

  // Clés pour SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserNom = 'user_nom';
  static const String _keyUserPrenom = 'user_prenom';
  static const String _keyUserRole = 'user_role';

  // Initialiser depuis SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userId = prefs.getString(_keyUserId);
      _currentUser = prefs.getString(_keyUserEmail);
      _userNom = prefs.getString(_keyUserNom);
      _userPrenom = prefs.getString(_keyUserPrenom);
      _userRole = prefs.getString(_keyUserRole) ?? 'etudiant';
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation: $e');
    }
  }

  String? get lastError => _lastError;

  Future<bool> login(String email, String password) async {
    _lastError = null;
    
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔐 TENTATIVE DE CONNEXION');
    debugPrint('Email: $email');
    debugPrint('═══════════════════════════════════════');
    
    // ==============================================
    // COMPTES ADMIN PRÉDÉFINIS - PAS BESOIN D'API
    // ==============================================
    final List<Map<String, dynamic>> adminAccounts = [
      {
        'email': 'admin@eneam.bj',
        'password': 'admin123',
        'nom': 'Administrateur',
        'prenom': 'ENEAM',
        'role': 'admin'
      },
      {
        'email': 'superadmin@eneam.bj',
        'password': 'superadmin123',
        'nom': 'Super',
        'prenom': 'Administrateur',
        'role': 'admin'
      },
      {
        'email': 'administrateur@eneam.bj',
        'password': 'admin2024',
        'nom': 'Admin',
        'prenom': 'System',
        'role': 'admin'
      },
      {
        'email': 'test@admin.bj',
        'password': 'test123',
        'nom': 'Test',
        'prenom': 'Admin',
        'role': 'admin'
      },
      {
        'email': 'directeur@eneam.bj',
        'password': 'directeur123',
        'nom': 'Directeur',
        'prenom': 'ENEAM',
        'role': 'admin'
      },
      // Comptes de test courants
      {
        'email': 'admin',
        'password': 'admin',
        'nom': 'Admin',
        'prenom': 'Simple',
        'role': 'admin'
      },
      {
        'email': 'root',
        'password': 'root',
        'nom': 'Root',
        'prenom': 'User',
        'role': 'admin'
      },
      {
        'email': 'administrator',
        'password': 'password',
        'nom': 'Administrator',
        'prenom': 'System',
        'role': 'admin'
      },
    ];

    // Vérifier si c'est un compte admin prédéfini
    for (var account in adminAccounts) {
      if (email.toLowerCase().trim() == account['email'].toString().toLowerCase() && 
          password == account['password']) {
        
        debugPrint('✅ COMPTE ADMIN PRÉDÉFINI DÉTECTÉ');
        debugPrint('Nom: ${account['nom']} ${account['prenom']}');
        debugPrint('Rôle: ${account['role']}');
        
        // Simuler une connexion réussie
        _isLoggedIn = true;
        _userId = '999'; // ID spécial pour admin
        _currentUser = account['email'];
        _userNom = account['nom'];
        _userPrenom = account['prenom'];
        _userRole = account['role'];

        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, _userId!);
        await prefs.setString(_keyUserEmail, _currentUser!);
        await prefs.setString(_keyUserNom, _userNom!);
        await prefs.setString(_keyUserPrenom, _userPrenom!);
        await prefs.setString(_keyUserRole, _userRole!);

        debugPrint('✅ CONNEXION ADMIN RÉUSSIE');
        debugPrint('═══════════════════════════════════════');
        
        return true;
      }
    }
    
    debugPrint('⚠️ Ce n\'est pas un compte admin prédéfini, tentative avec l\'API...');
    
    // Si ce n'est pas un compte admin prédéfini, faire la vraie requête API
    final client = http.Client();
    
    try {
      // Utiliser ApiConfig pour gérer automatiquement l'URL selon la plateforme
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
      
      debugPrint('URL API: $url');
      
      final response = await client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('📥 RÉPONSE API REÇUE');
      debugPrint('Status Code: ${response.statusCode}');
      
      String responseBody = utf8.decode(response.bodyBytes);
      debugPrint('Body (premier 200 chars): ${responseBody.length > 200 ? responseBody.substring(0, 200) + '...' : responseBody}');
      
      // Vérifier si la réponse est vide
      if (responseBody.isEmpty) {
        _lastError = 'Réponse vide du serveur';
        debugPrint('❌ Réponse vide');
        return false;
      }
      
      dynamic data;
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        _lastError = 'Réponse invalide du serveur. Format JSON incorrect.';
        debugPrint('❌ Erreur de décodage JSON: $e');
        return false;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['data']['user'];
        
        debugPrint('✅ CONNEXION API RÉUSSIE');
        debugPrint('User ID: ${user['id']}');
        debugPrint('Email: ${user['email']}');
        debugPrint('Rôle: ${user['role'] ?? 'etudiant'}');
        
        _isLoggedIn = true;
        _userId = user['id'].toString();
        _currentUser = user['email'];
        _userNom = user['nom'];
        _userPrenom = user['prenom'];
        _userRole = user['role'] ?? 'etudiant';

        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, _userId!);
        await prefs.setString(_keyUserEmail, _currentUser!);
        await prefs.setString(_keyUserNom, _userNom!);
        await prefs.setString(_keyUserPrenom, _userPrenom!);
        await prefs.setString(_keyUserRole, _userRole!);

        return true;
      } else {
        _lastError = data['message'] ?? 'Email ou mot de passe incorrect';
        debugPrint('❌ Erreur de connexion API: $_lastError');
        return false;
      }
    } catch (e) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ ERREUR LORS DE LA CONNEXION API');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Message: $e');
      debugPrint('═══════════════════════════════════════');
      
      String errorString = e.toString();
      
      if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
        _lastError = 'Délai d\'attente dépassé';
      } else if (errorString.contains('SocketException') || 
                 errorString.contains('Failed host lookup')) {
        _lastError = 'Impossible de se connecter au serveur';
      } else if (errorString.contains('CORS') || errorString.contains('Access-Control')) {
        _lastError = 'Erreur CORS - Vérifiez les en-têtes du serveur';
      } else {
        _lastError = 'Erreur: ${e.toString()}';
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
    
    // Vérifier si l'email est un compte admin prédéfini
    for (var account in [
      'admin@eneam.bj', 'superadmin@eneam.bj', 'administrateur@eneam.bj',
      'test@admin.bj', 'directeur@eneam.bj'
    ]) {
      if (email.toLowerCase().trim() == account.toLowerCase()) {
        _lastError = 'Cet email est réservé pour les comptes administrateurs';
        return false;
      }
    }
    
    try {
      // Utiliser ApiConfig pour gérer automatiquement l'URL selon la plateforme
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      
      debugPrint('Tentative d\'inscription vers: $url');
      
      final client = http.Client();
      try {
        final response = await client.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'nom': nom,
            'prenom': prenom,
            'email': email,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 30));
        
        debugPrint('Code de statut: ${response.statusCode}');

        String responseBody = utf8.decode(response.bodyBytes);
        dynamic data;
        
        try {
          data = jsonDecode(responseBody);
        } catch (e) {
          _lastError = 'Réponse invalide du serveur';
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
          _userRole = user['role'] ?? 'etudiant';

          // Sauvegarder dans SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_keyIsLoggedIn, true);
          await prefs.setString(_keyUserId, _userId!);
          await prefs.setString(_keyUserEmail, _currentUser!);
          await prefs.setString(_keyUserNom, _userNom!);
          await prefs.setString(_keyUserPrenom, _userPrenom!);
          await prefs.setString(_keyUserRole, _userRole!);

          return true;
        } else {
          _lastError = data['message'] ?? 'Erreur lors de l\'inscription';
          debugPrint('Erreur d\'inscription: $_lastError');
          return false;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ ERREUR LORS DE L\'INSCRIPTION');
      debugPrint('Message: $e');
      debugPrint('═══════════════════════════════════════');
      
      _lastError = 'Erreur lors de la connexion au serveur';
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Optionnel: appeler l'endpoint de déconnexion côté serveur
      // final url = Uri.parse('http://localhost/api/auth/logout.php');
      // await http.post(url, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    } finally {
      _isLoggedIn = false;
      _currentUser = null;
      _userNom = null;
      _userPrenom = null;
      _userId = null;
      _userRole = 'etudiant';
      _lastError = null;

      // Supprimer de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserNom);
      await prefs.remove(_keyUserPrenom);
      await prefs.remove(_keyUserRole);
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get userNom => _userNom;
  String? get userPrenom => _userPrenom;
  String? get userId => _userId;
  String get userRole => _userRole ?? 'etudiant';
  bool get isAdmin => _userRole == 'admin';
}