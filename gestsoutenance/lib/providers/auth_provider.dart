import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String? _currentUser;
  String? _userNom;
  String? _userPrenom;
  bool _isInitialized = false;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Attendre que AuthService soit initialisé
    await _authService.init();
    _loadAuthState();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadAuthState() {
    _isLoggedIn = _authService.isLoggedIn;
    _currentUser = _authService.currentUser;
    _userNom = _authService.userNom;
    _userPrenom = _authService.userPrenom;
  }

  bool get isInitialized => _isInitialized;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get userNom => _userNom;
  String? get userPrenom => _userPrenom;
  String? get lastError => _authService.lastError;

  Future<bool> login(String email, String password) async {
    try {
      final success = await _authService.login(email, password);
      if (success) {
        _isLoggedIn = true;
        _currentUser = _authService.currentUser;
        _userNom = _authService.userNom;
        _userPrenom = _authService.userPrenom;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      return false;
    }
  }

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    try {
      final success = await _authService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      );
      if (success) {
        _isLoggedIn = true;
        _currentUser = _authService.currentUser;
        _userNom = _authService.userNom;
        _userPrenom = _authService.userPrenom;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Erreur d\'inscription: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    _userNom = null;
    _userPrenom = null;
    notifyListeners();
  }
}

