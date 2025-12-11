// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:gestion_soutenances/features/etudiants/add_etudiant_page.dart';
import 'package:gestion_soutenances/features/memoires/add_memoire_page.dart';
import 'package:gestion_soutenances/features/salles/add_salle_page.dart';
import 'package:gestion_soutenances/features/soutenances/planifier_soutenance_page.dart';
import 'features/etudiants/etudiants_page.dart';
import 'features/memoires/memoires_page.dart';
import 'features/salles/salles_page.dart';
import 'features/soutenances/soutenances_page.dart';
import 'features/auth/home_page.dart';
import 'providers/etudiant_provider.dart';
import 'providers/memoire_provider.dart';
import 'providers/salle_provider.dart';
import 'providers/soutenance_provider.dart';
import 'providers/auth_provider.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser AuthService pour charger l'état de connexion depuis SharedPreferences
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EtudiantProvider()),
        ChangeNotifierProvider(create: (_) => MemoireProvider()),
        ChangeNotifierProvider(create: (_) => SalleProvider()),
        ChangeNotifierProvider(create: (_) => SoutenanceProvider()),
      ],
      child: MaterialApp(
        title: 'Gestion Soutenances - ENEAM',
        theme: _buildAppTheme(),
        debugShowCheckedModeBanner: false,
        
        // Corrigé : utilisation de la syntaxe correcte pour les délégations
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('fr', 'FR'),
        
        home: const AuthWrapper(),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        primary: const Color(0xFF2196F3),
        secondary: const Color(0xFF4CAF50),
        tertiary: const Color(0xFFFF9800),
        background: const Color(0xFFF8F9FA),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: false, // Changé à false pour l'alignement à gauche avec icône
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2C3E50),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(18),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        labelStyle: const TextStyle(color: Color(0xFF616161)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2196F3),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints(minWidth: 56, minHeight: 56),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Color(0xFF9E9E9E),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF2196F3),
        linearTrackColor: Color(0xFFE0E0E0),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EtudiantsPage(),
    const MemoiresPage(),
    const SallesPage(),
    const SoutenancesPage(),
  ];

  final List<String> _pageTitles = [
    'Gestion des Étudiants',
    'Gestion des Mémoires',
    'Gestion des Salles',
    'Planification des Soutenances',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final context = this.context;
    Provider.of<EtudiantProvider>(context, listen: false).loadEtudiants();
    Provider.of<MemoireProvider>(context, listen: false).loadMemoires();
    Provider.of<SalleProvider>(context, listen: false).loadSalles();
    Provider.of<SoutenanceProvider>(context, listen: false).loadSoutenances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // ICÔNE CHAPEAU ENEAM - AJOUTÉ ICI
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school, // Icône chapeau de diplômé ENEAM
                size: 28,
                color: Color(0xFF2196F3),
              ),
            ),
            // Titre avec mention ENEAM
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'ENEAM - ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    Text(
                      _pageTitles[_selectedIndex],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getSubtitle(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: _buildAppBarActions(),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  String _getSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Gérer les informations des étudiants';
      case 1:
        return 'Suivre les mémoires et leur état';
      case 2:
        return 'Gérer les salles de soutenance';
      case 3:
        return 'Planifier les soutenances';
      default:
        return '';
    }
  }

  List<Widget>? _buildAppBarActions() {
    return [
      if (_selectedIndex == 0)
        _buildActionButton(
          icon: Icons.refresh,
          tooltip: 'Actualiser',
          onPressed: () {
            Provider.of<EtudiantProvider>(context, listen: false).loadEtudiants();
            _showSnackBar('Liste des étudiants actualisée');
          },
        ),
      if (_selectedIndex == 1)
        _buildActionButton(
          icon: Icons.filter_list,
          tooltip: 'Filtrer',
          onPressed: () {
            // TODO: Implémenter le filtre
          },
        ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        color: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            _buildBottomNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Étudiants',
            ),
            _buildBottomNavItem(
              icon: Icons.book_outlined,
              activeIcon: Icons.book,
              label: 'Mémoires',
            ),
            _buildBottomNavItem(
              icon: Icons.meeting_room_outlined,
              activeIcon: Icons.meeting_room,
              label: 'Salles',
            ),
            _buildBottomNavItem(
              icon: Icons.school_outlined,
              activeIcon: Icons.school,
              label: 'Soutenances',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 22,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          activeIcon,
          size: 22,
          color: const Color(0xFF2196F3),
        ),
      ),
      label: label,
    );
  }

  Widget _buildFloatingActionButton() {
    final String tooltip = _getFABTooltip();
    
    return FloatingActionButton(
      onPressed: () {
        _navigateToAddPage();
      },
      tooltip: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }

  String _getFABTooltip() {
    switch (_selectedIndex) {
      case 0:
        return 'Ajouter un étudiant';
      case 1:
        return 'Ajouter un mémoire';
      case 2:
        return 'Ajouter une salle';
      case 3:
        return 'Planifier une soutenance';
      default:
        return 'Ajouter';
    }
  }

  void _navigateToAddPage() {
    switch (_selectedIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEtudiantPage(),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddMemoirePage(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddSallePage(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlanifierSoutenancePage(),
          ),
        );
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Widget qui vérifie l'état de connexion et affiche la bonne page
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Toujours afficher HomePage au démarrage pour permettre à l'utilisateur
        // de voir la page d'accueil et choisir de se connecter
        // La navigation vers MainScreen se fera après la connexion depuis LoginPage
        return const HomePage();
      },
    );
  }
}