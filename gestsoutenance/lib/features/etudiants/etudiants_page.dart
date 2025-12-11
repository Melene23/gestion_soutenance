import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/etudiant.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/permissions.dart';
import 'etudiant_detail_page.dart';


class EtudiantsPage extends StatefulWidget {
  const EtudiantsPage({super.key});

  @override
  State<EtudiantsPage> createState() => _EtudiantsPageState();
}

class _EtudiantsPageState extends State<EtudiantsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    return Consumer2<EtudiantProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
        // Filtrer selon le rôle
        List<Etudiant> allEtudiants = provider.searchEtudiants(_searchQuery);
        List<Etudiant> etudiants;
        
        if (Permissions.isAdmin(authProvider)) {
          // Admin voit tous les étudiants
          etudiants = allEtudiants;
        } else {
          // Étudiant voit seulement son profil (correspondance par email)
          etudiants = allEtudiants.where((etudiant) {
            return etudiant.email.toLowerCase() == 
                   (authProvider.currentUser ?? '').toLowerCase();
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
                  onPressed: () => provider.loadEtudiants(),
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un étudiant...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: etudiants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Aucun étudiant enregistré'
                                : 'Aucun étudiant trouvé',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          if (_searchQuery.isEmpty && Permissions.isAdmin(authProvider)) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Cliquez sur + pour ajouter un étudiant',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                          if (_searchQuery.isEmpty && !Permissions.isAdmin(authProvider)) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Votre profil étudiant apparaîtra ici',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: etudiants.length,
                      itemBuilder: (context, index) {
                        final etudiant = etudiants[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: CustomCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EtudiantDetailPage(
                                    etudiantId: etudiant.id,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    etudiant.prenom[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        etudiant.nomComplet,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        etudiant.filiere,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        etudiant.niveau,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (Permissions.isAdmin(authProvider))
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      _showOptionsDialog(context, etudiant, authProvider);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsDialog(BuildContext context, Etudiant etudiant, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(etudiant.nomComplet),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${etudiant.email}'),
              Text('Téléphone: ${etudiant.telephone}'),
              Text('Encadreur: ${etudiant.encadreur}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            if (Permissions.isAdmin(authProvider))
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, etudiant);
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Etudiant etudiant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer ${etudiant.nomComplet} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final provider =
                      Provider.of<EtudiantProvider>(context, listen: false);
                  await provider.deleteEtudiant(etudiant.id);
                  Helpers.showSnackBar(
                    context,
                    'Étudiant supprimé avec succès',
                  );
                } catch (e) {
                  Helpers.showSnackBar(
                    context,
                    'Erreur lors de la suppression: $e',
                    isError: true,
                  );
                }
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}