# Guide de Dépannage - Connexion API

## Problème : "Impossible de se connecter au serveur"

### ✅ Vérifications à faire :

#### 1. Vérifier que XAMPP est démarré
- Ouvrez le panneau de contrôle XAMPP
- Vérifiez que **Apache** est démarré (bouton vert)
- Vérifiez que **MySQL** est démarré (bouton vert)

#### 2. Tester l'API directement dans le navigateur
Ouvrez votre navigateur et allez à :
```
http://localhost/gestsoutenance/api/test.php
```

Vous devriez voir une réponse JSON comme :
```json
{
    "success": true,
    "message": "API fonctionnelle !",
    "data": {
        "server": "...",
        "php_version": "...",
        "database": {
            "status": "connected"
        }
    }
}
```

Si vous voyez une erreur 404 :
- Les fichiers API ne sont pas au bon endroit
- Vérifiez que les fichiers sont dans : `C:\xampp\htdocs\gestsoutenance\api\`

#### 3. Vérifier la structure des dossiers
Les fichiers doivent être organisés ainsi :
```
C:\xampp\htdocs\gestsoutenance\
  └── api\
      ├── auth\
      │   ├── login.php
      │   └── register.php
      ├── config\
      │   └── database.php
      ├── etudiants\
      │   └── index.php
      ├── memoires\
      │   └── index.php
      ├── salles\
      │   └── index.php
      ├── soutenances\
      │   └── index.php
      ├── metadata\
      │   └── index.php
      ├── test.php
      └── .htaccess
```

#### 4. Vérifier les permissions Apache
- Assurez-vous que le module `mod_rewrite` est activé dans Apache
- Vérifiez que le module `mod_headers` est activé pour CORS

#### 5. Vérifier la configuration de la base de données
Ouvrez `C:\xampp\htdocs\gestsoutenance\api\config\database.php` et vérifiez :
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // Votre mot de passe MySQL si vous en avez un
define('DB_NAME', 'gestion_soutenances');
```

#### 6. Vérifier que la base de données existe
1. Ouvrez phpMyAdmin : http://localhost/phpmyadmin
2. Vérifiez que la base de données `gestion_soutenances` existe
3. Si elle n'existe pas, importez le fichier `database/schema.sql`

#### 7. Problèmes de CORS (Cross-Origin Resource Sharing)
Si vous voyez des erreurs CORS dans la console du navigateur :
- Vérifiez que le fichier `.htaccess` existe dans le dossier `api`
- Vérifiez que les en-têtes CORS sont bien configurés

#### 8. Redémarrer Apache
1. Arrêtez Apache dans XAMPP
2. Attendez 5 secondes
3. Redémarrez Apache

#### 9. Vérifier les logs d'erreur
Consultez les logs Apache :
- `C:\xampp\apache\logs\error.log`
- Cherchez les erreurs récentes

#### 10. Tester avec curl (optionnel)
Ouvrez PowerShell et testez :
```powershell
curl -X POST http://localhost/gestsoutenance/api/auth/login.php -H "Content-Type: application/json" -d '{\"email\":\"test@test.com\",\"password\":\"test\"}'
```

## Solutions rapides

### Solution 1 : Copier les fichiers API
Si les fichiers ne sont pas au bon endroit, exécutez le script :
```powershell
.\copier_api.ps1
```

### Solution 2 : Vérifier le port Apache
Par défaut, Apache utilise le port 80. Si un autre service utilise ce port :
1. Ouvrez XAMPP Control Panel
2. Cliquez sur "Config" à côté d'Apache
3. Sélectionnez "httpd.conf"
4. Changez `Listen 80` en `Listen 8080`
5. Mettez à jour l'URL dans `api_config.dart` : `http://localhost:8080/gestsoutenance/api/`

### Solution 3 : Désactiver le pare-feu Windows (temporairement)
Parfois, le pare-feu Windows bloque les connexions locales :
1. Ouvrez "Pare-feu Windows Defender"
2. Désactivez temporairement le pare-feu
3. Testez à nouveau
4. Réactivez le pare-feu après

## Test final

Une fois toutes les vérifications faites, testez dans votre application Flutter :
1. Lancez l'application : `flutter run -d chrome`
2. Essayez de vous connecter
3. Si ça ne fonctionne toujours pas, ouvrez la console du navigateur (F12)
4. Regardez l'onglet "Network" pour voir les requêtes HTTP
5. Vérifiez les erreurs dans l'onglet "Console"

