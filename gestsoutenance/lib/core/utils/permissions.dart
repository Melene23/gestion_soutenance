// Helper pour gérer les permissions basées sur les rôles
import 'package:gestion_soutenances/providers/auth_provider.dart';

class Permissions {
  // Vérifier si l'utilisateur est admin
  static bool isAdmin(AuthProvider authProvider) {
    return authProvider.isAdmin;
  }

  // Vérifier si l'utilisateur est étudiant
  static bool isEtudiant(AuthProvider authProvider) {
    return authProvider.userRole == 'etudiant';
  }

  // Vérifier si l'utilisateur peut voir toutes les données (admin uniquement)
  static bool canViewAll(AuthProvider authProvider) {
    return isAdmin(authProvider);
  }

  // Vérifier si l'utilisateur peut gérer les salles (admin uniquement)
  static bool canManageSalles(AuthProvider authProvider) {
    return isAdmin(authProvider);
  }

  // Vérifier si l'utilisateur peut attribuer les salles (admin uniquement)
  static bool canAssignSalles(AuthProvider authProvider) {
    return isAdmin(authProvider);
  }

  // Vérifier si l'utilisateur peut voir toutes les soutenances (admin uniquement)
  static bool canViewAllSoutenances(AuthProvider authProvider) {
    return isAdmin(authProvider);
  }

  // Vérifier si l'utilisateur peut gérer les étudiants (admin uniquement)
  static bool canManageEtudiants(AuthProvider authProvider) {
    return isAdmin(authProvider);
  }

  // Vérifier si l'utilisateur peut gérer les mémoires (admin uniquement)
  static bool canManageMemoires(AuthProvider authProvider) {
    return isAdmin(authProvider);
  }

  // Vérifier si l'utilisateur peut voir ses propres données (étudiant)
  static bool canViewOwnData(AuthProvider authProvider) {
    return isEtudiant(authProvider);
  }

  // Obtenir l'ID de l'utilisateur connecté (pour filtrer les données des étudiants)
  static String? getCurrentUserId(AuthProvider authProvider) {
    // Pour les étudiants, on utilisera l'email pour faire correspondre avec la table etudiants
    return authProvider.currentUser;
  }
}

