<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tests de Configuration - API Gestion Soutenances</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 1.1em;
        }
        
        .content {
            padding: 30px;
        }
        
        .test-section {
            margin-bottom: 30px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
        }
        
        .test-header {
            background: #f5f5f5;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .test-header:hover {
            background: #eeeeee;
        }
        
        .test-header h2 {
            color: #333;
            font-size: 1.3em;
        }
        
        .test-link {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
            transition: background 0.3s;
        }
        
        .test-link:hover {
            background: #5568d3;
        }
        
        .test-description {
            padding: 20px;
            background: #fafafa;
            color: #666;
            line-height: 1.6;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
            margin-left: 10px;
        }
        
        .status-success {
            background: #4caf50;
            color: white;
        }
        
        .status-error {
            background: #f44336;
            color: white;
        }
        
        .status-warning {
            background: #ff9800;
            color: white;
        }
        
        .instructions {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 20px;
            margin-bottom: 30px;
            border-radius: 5px;
        }
        
        .instructions h3 {
            color: #1976d2;
            margin-bottom: 10px;
        }
        
        .instructions ol {
            margin-left: 20px;
        }
        
        .instructions li {
            margin: 10px 0;
            line-height: 1.6;
        }
        
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            background: #f5f5f5;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧪 Tests de Configuration</h1>
            <p>API Gestion des Soutenances</p>
        </div>
        
        <div class="content">
            <div class="instructions">
                <h3>📋 Instructions</h3>
                <ol>
                    <li>Cliquez sur les liens ci-dessous pour exécuter les différents tests</li>
                    <li>Les résultats s'afficheront au format JSON</li>
                    <li>Vérifiez que tous les tests passent (status: "success")</li>
                    <li>En cas d'erreur, consultez les détails pour identifier le problème</li>
                </ol>
            </div>
            
            <div class="test-section">
                <div class="test-header">
                    <div>
                        <h2>1. Test de Configuration Générale</h2>
                        <span class="status-badge status-success">Recommandé</span>
                    </div>
                    <a href="test_config.php" class="test-link" target="_blank">Exécuter le test</a>
                </div>
                <div class="test-description">
                    Vérifie la configuration PHP, les extensions requises, les fichiers de configuration, 
                    les permissions et les chemins. C'est le premier test à exécuter.
                </div>
            </div>
            
            <div class="test-section">
                <div class="test-header">
                    <div>
                        <h2>2. Test de Connexion à la Base de Données</h2>
                        <span class="status-badge status-success">Recommandé</span>
                    </div>
                    <a href="test_database.php" class="test-link" target="_blank">Exécuter le test</a>
                </div>
                <div class="test-description">
                    Vérifie la connexion MySQL, l'existence de la base de données, 
                    la structure de la table utilisateurs et le nombre d'utilisateurs existants.
                </div>
            </div>
            
            <div class="test-section">
                <div class="test-header">
                    <div>
                        <h2>3. Test de l'Endpoint d'Inscription</h2>
                        <span class="status-badge status-success">Recommandé</span>
                    </div>
                    <a href="test_register.php" class="test-link" target="_blank">Exécuter le test</a>
                </div>
                <div class="test-description">
                    Vérifie que l'endpoint d'inscription est correctement configuré, 
                    que la validation fonctionne, et que les requêtes SQL peuvent être exécutées.
                </div>
            </div>
            
            <div class="test-section">
                <div class="test-header">
                    <div>
                        <h2>4. Test HTTP de l'Endpoint d'Inscription</h2>
                        <span class="status-badge status-success">Recommandé</span>
                    </div>
                    <a href="test_register_endpoint.php" class="test-link" target="_blank">Exécuter le test</a>
                </div>
                <div class="test-description">
                    Teste l'endpoint d'inscription avec de vraies requêtes HTTP. Vérifie l'inscription réussie, 
                    la validation des données, la détection d'email dupliqué et la validation du mot de passe.
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>© 2024 - API Gestion des Soutenances</p>
            <p>En cas de problème, vérifiez les logs d'erreur PHP et la configuration de votre serveur.</p>
        </div>
    </div>
</body>
</html>

