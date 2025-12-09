import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/etudiants/etudiants_page.dart';
import '../features/memoires/memoires_page.dart';
import '../features/salles/salles_page.dart';
import '../features/soutenances/soutenances_page.dart';
import '../features/etudiants/add_etudiant_page.dart';
import '../features/memoires/add_memoire_page.dart';
import '../features/salles/add_salle_page.dart';
import '../features/soutenances/planifier_soutenance_page.dart';
import '../features/etudiants/etudiant_detail_page.dart';
import '../features/memoires/memoire_detail_page.dart';
import '../features/soutenances/soutenance_detail_page.dart';
import '../providers/etudiant_provider.dart';
import '../providers/memoire_provider.dart';
import '../providers/salle_provider.dart';
import '../providers/soutenance_provider.dart';
import 'routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const EtudiantsPage(),
    const MemoiresPage(),
    const SallesPage(),
    const SoutenancesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EtudiantProvider()),
        ChangeNotifierProvider(create: (_) => MemoireProvider()),
        ChangeNotifierProvider(create: (_) => SalleProvider()),
        ChangeNotifierProvider(create: (_) => SoutenanceProvider()),
      ],
      child: MaterialApp(
        title: 'Gestion des Soutenances',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: Routes.etudiants,
        routes: {
          Routes.etudiants: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Étudiants'),
            ),
            body: _pages[0],
            bottomNavigationBar: _buildBottomNavBar(),
          ),
          Routes.addEtudiant: (context) => const AddEtudiantPage(),
          Routes.etudiantDetail: (context) {
            final id = ModalRoute.of(context)!.settings.arguments as String;
            return EtudiantDetailPage(etudiantId: id);
          },
          Routes.memoires: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Mémoires'),
            ),
            body: _pages[1],
            bottomNavigationBar: _buildBottomNavBar(),
          ),
          Routes.addMemoire: (context) => const AddMemoirePage(),
          Routes.memoireDetail: (context) {
            final id = ModalRoute.of(context)!.settings.arguments as String;
            return MemoireDetailPage(memoireId: id);
          },
          Routes.salles: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Salles'),
            ),
            body: _pages[2],
            bottomNavigationBar: _buildBottomNavBar(),
          ),
          Routes.addSalle: (context) => const AddSallePage(),
          Routes.soutenances: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Soutenances'),
            ),
            body: _pages[3],
            bottomNavigationBar: _buildBottomNavBar(),
          ),
          Routes.planifierSoutenance: (context) => const PlanifierSoutenancePage(),
          Routes.soutenanceDetail: (context) {
            final id = ModalRoute.of(context)!.settings.arguments as String;
            return SoutenanceDetailPage(soutenanceId: id);
          },
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          Navigator.pushNamed(context, [
            Routes.etudiants,
            Routes.memoires,
            Routes.salles,
            Routes.soutenances,
          ][index]);
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Étudiants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Mémoires',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.meeting_room),
          label: 'Salles',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Soutenances',
        ),
      ],
    );
  }
}