import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/soutenance.dart';
import '../../providers/soutenance_provider.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/salle_provider.dart';
import '../../widgets/custom_card.dart';
import '../../core/utils/helpers.dart';
import 'planifier_soutenance_page.dart';
import 'soutenance_detail_page.dart';

class SoutenancesPage extends StatefulWidget {
  const SoutenancesPage({super.key});

  @override
  State<SoutenancesPage> createState() => _SoutenancesPageState();
}

class _SoutenancesPageState extends State<SoutenancesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SoutenanceProvider>(
      builder: (context, provider, child) {
        List<Soutenance> filteredSoutenances = provider.getSoutenancesByDate(_selectedDate);

        if (_searchQuery.isNotEmpty) {
          filteredSoutenances = filteredSoutenances.where((soutenance) {
            // Rechercher dans les détails associés
            final memoireProvider = Provider.of<MemoireProvider>(context, listen: false);
            final memoire = memoireProvider.getMemoireById(soutenance.memoireId);
            
            if (memoire != null && 
                memoire.theme.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return true;
            }
            
            final salleProvider = Provider.of<SalleProvider>(context, listen: false);
            final salle = salleProvider.getSalleById(soutenance.salleId);
            
            if (salle != null && 
                salle.nom.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return true;
            }
            
            return false;
          }).toList();
        }

        // Trier par heure
        filteredSoutenances.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));

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
                  onPressed: () => provider.loadSoutenances(),
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
                      hintText: 'Rechercher une soutenance...',
                      prefixIcon: const Icon(Icons.search_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            'Soutenances du ${Helpers.formatDate(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_outlined, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredSoutenances.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune soutenance prévue pour le ${Helpers.formatDate(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cliquez sur + pour planifier une soutenance',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: filteredSoutenances.length,
                      itemBuilder: (context, index) {
                        final soutenance = filteredSoutenances[index];
                        return _buildSoutenanceCard(context, soutenance);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSoutenanceCard(BuildContext context, Soutenance soutenance) {
    final memoireProvider = Provider.of<MemoireProvider>(context, listen: false);
    final etudiantProvider = Provider.of<EtudiantProvider>(context, listen: false);
    final salleProvider = Provider.of<SalleProvider>(context, listen: false);
    
    final memoire = memoireProvider.getMemoireById(soutenance.memoireId);
    final etudiant = memoire != null 
        ? etudiantProvider.getEtudiantById(memoire.etudiantId)
        : null;
    final salle = salleProvider.getSalleById(soutenance.salleId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CustomCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoutenanceDetailPage(soutenanceId: soutenance.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memoire?.theme ?? 'Thème inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (etudiant != null)
                        Text(
                          etudiant.nomComplet,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Helpers.formatTime(TimeOfDay.fromDateTime(soutenance.dateHeure)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      salle?.nom ?? 'Salle inconnue',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Jury: ${Helpers.truncateText(soutenance.juryDisplay, maxLength: 40)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}