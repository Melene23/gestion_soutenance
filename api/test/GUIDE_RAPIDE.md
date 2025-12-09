# 🚀 Guide Rapide - Tests de Configuration

## Étape 1: Vérifier que votre serveur est démarré

1. Ouvrez XAMPP Control Panel
2. Démarrez **Apache**
3. Démarrez **MySQL**

## Étape 2: Accéder à la page de tests

Ouvrez votre navigateur et allez à:

```
http://localhost/gestsoutenance/api/test/index.php
```

**OU** si vos fichiers sont dans un autre dossier:

```
http://localhost/[votre-dossier]/api/test/index.php
```

## Étape 3: Exécuter les tests dans l'ordre

### ✅ Test 1: Configuration Générale
Cliquez sur "Exécuter le test" pour `test_config.php`

**Vérifiez:**
- ✅ Toutes les extensions PHP sont installées
- ✅ Tous les fichiers de configuration existent
- ✅ Les permissions sont correctes

### ✅ Test 2: Base de Données
Cliquez sur "Exécuter le test" pour `test_database.php`

**Vérifiez:**
- ✅ La connexion MySQL fonctionne
- ✅ La base de données `gestion_soutenances` existe
- ✅ La table `utilisateurs` existe avec toutes les colonnes

**Si la table n'existe pas:**
1. Ouvrez phpMyAdmin: `http://localhost/phpmyadmin`
2. Sélectionnez la base `gestion_soutenances`
3. Allez dans l'onglet "Importer"
4. Sélectionnez le fichier: `database/schema.sql`
5. Cliquez sur "Exécuter"

### ✅ Test 3: Endpoint d'Inscription
Cliquez sur "Exécuter le test" pour `test_register.php`

**Vérifiez:**
- ✅ Le fichier `register.php` existe
- ✅ La validation fonctionne
- ✅ Le hashage des mots de passe fonctionne

### ✅ Test 4: Test HTTP de l'Endpoint
Cliquez sur "Exécuter le test" pour `test_register_endpoint.php`

**Vérifiez:**
- ✅ L'endpoint est accessible
- ✅ L'inscription fonctionne avec des données valides
- ✅ Les données invalides sont rejetées
- ✅ Les emails dupliqués sont détectés

## 🔧 Problèmes Courants

### ❌ "Impossible de se connecter à la base de données"

**Solution:**
1. Vérifiez que MySQL est démarré dans XAMPP
2. Ouvrez `api/config/database.php`
3. Vérifiez les paramètres:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'root');
   define('DB_PASS', ''); // Votre mot de passe MySQL
   define('DB_NAME', 'gestion_soutenances');
   ```

### ❌ "La table utilisateurs n'existe pas"

**Solution:**
1. Ouvrez phpMyAdmin
2. Créez la base de données `gestion_soutenances` si elle n'existe pas
3. Importez le fichier `database/schema.sql`

### ❌ "Endpoint non accessible"

**Solution:**
1. Vérifiez que vos fichiers API sont dans `C:\xampp\htdocs\gestsoutenance\api\`
2. Vérifiez l'URL dans `gestsoutenance/lib/core/constants/api_config.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2/gestsoutenance/api/';
   ```
3. Si vos fichiers sont ailleurs, ajustez l'URL

### ❌ "Extension mysqli non chargée"

**Solution:**
1. Ouvrez `C:\xampp\php\php.ini`
2. Cherchez la ligne: `;extension=mysqli`
3. Enlevez le `;` pour avoir: `extension=mysqli`
4. Redémarrez Apache

## ✅ Si tous les tests passent

Si tous les tests affichent `"status": "success"`, votre configuration est correcte!

Vous pouvez maintenant:
1. Tester l'inscription depuis l'application Flutter
2. Vérifier que les messages d'erreur s'affichent correctement
3. Utiliser l'application normalement

## 📱 Test depuis l'application Flutter

1. Assurez-vous que l'URL dans `api_config.dart` correspond à votre configuration
2. Pour Android Emulator: `http://10.0.2.2/gestsoutenance/api/`
3. Pour appareil physique: Remplacez par votre IP locale (ex: `http://192.168.1.100/gestsoutenance/api/`)
4. Testez l'inscription depuis l'application

## 🆘 Besoin d'aide?

Si les tests échouent, notez:
- Le message d'erreur exact
- Le numéro du test qui échoue
- Les détails dans la section "details" du résultat JSON

Ces informations aideront à identifier le problème rapidement.

