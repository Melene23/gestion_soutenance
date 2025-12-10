import 'package:flutter/foundation.dart';

// Configuration de l'API avec détection automatique de la plateforme
class ApiConfig {
  // URLs de base selon la plateforme
  static const String _baseUrlWeb = 'http://127.0.0.1/gestsoutenance/api/';
  static const String _baseUrlAndroid = 'http://10.0.2.2/gestsoutenance/api/';
  static const String _baseUrlIOS = 'http://localhost/gestsoutenance/api/';
  
  // Détection automatique de la plateforme et retour de l'URL appropriée
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web
      debugPrint('🌐 Plateforme détectée: WEB - URL: $_baseUrlWeb');
      return _baseUrlWeb;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android (Emulator ou appareil physique)
      debugPrint('🤖 Plateforme détectée: ANDROID - URL: $_baseUrlAndroid');
      return _baseUrlAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS Simulator
      debugPrint('🍎 Plateforme détectée: iOS - URL: $_baseUrlIOS');
      return _baseUrlIOS;
    } else {
      // Par défaut (Windows, Linux, macOS)
      debugPrint('💻 Plateforme détectée: ${defaultTargetPlatform} - URL: $_baseUrlWeb');
      return _baseUrlWeb;
    }
  }
  
  // Pour forcer une URL spécifique (utile pour le débogage)
  static String? _forcedBaseUrl;
  static void setBaseUrl(String? url) {
    _forcedBaseUrl = url;
    if (url != null) {
      debugPrint('🔧 URL forcée: $url');
    } else {
      debugPrint('🔧 URL forcée désactivée, utilisation de la détection automatique');
    }
  }
  
  // Getter qui utilise l'URL forcée si définie
  static String get effectiveBaseUrl => _forcedBaseUrl ?? baseUrl;
  
  // Endpoints
  static const String loginEndpoint = 'auth/login.php';
  static const String registerEndpoint = 'auth/register.php';
  static const String logoutEndpoint = 'auth/logout.php';
  
  // Endpoints CRUD
  static const String etudiantsEndpoint = 'etudiants/index.php';
  static const String memoiresEndpoint = 'memoires/index.php';
  static const String sallesEndpoint = 'salles/index.php';
  static const String soutenancesEndpoint = 'soutenances/index.php';
  static const String metadataEndpoint = 'metadata/index.php';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Méthode pour tester la connexion
  static String get testUrl => '${effectiveBaseUrl}test.php';
}

