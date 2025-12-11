import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/memoire.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/permissions.dart';
import 'add_memoire_page.dart';
import 'memoire_detail_page.dart';

class MemoiresPage extends StatefulWidget {
  const MemoiresPage({super.key});

  @override
  State<MemoiresPage> createState() => _MemoiresPageState();
}

class _MemoiresPageState extends State<MemoiresPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Tous, 1: En préparation, 2: Soumis, 3: Validés

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Memoire> _filterMemoires(List<Memoire> memoires, int filter) {
    if (filter == 0) return memoires;
    
    return memoires.where((memoire) {
      switch (filter) {
        case 1:
          return memoire.etat == EtatMemoire.enPreparation;
        case 2:
          return memoire.etat == EtatMemoire.soumis;
        case 3:
          return memoire.etat == EtatMemoire.valide;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MemoireProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
        // Filtrer selon le rôle
        List<Memoire> allMemoires = provider.memoires;
        List<Memoire> memoiresToShow;
        
        if (Permissions.isAdmin(authProvider)) {
          // Admin voit tous les mémoires
          memoiresToShow = allMemoires;
        } else {
          // Étudiant voit seulement ses mémoires (via email dans etudiants)
          final etudiantProvider = Provider.of<EtudiantProvider>(context, listen: false);
          final userEmail = authProvider.currentUser?.toLowerCase() ?? '';
          
          memoiresToShow = allMemoires.where((memoire) {
            final etudiant = etudiantProvider.getEtudiantById(memoire.etudiantId);
            return etudiant?.email.toLowerCase() == userEmail;
          }).toList();
        }
        
        List<Memoire> filteredMemoires = _filterMemoires(memoiresToShow, _selectedFilter);

        if (_searchQuery.isNotEmpty) {
          filteredMemoires = filteredMemoires.where((memoire) {
            return memoire.theme.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   memoire.encadreur.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   memoire.description.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erreur: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadMemoires(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un mémoire...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tous', 0),
                        _buildFilterChip('En préparation', 1),
                        _buildFilterChip('Soumis', 2),
                        _buildFilterChip('Validés', 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredMemoires.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedFilter == 0
                                ? 'Aucun mémoire enregistré'
                                : 'Aucun mémoire trouvé',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          if (_searchQuery.isEmpty && _selectedFilter == 0) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Cliquez sur + pour ajouter un mémoire',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: filteredMemoires.length,
                      itemBuilder: (context, index) {
                        final memoire = filteredMemoires[index];
                        return _buildMemoireCard(context, memoire);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 0;
          });
        },
      ),
    );
  }

  Widget _buildMemoireCard(BuildContext context, Memoire memoire) {
    final etudiantProvider = Provider.of<EtudiantProvider>(context, listen: false);
    final etudiant = etudiantProvider.getEtudiantById(memoire.etudiantId);

    Color getEtatColor(EtatMemoire etat) {
      switch (etat) {
        case EtatMemoire.enPreparation:
          return Colors.orange;
        case EtatMemoire.soumis:
          return Colors.blue;
        case EtatMemoire.valide:
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemoireDetailPage(memoireId: memoire.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        memoire.theme,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: getEtatColor(memoire.etat).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        memoire.etat.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: getEtatColor(memoire.etat),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (etudiant != null)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          etudiant.nomComplet,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        memoire.encadreur,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Début: ${Helpers.formatDate(memoire.dateDebut)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}