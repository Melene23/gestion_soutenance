class AppStrings {
  // Titres
  static const String appTitle = 'Gestion des Soutenances';
  static const String etudiants = 'Étudiants';
  static const String memoires = 'Mémoires';
  static const String salles = 'Salles';
  static const String soutenances = 'Soutenances';
  
  // Actions
  static const String ajouter = 'Ajouter';
  static const String modifier = 'Modifier';
  static const String supprimer = 'Supprimer';
  static const String sauvegarder = 'Sauvegarder';
  static const String annuler = 'Annuler';
  static const String filtrer = 'Filtrer';
  static const String rechercher = 'Rechercher...';
  
  // Messages
  static const String confirmationSuppression = 'Êtes-vous sûr de vouloir supprimer ?';
  static const String operationReussie = 'Opération réussie';
  static const String erreur = 'Une erreur est survenue';
  static const String aucunDonnee = 'Aucune donnée disponible';
  static const String chargement = 'Chargement...';
  
  // Labels
  static const String nom = 'Nom';
  static const String prenom = 'Prénom';
  static const String email = 'Email';
  static const String telephone = 'Téléphone';
  static const String filiere = 'Filière';
  static const String niveau = 'Niveau';
  static const String encadreur = 'Encadreur';
  static const String theme = 'Thème';
  static const String date = 'Date';
  static const String heure = 'Heure';
  static const String salle = 'Salle';
  static const String etat = 'État';
  static const String capacite = 'Capacité';
  static const String equipements = 'Équipements';
  
  // États
  static const String enCours = 'En cours';
  static const String valide = 'Validé';
  static const String soutenu = 'Soutenu';
}

class Messages {
  static String get requiredField => 'Ce champ est obligatoire';
  static String get invalidEmail => 'Email invalide';
  static String get invalidPhone => 'Numéro de téléphone invalide';
  static String get invalidNumber => 'Valeur numérique invalide';
}