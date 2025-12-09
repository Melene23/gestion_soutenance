// Configuration de l'API
class ApiConfig {
  // Modifiez cette URL selon votre configuration :
  // 
  // Pour Android Emulator (recommandé pour le développement) :
  // static const String baseUrl = 'http://10.0.2.2/api/';
  //
  // Pour iOS Simulator :
  // static const String baseUrl = 'http://localhost/api/';
  //
  // Pour un appareil physique (remplacez par votre IP locale) :
  // static const String baseUrl = 'http://192.168.1.100/api/';
  //
  // Pour un serveur distant :
  // static const String baseUrl = 'https://votre-domaine.com/api/';
  
  // Configuration par défaut pour Android Emulator
  // Les fichiers API sont dans C:\xampp\htdocs\gestsoutenance\api\
  static const String baseUrl = 'http://10.0.2.2/gestsoutenance/api/';
  
  
  // Endpoints
  static const String loginEndpoint = 'auth/login.php';
  static const String registerEndpoint = 'auth/register.php';
  static const String logoutEndpoint = 'auth/logout.php';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}

