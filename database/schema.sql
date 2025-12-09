-- Base de données pour l'application de gestion des soutenances
-- Créez d'abord la base de données dans MySQL

CREATE DATABASE IF NOT EXISTS gestion_soutenances CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE gestion_soutenances;

-- Table des utilisateurs (administrateurs)
CREATE TABLE IF NOT EXISTS utilisateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des étudiants
CREATE TABLE IF NOT EXISTS etudiants (
    id VARCHAR(36) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telephone VARCHAR(20),
    filiere VARCHAR(100) NOT NULL,
    niveau VARCHAR(50) NOT NULL,
    encadreur VARCHAR(100) NOT NULL,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_filiere (filiere)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des mémoires
CREATE TABLE IF NOT EXISTS memoires (
    id VARCHAR(36) PRIMARY KEY,
    etudiant_id VARCHAR(36) NOT NULL,
    theme VARCHAR(255) NOT NULL,
    description TEXT,
    encadreur VARCHAR(100) NOT NULL,
    etat ENUM('enPreparation', 'soumis', 'valide') DEFAULT 'enPreparation',
    date_debut DATETIME NOT NULL,
    date_soutenance DATETIME NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (etudiant_id) REFERENCES etudiants(id) ON DELETE CASCADE,
    INDEX idx_etudiant (etudiant_id),
    INDEX idx_etat (etat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des salles
CREATE TABLE IF NOT EXISTS salles (
    id VARCHAR(36) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    capacite INT NOT NULL,
    equipements TEXT,
    disponible BOOLEAN DEFAULT TRUE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_disponible (disponible)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des soutenances
CREATE TABLE IF NOT EXISTS soutenances (
    id VARCHAR(36) PRIMARY KEY,
    etudiant_id VARCHAR(36) NOT NULL,
    memoire_id VARCHAR(36) NOT NULL,
    salle_id VARCHAR(36) NOT NULL,
    date_soutenance DATETIME NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    jury TEXT,
    notes TEXT,
    statut ENUM('planifiee', 'en_cours', 'terminee', 'annulee') DEFAULT 'planifiee',
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (etudiant_id) REFERENCES etudiants(id) ON DELETE CASCADE,
    FOREIGN KEY (memoire_id) REFERENCES memoires(id) ON DELETE CASCADE,
    FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE RESTRICT,
    INDEX idx_date (date_soutenance),
    INDEX idx_statut (statut),
    INDEX idx_etudiant (etudiant_id),
    INDEX idx_salle (salle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insérer un utilisateur admin par défaut (mot de passe: admin123)
-- Changez ce mot de passe après la première connexion !
INSERT INTO utilisateurs (nom, prenom, email, password) VALUES 
('Admin', 'Système', 'admin@gestsoutenance.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE email=email;

