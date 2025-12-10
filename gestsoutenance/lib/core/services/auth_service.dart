// Service d'authentification (pour extension future avec PHP MySQL)
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUser;
  String? _userNom;
  String? _userPrenom;

  Future<bool> login(String email, String password) async {
    // Simuler une authentification
    // TODO: Remplacer par un appel API PHP MySQL
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _currentUser = email;
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    // Simuler une inscription
    // TODO: Remplacer par un appel API PHP MySQL
    await Future.delayed(const Duration(seconds: 1));
    
    if (nom.isNotEmpty && prenom.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _currentUser = email;
      _userNom = nom;
      _userPrenom = prenom;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
    _currentUser = null;
    _userNom = null;
    _userPrenom = null;
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get userNom => _userNom;
  String? get userPrenom => _userPrenom;

  String? get lastError => null;

  Future<void> init() async {}
}