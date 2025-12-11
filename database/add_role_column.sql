-- Script pour ajouter le champ 'role' à la table utilisateurs
-- Exécutez ce script dans phpMyAdmin ou via MySQL
-- IMPORTANT: Exécutez ce script avant d'utiliser l'application avec les rôles

USE gestion_soutenances;

-- Vérifier si la colonne existe déjà, sinon l'ajouter
SET @dbname = DATABASE();
SET @tablename = 'utilisateurs';
SET @columnname = 'role';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' ENUM(\'admin\', \'etudiant\') DEFAULT \'etudiant\' AFTER password')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Mettre à jour le compte admin existant
UPDATE utilisateurs 
SET role = 'admin' 
WHERE email = 'admin@gestsoutenance.com' OR email LIKE '%admin%';

-- Mettre tous les autres utilisateurs en 'etudiant' par défaut (si NULL)
UPDATE utilisateurs 
SET role = 'etudiant' 
WHERE role IS NULL;

-- Afficher un message de confirmation
SELECT 'Colonne role ajoutée avec succès!' as message;
