// lib/features/etudiants/add_etudiant_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/etudiant.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

class AddEtudiantPage extends StatefulWidget {
  final Etudiant? etudiant;

  const AddEtudiantPage({super.key, this.etudiant});

  @override
  State<AddEtudiantPage> createState() => _AddEtudiantPageState();
}

class _AddEtudiantPageState extends State<AddEtudiantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _encadreurController = TextEditingController();
  
  // Variables pour les dropdowns
  String? _selectedFiliere;
  String? _selectedNiveau;
  
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  // Liste des filières ENEAM
  final List<String> _filiereOptions = [
    'Informatique de gestion',
    'Planification des projets',
    'Gestion de Banque et Assurance',
    'Gestion Commerciale',
    'Gestion des Transports & Logistiques',
    'Gestion des Ressources Humaines (GRH)',
    'Statistiques',
  ];

  // Liste des niveaux ENEAM (L2, L3, M2 seulement)
  final List<String> _niveauOptions = ['L2', 'L3', 'M2'];

  @override
  void initState() {
    super.initState();
    if (widget.etudiant != null) {
      // Mode édition : charger les données de l'étudiant existant
      _nomController.text = widget.etudiant!.nom;
      _prenomController.text = widget.etudiant!.prenom;
      _emailController.text = widget.etudiant!.email;
      _telephoneController.text = widget.etudiant!.telephone;
      _encadreurController.text = widget.etudiant!.encadreur ?? '';
      _selectedFiliere = widget.etudiant!.filiere;
      _selectedNiveau = widget.etudiant!.niveau;
    } else {
      // Mode ajout : récupérer les infos depuis l'inscription/connexion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.userNom != null && authProvider.userNom!.isNotEmpty) {
          _nomController.text = authProvider.userNom!;
        }
        if (authProvider.userPrenom != null && authProvider.userPrenom!.isNotEmpty) {
          _prenomController.text = authProvider.userPrenom!;
        }
        if (authProvider.currentUser != null && authProvider.currentUser!.isNotEmpty) {
          _emailController.text = authProvider.currentUser!;
        }
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _encadreurController.dispose();
    super.dispose();
  }

  Future<void> _saveEtudiant() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation des dropdowns
    if (_selectedFiliere == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner une filière', isError: true);
      return;
    }
    if (_selectedNiveau == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner un niveau', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<EtudiantProvider>(context, listen: false);
      final etudiant = Etudiant(
        id: widget.etudiant?.id ?? _uuid.v4(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        filiere: _selectedFiliere!,
        niveau: _selectedNiveau!,
        encadreur: _encadreurController.text.trim().isNotEmpty 
            ?  _encadreurController.text.trim() 
            : null,
      );

      if (widget.etudiant == null) {
        await provider.addEtudiant(etudiant);
        Helpers.showSnackBar(context, 'Étudiant ajouté avec succès');
      } else {
        await provider.updateEtudiant(etudiant);
        Helpers.showSnackBar(context, 'Étudiant modifié avec succès');
      }

      Navigator.pop(context);
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Erreur: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            Text(
              widget.etudiant == null 
                ? 'Ajouter un étudiant' 
                : 'Modifier étudiant',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.etudiant != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context),
              tooltip: 'Supprimer',
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête moderne
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.etudiant == null 
                            ? Icons.person_add_rounded 
                            : Icons.person_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.etudiant == null
                                ? 'Nouvel étudiant'
                                : 'Modifier étudiant',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.etudiant == null
                                ? 'Les informations de connexion seront pré-remplies'
                                : 'Mettez à jour les informations',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations personnelles
                _buildFormSection('Informations personnelles', [
                  _buildInputField(
                    label: 'Nom *',
                    controller: _nomController,
                    icon: Icons.person,
                    validator: (value) => Validators.validateRequired(value, fieldName: 'Le nom'),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Prénom *',
                    controller: _prenomController,
                    icon: Icons.person_outline,
                    validator: (value) => Validators.validateRequired(value, fieldName: 'Le prénom'),
                  ),
                ]),

                const SizedBox(height: 20),

                // Informations académiques ENEAM
                _buildFormSection('Informations académiques - ENEAM', [
                  // Filière - DROPDOWN
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filière *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedFiliere == null 
                              ? Colors.grey.shade300
                              : const Color(0xFF6366F1),
                            width: _selectedFiliere == null ? 1 : 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFiliere,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Sélectionnez une filière ENEAM',
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ),
                            items: _filiereOptions.map((filiere) {
                              return DropdownMenuItem<String>(
                                value: filiere,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    filiere,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFiliere = value;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_selectedFiliere == null && _formKey.currentState?.validate() == false)
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Veuillez sélectionner une filière',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Niveau - DROPDOWN
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Niveau *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedNiveau == null 
                              ? Colors.grey.shade300
                              : const Color(0xFF6366F1),
                            width: _selectedNiveau == null ? 1 : 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedNiveau,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Sélectionnez un niveau',
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ),
                            items: _niveauOptions.map((niveau) {
                              return DropdownMenuItem<String>(
                                value: niveau,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    niveau,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedNiveau = value;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_selectedNiveau == null && _formKey.currentState?.validate() == false)
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Veuillez sélectionner un niveau',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),

                // Informations de contact et encadrement
                _buildFormSection('Informations de contact', [
                  _buildInputField(
                    label: 'Email *',
                    controller: _emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Téléphone *',
                    controller: _telephoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Encadreur (optionnel)',
                    controller: _encadreurController,
                    icon: Icons.supervisor_account,
                  ),
                ]),

                const SizedBox(height: 32),

                // Bouton d'action moderne
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEtudiant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.etudiant == null 
                                  ? Icons.add_circle_rounded 
                                  : Icons.save_rounded,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.etudiant == null 
                                  ? 'Ajouter l\'étudiant' 
                                  : 'Enregistrer les modifications',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton d'annulation
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF757575),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ANNULER',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF616161),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2C3E50),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF757575),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            hintText: label.contains('optionnel') 
                ? label 
                : 'Entrez ${label.toLowerCase().replaceAll(' *', '')}',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('Confirmation de suppression'),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'étudiant "${widget.etudiant!.nom} ${widget.etudiant!.prenom}" ? Cette action est irréversible.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF616161),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF757575),
              ),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final provider = Provider.of<EtudiantProvider>(
                    context, 
                    listen: false,
                  );
                  await provider.deleteEtudiant(widget.etudiant!.id);
                  Helpers.showSnackBar(
                    context, 
                    'Étudiant supprimé avec succès'
                  );
                  Navigator.pop(context);
                } catch (e) {
                  Helpers.showSnackBar(
                    context,
                    'Erreur lors de la suppression: $e',
                    isError: true,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('SUPPRIMER'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        );
      },
    );
  }
}