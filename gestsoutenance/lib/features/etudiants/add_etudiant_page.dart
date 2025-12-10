// lib/features/etudiants/add_etudiant_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/etudiant.dart';
import '../../providers/etudiant_provider.dart';
import '../../providers/metadata_provider.dart';
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
  
  String? _selectedFiliere;
  String? _selectedNiveau;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.etudiant != null) {
      _nomController.text = widget.etudiant!.nom;
      _prenomController.text = widget.etudiant!.prenom;
      _emailController.text = widget.etudiant!.email;
      _telephoneController.text = widget.etudiant!.telephone;
      _selectedFiliere = widget.etudiant!.filiere;
      _selectedNiveau = widget.etudiant!.niveau;
      _encadreurController.text = widget.etudiant!.encadreur;
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

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<EtudiantProvider>(context, listen: false);
      if (_selectedFiliere == null || _selectedNiveau == null) {
        Helpers.showSnackBar(
          context,
          'Veuillez sélectionner une filière et un niveau',
          isError: true,
        );
        return;
      }
      
      final etudiant = Etudiant(
        id: widget.etudiant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        filiere: _selectedFiliere!,
        niveau: _selectedNiveau!,
        encadreur: _encadreurController.text.trim(),
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
        title: Text(
          widget.etudiant == null 
            ? 'Nouvel étudiant' 
            : 'Modifier étudiant',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.etudiant != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmation,
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
                // En-tête
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.etudiant == null 
                          ? Icons.person_add 
                          : Icons.person_outline,
                        color: const Color(0xFF2196F3),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.etudiant == null
                            ? 'Remplissez les informations de l\'étudiant'
                            : 'Modifiez les informations de l\'étudiant',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Formulaire
                _buildFormSection('Informations personnelles', [
                  _buildInputField(
                    label: 'Nom *',
                    controller: _nomController,
                    icon: Icons.account_circle_outlined,
                    validator: (value) => Validators.validateRequired(
                      value, 
                      fieldName: 'Le nom'
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Prénom *',
                    controller: _prenomController,
                    icon: Icons.person_outline,
                    validator: (value) => Validators.validateRequired(
                      value, 
                      fieldName: 'Le prénom'
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Email *',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Téléphone *',
                    controller: _telephoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                ]),

                const SizedBox(height: 24),

                _buildFormSection('Informations académiques', [
                  // Liste déroulante pour Filière
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
                      Consumer<MetadataProvider>(
                        builder: (context, metadataProvider, child) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedFiliere == null 
                                  ? const Color(0xFFE0E0E0) 
                                  : const Color(0xFF2196F3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFiliere,
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Sélectionnez une filière',
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ),
                                items: metadataProvider.filieres.map((filiere) {
                                  return DropdownMenuItem<String>(
                                    value: filiere,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                          );
                        },
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
                  // Liste déroulante pour Niveau
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
                      Consumer<MetadataProvider>(
                        builder: (context, metadataProvider, child) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedNiveau == null 
                                  ? const Color(0xFFE0E0E0) 
                                  : const Color(0xFF2196F3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedNiveau,
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Sélectionnez un niveau',
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ),
                                items: metadataProvider.niveaux.map((niveau) {
                                  return DropdownMenuItem<String>(
                                    value: niveau,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                          );
                        },
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
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Encadreur *',
                    controller: _encadreurController,
                    icon: Icons.supervisor_account_outlined,
                    validator: (value) => Validators.validateRequired(
                      value, 
                      fieldName: 'L\'encadreur'
                    ),
                  ),
                ]),

                const SizedBox(height: 32),

                // Bouton d'action
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEtudiant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.etudiant == null 
                                  ? Icons.add_circle_outline 
                                  : Icons.save,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.etudiant == null 
                                  ? 'AJOUTER L\'ÉTUDIANT' 
                                  : 'ENREGISTRER LES MODIFICATIONS',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            hintText: 'Entrez $label',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 12),
              Text('Confirmation de suppression'),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'étudiant "${widget.etudiant!.nomComplet}" ? Cette action est irréversible.',
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