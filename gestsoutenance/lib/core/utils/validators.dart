import 'package:flutter/material.dart';

class Validators {
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est obligatoire';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le téléphone est obligatoire';
    }
    
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide (10 chiffres requis)';
    }
    return null;
  }
  
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Veuillez entrer un nombre valide';
    }
    
    if (number <= 0) {
      return 'Le nombre doit être positif';
    }
    
    return null;
  }
  
  // UNE SEULE méthode validateTime (j'ai gardé la plus complète)
  static String? validateTime(TimeOfDay? time) {
    if (time == null) {
      return 'Veuillez sélectionner une heure';
    }
    
    // Vous pouvez ajouter des validations supplémentaires si besoin
    // Par exemple : vérifier que l'heure est dans une plage horaire
    // if (time.hour < 8 || time.hour > 18) {
    //   return 'L\'heure doit être entre 8h et 18h';
    // }
    
    return null;
  }
  
  // Ajoutez d'autres validateurs si besoin
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'La date est obligatoire';
    }
    
    if (date.isBefore(DateTime.now())) {
      return 'La date ne peut pas être dans le passé';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    return null;
  }
}