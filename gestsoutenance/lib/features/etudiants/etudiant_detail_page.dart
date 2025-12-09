// lib/features/etudiants/etudiant_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/etudiant.dart';
import '../../models/memoire.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/memoire_provider.dart';
import '../../core/utils/helpers.dart';
import 'add_etudiant_page.dart';

class EtudiantDetailPage extends StatelessWidget {
  final String etudiantId;

  const EtudiantDetailPage({super.key, required this.etudiantId});

  @override
  Widget build(BuildContext context) {
    final etudiantProvider = Provider.of<EtudiantProvider>(context);
    final memoireProvider = Provider.of<MemoireProvider>(context);
    
    final etudiant = etudiantProvider.getEtudiantById(etudiantId);
    final memoires = memoireProvider.getMemoiresByEtudiant(etudiantId);

    if (etudiant == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Étudiant non trouvé'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Étudiant non trouvé',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              etudiant.nomComplet,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              etudiant.filiere,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEtudiantPage(etudiant: etudiant),
                ),
              );
            },
            tooltip: 'Modifier',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec avatar
            _buildHeader(context, etudiant),
            const SizedBox(height: 24),

            // Informations personnelles
            _buildInfoCard(
              title: 'Informations personnelles',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('Nom', etudiant.nom),
                _buildInfoRow('Prénom', etudiant.prenom),
                _buildInfoRow('Email', etudiant.email),
                _buildInfoRow('Téléphone', etudiant.telephone),
                _buildInfoRow(
                  'Date d\'inscription', 
                  Helpers.formatDate(etudiant.dateInscription),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informations académiques
            _buildInfoCard(
              title: 'Informations académiques',
              icon: Icons.school_outlined,
              children: [
                _buildInfoRow('Filière', etudiant.filiere),
                _buildInfoRow('Niveau', etudiant.niveau),
                _buildInfoRow('Encadreur', etudiant.encadreur),
              ],
            ),
            const SizedBox(height: 16),

            // Mémoires
            _buildInfoCard(
              title: 'Mémoires',
              icon: Icons.book_outlined,
              child: memoires.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.book_outlined,
                      message: 'Aucun mémoire enregistré',
                      subtitle: 'Les mémoires apparaîtront ici',
                    )
                  : Column(
                      children: memoires.map((memoire) {
                        return _buildMemoireItem(context, memoire);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Etudiant etudiant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Center(
              child: Text(
                etudiant.prenom[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etudiant.nomComplet,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  etudiant.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inscrit le ${Helpers.formatDate(etudiant.dateInscription)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    List<Widget>? children,
    Widget? child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF2196F3),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (children != null) ...children,
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF616161),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoireItem(BuildContext context, Memoire memoire) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: memoire.etat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: memoire.etat.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  memoire.etat.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: memoire.etat.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            memoire.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 4),
              Text(
                'Début: ${Helpers.formatDate(memoire.dateDebut)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Implémenter la navigation vers le détail du mémoire
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                child: const Row(
                  children: [
                    Text('Voir détails'),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_outlined, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9E9E9E),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFBDBDBD),
              ),
            ),
          ],
        ],
      ),
    );
  }
}