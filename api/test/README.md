# Scripts de Test - API Gestion des Soutenances

Ce dossier contient des scripts de test pour vérifier que votre configuration API fonctionne correctement.

## 📋 Prérequis

- Serveur web (Apache/XAMPP) démarré
- PHP 7.4 ou supérieur
- Extension MySQLi activée
- Base de données MySQL configurée

## 🚀 Utilisation

### Option 1: Interface Web (Recommandé)

1. Ouvrez votre navigateur
2. Accédez à: `http://localhost/gestsoutenance/api/test/index.php`
3. Cliquez sur les liens pour exécuter les différents tests

### Option 2: Accès Direct

Vous pouvez accéder directement aux scripts de test:

- **Test de Configuration Générale**: `http://localhost/gestsoutenance/api/test/test_config.php`
- **Test de Base de Données**: `http://localhost/gestsoutenance/api/test/test_database.php`
- **Test d'Inscription**: `http://localhost/gestsoutenance/api/test/test_register.php`
- **Test de l'Endpoint d'Inscription**: `http://localhost/gestsoutenance/api/test/test_register_endpoint.php`

## 📊 Tests Disponibles

### 1. Test de Configuration Générale (`test_config.php`)

Vérifie:
- ✅ Version PHP et extensions requises
- ✅ Existence des fichiers de configuration
- ✅ Permissions des dossiers
- ✅ Configuration de la base de données
- ✅ En-têtes CORS

### 2. Test de Base de Données (`test_database.php`)

Vérifie:
- ✅ Connexion MySQL
- ✅ Existence de la base de données
- ✅ Structure de la table `utilisateurs`
- ✅ Nombre d'utilisateurs existants
- ✅ Fonctionnement des requêtes préparées

### 3. Test d'Inscription (`test_register.php`)

Vérifie:
- ✅ Existence du fichier `register.php`
- ✅ Connexion à la base de données
- ✅ Structure de la table utilisateurs
- ✅ Validation des données
- ✅ Validation de l'email
- ✅ Hashage des mots de passe

### 4. Test de l'Endpoint d'Inscription (`test_register_endpoint.php`)

Vérifie:
- ✅ Accessibilité de l'endpoint
- ✅ Inscription avec données valides
- ✅ Rejet des données invalides
- ✅ Détection d'email dupliqué
- ✅ Validation de la longueur du mot de passe

## 🔍 Interprétation des Résultats

Les résultats sont au format JSON avec les statuts suivants:

- **success** ✅: Le test a réussi
- **error** ❌: Le test a échoué (action requise)
- **warning** ⚠️: Le test a des problèmes mineurs

### Exemple de Résultat

```json
{
  "timestamp": "2024-01-15 10:30:00",
  "tests": {
    "connection": {
      "name": "Connexion MySQL",
      "status": "success",
      "message": "Connexion réussie"
    }
  },
  "summary": {
    "total": 5,
    "success": 5,
    "errors": 0,
    "all_passed": true
  }
}
```

## 🐛 Résolution des Problèmes

### Erreur: "Impossible de se connecter à la base de données"

1. Vérifiez que MySQL est démarré
2. Vérifiez les identifiants dans `api/config/database.php`
3. Vérifiez que la base de données `gestion_soutenances` existe
4. Exécutez le script `database/schema.sql` pour créer la base

### Erreur: "La table utilisateurs n'existe pas"

1. Exécutez le script SQL: `database/schema.sql`
2. Vérifiez que vous êtes connecté à la bonne base de données

### Erreur: "Extension mysqli non chargée"

1. Ouvrez `php.ini`
2. Décommentez la ligne: `extension=mysqli`
3. Redémarrez Apache

### Erreur: "Endpoint non accessible"

1. Vérifiez que Apache est démarré
2. Vérifiez l'URL dans `gestsoutenance/lib/core/constants/api_config.dart`
3. Vérifiez que les fichiers sont dans le bon dossier (`htdocs/gestsoutenance/api/`)

## 📝 Notes

- Les tests créent parfois des utilisateurs de test dans la base de données
- Vous pouvez supprimer ces utilisateurs de test manuellement si nécessaire
- Les tests utilisent des emails uniques basés sur le timestamp pour éviter les conflits

## 🔒 Sécurité

⚠️ **Important**: Ces scripts de test ne doivent **PAS** être déployés en production. Ils exposent des informations sensibles sur votre configuration.

Pour la production:
- Supprimez le dossier `api/test/`
- Ou ajoutez une protection par mot de passe
- Ou bloquez l'accès via `.htaccess`









