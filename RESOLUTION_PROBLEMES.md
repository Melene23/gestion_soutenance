# 🔧 Résolution des Problèmes - Icônes et Inscription

## Problème 1 : Les icônes ne s'affichent pas

### Solution 1 : Nettoyer et reconstruire l'application

Les icônes Material sont incluses par défaut dans Flutter, mais parfois le cache peut causer des problèmes.

```bash
cd gestsoutenance
flutter clean
flutter pub get
flutter run
```

### Solution 2 : Vérifier que MaterialApp est utilisé

Assurez-vous que votre application utilise `MaterialApp` (pas `CupertinoApp`). Vérifiez dans `lib/main.dart` :

```dart
MaterialApp(
  title: 'Gestion Soutenances',
  theme: _buildAppTheme(),
  // ...
)
```

### Solution 3 : Vérifier le thème

Si les icônes sont blanches sur fond blanc, elles peuvent être invisibles. Vérifiez les couleurs dans votre thème.

## Problème 2 : Impossible de s'inscrire

### Étape 1 : Vérifier que l'application a été reconstruite

**IMPORTANT** : Après avoir ajouté `network_security_config.xml`, vous DEVEZ reconstruire l'application :

```bash
cd gestsoutenance
flutter clean
flutter pub get
flutter run
```

### Étape 2 : Vérifier que Apache est démarré

1. Ouvrez XAMPP Control Panel
2. Vérifiez que **Apache** est démarré (bouton vert)
3. Si ce n'est pas le cas, cliquez sur "Start"

### Étape 3 : Vérifier que MySQL est démarré

1. Dans XAMPP Control Panel
2. Vérifiez que **MySQL** est démarré
3. Si ce n'est pas le cas, cliquez sur "Start"

### Étape 4 : Vérifier la configuration de l'API

Vérifiez que l'URL dans `gestsoutenance/lib/core/constants/api_config.dart` est correcte :

```dart
static const String baseUrl = 'http://10.0.2.2/gestsoutenance/api/';
```

**Pour Android Emulator** : `http://10.0.2.2/gestsoutenance/api/`
**Pour appareil physique** : Remplacez par votre IP locale (ex: `http://192.168.1.100/gestsoutenance/api/`)

### Étape 5 : Tester l'API directement

Ouvrez votre navigateur et testez :
```
http://localhost/gestsoutenance/api/test/test_register_endpoint.php
```

Si cela fonctionne dans le navigateur mais pas dans l'app, c'est un problème de configuration Android.

### Étape 6 : Vérifier les fichiers de configuration Android

Assurez-vous que ces fichiers existent :

1. **`gestsoutenance/android/app/src/main/res/xml/network_security_config.xml`**
   - Doit autoriser le trafic HTTP vers `10.0.2.2`

2. **`gestsoutenance/android/app/src/main/AndroidManifest.xml`**
   - Doit contenir :
     ```xml
     android:usesCleartextTraffic="true"
     android:networkSecurityConfig="@xml/network_security_config"
     ```

### Étape 7 : Vérifier les permissions

Dans `AndroidManifest.xml`, assurez-vous d'avoir :
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 🔍 Diagnostic

### Vérifier les logs Flutter

Lancez l'application avec les logs :
```bash
flutter run -v
```

Cherchez les erreurs de connexion dans les logs.

### Tester la connexion depuis l'émulateur

1. Ouvrez un navigateur dans l'émulateur Android
2. Allez à : `http://10.0.2.2/gestsoutenance/api/test/test_config.php`
3. Si cela ne fonctionne pas, Apache n'est pas accessible depuis l'émulateur

## ✅ Checklist de vérification

- [ ] Application reconstruite après modifications Android (`flutter clean && flutter run`)
- [ ] Apache démarré dans XAMPP
- [ ] MySQL démarré dans XAMPP
- [ ] Base de données `gestion_soutenances` existe
- [ ] Table `utilisateurs` existe (importez `database/schema.sql`)
- [ ] Fichier `network_security_config.xml` existe
- [ ] `AndroidManifest.xml` contient les bonnes configurations
- [ ] URL dans `api_config.dart` est correcte
- [ ] Permissions Internet dans `AndroidManifest.xml`

## 🚀 Solution rapide

Si rien ne fonctionne, exécutez ces commandes dans l'ordre :

```bash
# 1. Nettoyer le projet
cd gestsoutenance
flutter clean

# 2. Récupérer les dépendances
flutter pub get

# 3. Vérifier la configuration
flutter doctor

# 4. Reconstruire et lancer
flutter run
```

## 📱 Pour un appareil physique

Si vous testez sur un appareil physique (pas un émulateur) :

1. Trouvez votre IP locale :
   ```bash
   ipconfig  # Windows
   # Cherchez "Adresse IPv4" (ex: 192.168.1.100)
   ```

2. Modifiez `api_config.dart` :
   ```dart
   static const String baseUrl = 'http://192.168.1.100/gestsoutenance/api/';
   ```

3. Assurez-vous que votre téléphone et votre ordinateur sont sur le même réseau WiFi

4. Désactivez le pare-feu Windows temporairement pour tester

## 🆘 Si le problème persiste

1. Vérifiez les logs d'erreur Flutter
2. Vérifiez les logs Apache dans XAMPP
3. Testez l'API directement dans le navigateur
4. Vérifiez que tous les fichiers sont au bon endroit


