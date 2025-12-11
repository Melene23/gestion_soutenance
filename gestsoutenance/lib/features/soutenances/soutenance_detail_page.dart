import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/soutenance.dart';
import '../../models/memoire.dart';
import '../../models/salle.dart';
import '../../providers/soutenance_provider.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/salle_provider.dart';
import '../../widgets/custom_card.dart';
import '../../core/utils/helpers.dart';
import 'planifier_soutenance_page.dart';

class SoutenanceDetailPage extends StatelessWidget {
  final String soutenanceId;

  const SoutenanceDetailPage({super.key, required this.soutenanceId});

  @override
  Widget build(BuildContext context) {
    final soutenanceProvider = Provider.of<SoutenanceProvider>(context);
    final memoireProvider = Provider.of<MemoireProvider>(context);
    final etudiantProvider = Provider.of<EtudiantProvider>(context);
    final salleProvider = Provider.of<SalleProvider>(context);
    
    final soutenance = soutenanceProvider.getSoutenanceById(soutenanceId);
    final memoire = soutenance != null 
        ? memoireProvider.getMemoireById(soutenance.memoireId)
        : null;
    final etudiant = memoire != null 
        ? etudiantProvider.getEtudiantById(memoire.etudiantId)
        : null;
    final salle = soutenance != null 
        ? salleProvider.getSalleById(soutenance.salleId)
        : null;

    if (soutenance == null) {
      return const Scaffold(
        body: Center(
          child: Text('Soutenance non trouvée'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la soutenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlanifierSoutenancePage(soutenance: soutenance),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec date et heure
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Text(
                    Helpers.formatDateTime(soutenance.dateHeure),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salle?.nom ?? 'Salle inconnue',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informations du mémoire
            if (memoire != null)
              CustomCardWithTitle(
                title: 'Mémoire',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Thème', memoire.theme),
                    _buildInfoRow('Description', memoire.description),
                    _buildInfoRow('Encadreur', memoire.encadreur),
                    _buildInfoRow('État', memoire.etat.displayName),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Informations de l'étudiant
            if (etudiant != null)
              CustomCardWithTitle(
                title: 'Étudiant',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          etudiant.prenom[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(etudiant.nomComplet),
                      subtitle: Text('${etudiant.filiere} - ${etudiant.niveau}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Naviguer vers le détail de l'étudiant
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Informations de la salle
            if (salle != null)
              CustomCardWithTitle(
                title: 'Salle',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nom', salle.nom),
                    _buildInfoRow('Capacité', '${salle.capacite} places'),
                    _buildInfoRow('Équipements', salle.equipementsDisplay),
                    _buildInfoRow('Statut', salle.disponible ? 'Disponible' : 'Occupée'),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Jury
            CustomCardWithTitle(
              title: 'Jury',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: soutenance.jury.map((membre) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(membre),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            if (soutenance.notes != null && soutenance.notes!.isNotEmpty)
              CustomCardWithTitle(
                title: 'Notes',
                child: Text(soutenance.notes!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}