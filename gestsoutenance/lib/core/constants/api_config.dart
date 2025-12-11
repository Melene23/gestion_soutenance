import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApiConfig {
  // URLs de base
  static const String _baseUrlWeb = 'http://localhost/api/';
  static const String _baseUrlAndroid = 'http://10.0.2.2/api/';
  static const String _baseUrlIOS = 'http://localhost/api/';

  // Getter pour l'URL de base selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return _baseUrlWeb;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return _baseUrlAndroid;
        case TargetPlatform.iOS:
          return _baseUrlIOS;
        default:
          return _baseUrlWeb;
      }
    }
  }

  // Getter pour l'URL effective (alias de baseUrl)
  static String get effectiveBaseUrl => baseUrl;

  // Endpoints d'authentification
  static String get loginEndpoint => 'auth/login.php';
  static String get registerEndpoint => 'auth/register.php';

  // Endpoints de données
  static String get etudiantsEndpoint => 'etudiants/list.php';
  static String get memoiresEndpoint => 'memoires/list.php';
  static String get sallesEndpoint => 'salles/list.php';
  static String get soutenancesEndpoint => 'soutenances/list.php';        
  
  // CORRECTION: Endpoints de métadonnées
  static String get metadataEndpoint => 'metadata/list.php';  // Changé de 'stats.php' à 'list.php'
  
  // NOUVEAUX: Endpoints pour filières et niveaux
  static String get filieresEndpoint => 'filieres/list.php';
  static String get niveauxEndpoint => 'niveaux/list.php';

  // Headers communs
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Timeout
  static Duration get timeout => const Duration(seconds: 30);
}
