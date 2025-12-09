// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_soutenances/main.dart';


void main() {
  group('Tests de base de l\'application', () {
    testWidgets('L\'application démarre avec l\'écran d\'accueil', 
        (WidgetTester tester) async {
      // Construire l'application
      await tester.pumpWidget(const MyApp());

      // Vérifier que l'application démarre
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Vérifier qu'il y a une Scaffold (structure de base)
      expect(find.byType(Scaffold), findsAtLeast(1));
    });

    testWidgets('Test de la navigation de base', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Vérifier la présence de widgets communs
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsAtLeast(1)); // Étudiants
      expect(find.byIcon(Icons.book), findsAtLeast(1));   // Mémoires
      expect(find.byIcon(Icons.meeting_room), findsAtLeast(1)); // Salles
      expect(find.byIcon(Icons.school), findsAtLeast(1)); // Soutenances
    });
  });

  // Vous pouvez ajouter d'autres groupes de tests
  group('Tests des pages spécifiques', () {
    // Tests pour la page Étudiants
    testWidgets('Page Étudiants affiche les éléments de base', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Naviguer vers la page Étudiants
      await tester.tap(find.byIcon(Icons.person).first);
      await tester.pumpAndSettle();
      
      // Vérifier les éléments de la page
      expect(find.text('Étudiants'), findsAtLeast(1));
      expect(find.byIcon(Icons.add), findsAtLeast(1));
      expect(find.byType(ListView), findsAtLeast(1));
    });

    // Tests pour la page Mémoires
    testWidgets('Page Mémoires affiche les éléments de base', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Naviguer vers la page Mémoires
      await tester.tap(find.byIcon(Icons.book).first);
      await tester.pumpAndSettle();
      
      // Vérifier les éléments de la page
      expect(find.text('Mémoires'), findsAtLeast(1));
      expect(find.byIcon(Icons.add), findsAtLeast(1));
    });
  });
}