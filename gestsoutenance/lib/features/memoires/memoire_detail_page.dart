import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/memoire.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/etudiant_provider.dart';
import '../../widgets/custom_card.dart';
import '../../core/utils/helpers.dart';
import 'add_memoire_page.dart';

class MemoireDetailPage extends StatelessWidget {
  final String memoireId;

  const MemoireDetailPage({super.key, required this.memoireId});

  @override
  Widget build(BuildContext context) {
    final memoireProvider = Provider.of<MemoireProvider>(context);
    final etudiantProvider = Provider.of<EtudiantProvider>(context);
    
    final memoire = memoireProvider.getMemoireById(memoireId);
    final etudiant = etudiantProvider.getEtudiantById(memoire?.etudiantId ?? '');

    if (memoire == null) {
      return const Scaffold(
        body: Center(
          child: Text('Mémoire non trouvé'),
        ),
      );
    }

    // Fonction pour obtenir la couleur selon l'état
    Color getEtatColor(EtatMemoire etat) {
      switch (etat) {
        case EtatMemoire.enPreparation:
          return Colors.orange;
        case EtatMemoire.soumis:
          return Colors.blue;
        case EtatMemoire.valide:
          return Colors.green;
        default:
          return Colors.grey; // Cas par défaut pour éviter les erreurs
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Helpers.truncateText(memoire.theme, maxLength: 30)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemoirePage(memoire: memoire),
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
            // État du mémoire
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getEtatColor(memoire.etat).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getEtatColor(memoire.etat).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'État',
                    style: TextStyle(
                      fontSize: 14,
                      color: getEtatColor(memoire.etat),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memoire.etat.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      color: getEtatColor(memoire.etat),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informations du mémoire
            _buildInfoCard(
              title: 'Informations du mémoire',
              children: [
                _buildInfoRow('Thème', memoire.theme),
                _buildInfoRow('Description', memoire.description),
                _buildInfoRow('Encadreur', memoire.encadreur),
                _buildInfoRow('Date de début', 
                  Helpers.formatDate(memoire.dateDebut)),
                if (memoire.dateSoutenance != null)
                  _buildInfoRow('Date de soutenance', 
                    Helpers.formatDate(memoire.dateSoutenance!)),
              ],
            ),
            const SizedBox(height: 16),

            // Informations de l'étudiant
            if (etudiant != null)
              _buildInfoCard(
                title: 'Étudiant',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          etudiant.prenom.isNotEmpty 
                            ? etudiant.prenom[0].toUpperCase() 
                            : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(etudiant.nomComplet),
                      subtitle: Text('${etudiant.filiere} - ${etudiant.niveau}'),
                      trailing: const Icon(Icons.chevron_right_outlined),
                      onTap: () {
                        // Naviguer vers le détail de l'étudiant
                        // Vous devrez implémenter cette navigation
                        // Navigator.push(...);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, List<Widget>? children, Widget? child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (children != null) ...children,
            if (child != null) child,
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