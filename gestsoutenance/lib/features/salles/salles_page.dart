import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/salle.dart';
import '../../providers/salle_provider.dart';
import '../../widgets/custom_card.dart';
import '../../core/utils/helpers.dart';
import 'add_salle_page.dart';

class SallesPage extends StatefulWidget {
  const SallesPage({super.key});

  @override
  State<SallesPage> createState() => _SallesPageState();
}

class _SallesPageState extends State<SallesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showDisponiblesOnly = false;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<SalleProvider>(
      builder: (context, provider, child) {
        List<Salle> filteredSalles = _showDisponiblesOnly
            ? provider.getSallesDisponibles()
            : provider.salles;

        if (_searchQuery.isNotEmpty) {
          filteredSalles = filteredSalles.where((salle) {
            return salle.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   salle.equipementsDisplay.toLowerCase().contains(_searchQuery.toLowerCase());
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
                  onPressed: () => provider.loadSalles(),
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
                      hintText: 'Rechercher une salle...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: _showDisponiblesOnly,
                        onChanged: (value) {
                          setState(() {
                            _showDisponiblesOnly = value;
                          });
                        },
                      ),
                      const Text('Afficher seulement les salles disponibles'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredSalles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.meeting_room_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Aucune salle enregistrée'
                                : 'Aucune salle trouvée',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Cliquez sur + pour ajouter une salle',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: filteredSalles.length,
                      itemBuilder: (context, index) {
                        final salle = filteredSalles[index];
                        return _buildSalleCard(context, salle);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalleCard(BuildContext context, Salle salle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CustomCard(
        onTap: () {
          _showSalleDetails(context, salle);
        },
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: salle.disponible ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                salle.disponible ? Icons.meeting_room : Icons.meeting_room_outlined,
                color: salle.disponible ? Colors.green : Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salle.nom,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Capacité: ${salle.capacite} places',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Helpers.truncateText(salle.equipementsDisplay, maxLength: 30),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: salle.disponible ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                salle.disponible ? 'Disponible' : 'Occupée',
                style: TextStyle(
                  fontSize: 12,
                  color: salle.disponible ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalleDetails(BuildContext context, Salle salle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(salle.nom),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('Capacité', '${salle.capacite} places'),
                _buildDetailItem('Équipements', salle.equipementsDisplay),
                _buildDetailItem('Statut', salle.disponible ? 'Disponible' : 'Occupée'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSallePage(salle: salle),
                  ),
                );
              },
              child: const Text('Modifier'),
            ),
            if (salle.disponible)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Planifier une soutenance dans cette salle
                },
                child: const Text('Planifier'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}