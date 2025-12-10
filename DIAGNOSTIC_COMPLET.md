# Diagnostic Complet - Problème de Connexion Flutter Web

## ✅ Ce qui fonctionne
- L'API répond correctement depuis PowerShell
- Les données sont enregistrées en base de données
- Les en-têtes CORS sont configurés dans les fichiers PHP

## ❌ Problème
Flutter Web ne peut pas se connecter à l'API (erreur "Impossible de se connecter au serveur")

## 🔍 Étapes de Diagnostic

### 1. Testez CORS directement dans le navigateur
Ouvrez : **http://localhost/gestsoutenance/test_cors.html**
- Cliquez sur "Tester l'inscription"
- Si ça fonctionne : le problème vient de Flutter Web
- Si ça ne fonctionne pas : le problème vient de l'API/CORS

### 2. Ouvrez la Console du Navigateur (F12)
Dans votre application Flutter :
1. Appuyez sur **F12** pour ouvrir les outils de développement
2. Allez dans l'onglet **Console**
3. Regardez les messages de debug (ils commencent par "Tentative de...")
4. Notez les erreurs affichées

### 3. Vérifiez l'onglet Network
1. Dans les outils de développement (F12)
2. Allez dans l'onglet **Network**
3. Essayez de vous connecter/inscrire
4. Cherchez la requête vers `register.php` ou `login.php`
5. Cliquez dessus et regardez :
   - **Status** : Quel code HTTP ?
   - **Headers** : Les en-têtes CORS sont-ils présents ?
   - **Response** : Quelle est la réponse du serveur ?

### 4. Vérifications XAMPP
- ✅ Apache est démarré (bouton vert)
- ✅ MySQL est démarré (bouton vert)
- ✅ Le port 80 n'est pas utilisé par un autre service

### 5. Redémarrez Apache
1. Arrêtez Apache dans XAMPP
2. Attendez 5 secondes
3. Redémarrez Apache

### 6. Videz le cache du navigateur
1. Appuyez sur **Ctrl + Shift + Delete**
2. Cochez "Images et fichiers en cache"
3. Cliquez sur "Effacer les données"
4. Rechargez l'application Flutter

### 7. Testez avec un autre navigateur
Essayez Chrome, Firefox, ou Edge pour voir si le problème est spécifique à un navigateur.

## 🔧 Solutions Possibles

### Solution 1 : Utiliser 127.0.0.1 au lieu de localhost
Modifiez `api_config.dart` :
```dart
static const String baseUrl = 'http://127.0.0.1/gestsoutenance/api/';
```

### Solution 2 : Vérifier le port Apache
Si Apache utilise un autre port (ex: 8080), modifiez l'URL :
```dart
static const String baseUrl = 'http://localhost:8080/gestsoutenance/api/';
```

### Solution 3 : Désactiver temporairement le pare-feu
1. Ouvrez "Pare-feu Windows Defender"
2. Désactivez temporairement
3. Testez
4. Réactivez après

### Solution 4 : Vérifier les modules Apache
Assurez-vous que ces modules sont activés dans Apache :
- mod_rewrite
- mod_headers

Pour vérifier :
1. Ouvrez `C:\xampp\apache\conf\httpd.conf`
2. Cherchez `LoadModule rewrite_module`
3. Vérifiez qu'il n'y a pas de `#` devant

## 📝 Informations à me fournir

Si le problème persiste, fournissez-moi :
1. Les messages de la console du navigateur (F12 > Console)
2. Les détails de la requête HTTP (F12 > Network > cliquez sur la requête)
3. Le code de statut HTTP
4. Les en-têtes de réponse
5. Le message d'erreur exact dans Flutter

