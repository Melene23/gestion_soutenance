-- Migration pour ajouter le champ 'role' à la table utilisateurs
-- Exécutez ce script dans votre base de données MySQL

USE gestion_soutenances;

-- Ajouter la colonne 'role' si elle n'existe pas déjà
ALTER TABLE utilisateurs 
ADD COLUMN IF NOT EXISTS role ENUM('admin', 'etudiant') DEFAULT 'etudiant' AFTER password;

-- Mettre à jour l'admin existant pour avoir le role 'admin'
UPDATE utilisateurs 
SET role = 'admin' 
WHERE email = 'admin@gestsoutenance.com';

-- Créer un index sur le role pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_role ON utilisateurs(role);

