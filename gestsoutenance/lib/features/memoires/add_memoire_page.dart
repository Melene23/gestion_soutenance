// lib/features/memoires/add_memoire_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/memoire.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/etudiant_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

class AddMemoirePage extends StatefulWidget {
  final Memoire? memoire;

  const AddMemoirePage({super.key, this.memoire});

  @override
  State<AddMemoirePage> createState() => _AddMemoirePageState();
}

class _AddMemoirePageState extends State<AddMemoirePage> {
  final _formKey = GlobalKey<FormState>();
  final _themeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _encadreurController = TextEditingController();
  
  String? _selectedEtudiantId;
  EtatMemoire _selectedEtat = EtatMemoire.enPreparation;
  DateTime? _selectedDateDebut;
  DateTime? _selectedDateSoutenance;
  File? _selectedFile;
  String? _fileName;
  
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.memoire != null) {
      _themeController.text = widget.memoire!.theme;
      _descriptionController.text = widget.memoire!.description;
      _encadreurController.text = widget.memoire!.encadreur;
      _selectedEtudiantId = widget.memoire!.etudiantId;
      _selectedEtat = widget.memoire!.etat;
      _selectedDateDebut = widget.memoire!.dateDebut;
      _selectedDateSoutenance = widget.memoire!.dateSoutenance;
    } else {
      _selectedDateDebut = DateTime.now();
    }
  }

  @override
  void dispose() {
    _themeController.dispose();
    _descriptionController.dispose();
    _encadreurController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        
        // Vérifier la taille du fichier (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          Helpers.showSnackBar(
            context, 
            'Le fichier est trop volumineux (max 10MB)', 
            isError: true
          );
          return;
        }

        setState(() {
          _selectedFile = File(file.path!);
          _fileName = file.name;
        });
        
        Helpers.showSnackBar(
          context, 
          'Fichier sélectionné: ${file.name}'
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        context, 
        'Erreur lors de la sélection du fichier: $e', 
        isError: true
      );
    }
  }

  Future<void> _saveMemoire() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEtudiantId == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner un étudiant', isError: true);
      return;
    }
    if (_selectedDateDebut == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner une date de début', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<MemoireProvider>(context, listen: false);
      
      // Créer le mémoire sans les champs fichier pour l'instant
      // (Vous pouvez les ajouter plus tard quand vous modifierez le modèle)
      final memoire = Memoire(
        id: widget.memoire?.id ?? _uuid.v4(),
        etudiantId: _selectedEtudiantId!,
        theme: _themeController.text.trim(),
        description: _descriptionController.text.trim(),
        encadreur: _encadreurController.text.trim(),
        etat: _selectedEtat,
        dateDebut: _selectedDateDebut!,
        dateSoutenance: _selectedDateSoutenance,
      );

      // TODO: Ajouter la logique pour enregistrer le fichier
      if (_selectedFile != null) {
        print('Fichier à enregistrer: ${_selectedFile!.path}');
        print('Nom du fichier: $_fileName');
        // Vous pourrez ajouter cette logique plus tard
      }

      if (widget.memoire == null) {
        await provider.addMemoire(memoire);
        Helpers.showSnackBar(context, 'Mémoire ajouté avec succès');
      } else {
        await provider.updateMemoire(memoire);
        Helpers.showSnackBar(context, 'Mémoire modifié avec succès');
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

  Future<void> _selectDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateDebut ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDateDebut) {
      setState(() {
        _selectedDateDebut = picked;
      });
    }
  }

  Future<void> _selectDateSoutenance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateSoutenance ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDateSoutenance) {
      setState(() {
        _selectedDateSoutenance = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final etudiantProvider = Provider.of<EtudiantProvider>(context);
    final etudiants = etudiantProvider.etudiants;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.memoire == null 
            ? 'Nouveau mémoire' 
            : 'Modifier mémoire',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.memoire != null)
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
                        widget.memoire == null 
                          ? Icons.bookmark_add_outlined 
                          : Icons.book_outlined,
                        color: const Color(0xFF2196F3),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.memoire == null
                            ? 'Remplissez les informations du mémoire'
                            : 'Modifiez les informations du mémoire',
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

                // Sélection de l'étudiant
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Étudiant *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedEtudiantId == null 
                            ? const Color(0xFFE0E0E0) 
                            : const Color(0xFF2196F3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEtudiantId,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Sélectionnez un étudiant',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          items: etudiants.map((etudiant) {
                            return DropdownMenuItem<String>(
                              value: etudiant.id,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      etudiant.nomComplet,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${etudiant.filiere} - ${etudiant.niveau}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEtudiantId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_selectedEtudiantId == null && _formKey.currentState?.validate() == false)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Veuillez sélectionner un étudiant',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Informations du mémoire
                _buildFormSection('Informations du mémoire', [
                  _buildInputField(
                    label: 'Thème du mémoire *',
                    controller: _themeController,
                    icon: Icons.title,
                    validator: (value) => Validators.validateRequired(
                      value, 
                      fieldName: 'Le thème'
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Fichier du mémoire (PDF/Word) - OPTIONNEL
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fichier du mémoire (PDF/Word) - Optionnel',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickFile,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedFile == null 
                                ? const Color(0xFFE0E0E0) 
                                : const Color(0xFF4CAF50),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedFile == null 
                                  ? Icons.attach_file 
                                  : Icons.check_circle,
                                color: _selectedFile == null 
                                  ? const Color(0xFF757575) 
                                  : const Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _fileName ?? 'Sélectionner un fichier (PDF, Word)',
                                  style: TextStyle(
                                    color: _selectedFile == null 
                                      ? const Color(0xFF9E9E9E) 
                                      : const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              if (_selectedFile != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFile = null;
                                      _fileName = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Fichier sélectionné: $_fileName',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputField(
                    label: 'Description *',
                    controller: _descriptionController,
                    icon: Icons.description,
                    maxLines: 4,
                    minLines: 3,
                    validator: (value) => Validators.validateRequired(
                      value, 
                      fieldName: 'La description'
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputField(
                    label: 'Encadreur *',
                    controller: _encadreurController,
                    icon: Icons.supervisor_account,
                    validator: (value) => Validators.validateRequired(
                      value, 
                      fieldName: 'L\'encadreur'
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // État du mémoire
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'État du mémoire *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<EtatMemoire>(
                          value: _selectedEtat,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          items: EtatMemoire.values.map((etat) {
                            return DropdownMenuItem<EtatMemoire>(
                              value: etat,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: etat.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      etat.displayName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedEtat = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dates
                _buildFormSection('Dates', [
                  // Date de début
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date de début *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectDateDebut(context),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedDateDebut == null 
                                ? const Color(0xFFE0E0E0) 
                                : const Color(0xFF2196F3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF757575),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDateDebut != null
                                      ? Helpers.formatDate(_selectedDateDebut!)
                                      : 'Sélectionner une date',
                                  style: TextStyle(
                                    color: _selectedDateDebut == null 
                                      ? const Color(0xFF9E9E9E) 
                                      : const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              if (_selectedDateDebut != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDateDebut = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date de soutenance (optionnel)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date de soutenance (optionnel)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF616161),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectDateSoutenance(context),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedDateSoutenance == null 
                                ? const Color(0xFFE0E0E0) 
                                : const Color(0xFF2196F3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF757575),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDateSoutenance != null
                                      ? Helpers.formatDate(_selectedDateSoutenance!)
                                      : 'Sélectionner une date',
                                  style: TextStyle(
                                    color: _selectedDateSoutenance == null 
                                      ? const Color(0xFF9E9E9E) 
                                      : const Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              if (_selectedDateSoutenance != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDateSoutenance = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 32),

                // Bouton d'action
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMemoire,
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
                                widget.memoire == null 
                                  ? Icons.add_circle_outline 
                                  : Icons.save_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.memoire == null 
                                  ? 'AJOUTER LE MÉMOIRE' 
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
    int maxLines = 1,
    int minLines = 1,
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
          maxLines: maxLines,
          minLines: minLines,
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
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Entrez $label',
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
            'Êtes-vous sûr de vouloir supprimer le mémoire "${widget.memoire!.theme}" ? Cette action est irréversible.',
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
                  final provider = Provider.of<MemoireProvider>(
                    context, 
                    listen: false,
                  );
                  await provider.deleteMemoire(widget.memoire!.id);
                  Helpers.showSnackBar(
                    context, 
                    'Mémoire supprimé avec succès'
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