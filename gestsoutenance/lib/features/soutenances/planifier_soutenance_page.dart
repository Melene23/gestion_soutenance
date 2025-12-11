import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/soutenance.dart';
import '../../models/memoire.dart';
import '../../providers/soutenance_provider.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/salle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/permissions.dart';

class PlanifierSoutenancePage extends StatefulWidget {
  final Soutenance? soutenance;

  const PlanifierSoutenancePage({super.key, this.soutenance});

  @override
  State<PlanifierSoutenancePage> createState() => _PlanifierSoutenancePageState();
}

class _PlanifierSoutenancePageState extends State<PlanifierSoutenancePage> {
  final _formKey = GlobalKey<FormState>();
  final _juryController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedMemoireId;
  String? _selectedSalleId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  bool _isLoading = false;
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    
    // Initialiser avec les données existantes si modification
    if (widget.soutenance != null) {
      _selectedMemoireId = widget.soutenance!.memoireId;
      _selectedSalleId = widget.soutenance!.salleId;
      _selectedDate = widget.soutenance!.dateHeure;
      _selectedTime = TimeOfDay.fromDateTime(widget.soutenance!.dateHeure);
      _juryController.text = widget.soutenance!.jury.join(', ');
      _notesController.text = widget.soutenance!.notes ?? '';
    }
    
    // Charger les données après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;
    
    try {
      // Charger les mémoires si nécessaire
      final memoireProvider = Provider.of<MemoireProvider>(context, listen: false);
      if (memoireProvider.memoires.isEmpty) {
        await memoireProvider.loadMemoires();
      }
      
      // Note: Si loadSalles() existe, elle sera appelée automatiquement par le provider
      // On ne fait rien de spécial ici
      
      // Si c'est une modification et le mémoire sélectionné n'est plus dans la liste,
      // l'ajouter temporairement
      if (widget.soutenance != null && _selectedMemoireId != null) {
        final memoire = memoireProvider.getMemoireById(_selectedMemoireId!);
        if (memoire == null) {
          print('Attention: Mémoire ${_selectedMemoireId} non trouvé pour la soutenance en modification');
        }
      }
      
      _isInitialized = true;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
    }
  }

  @override
  void dispose() {
    _juryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveSoutenance() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation des champs obligatoires
    if (_selectedMemoireId == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner un mémoire', isError: true);
      return;
    }
    if (_selectedSalleId == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner une salle', isError: true);
      return;
    }
    if (_selectedDate == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner une date', isError: true);
      return;
    }
    if (_selectedTime == null) {
      Helpers.showSnackBar(context, 'Veuillez sélectionner une heure', isError: true);
      return;
    }

    // Créer la date/heure complète
    final dateHeure = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Vérifier les conflits
    final soutenanceProvider = Provider.of<SoutenanceProvider>(context, listen: false);
    
    // Vérifier conflit salle
    bool hasSalleConflict = false;
    try {
      hasSalleConflict = soutenanceProvider.hasSalleConflict?.call(
        _selectedSalleId!,
        dateHeure,
        excludeId: widget.soutenance?.id,
      ) ?? false;
    } catch (e) {
      print('Erreur lors de la vérification de conflit salle: $e');
    }
    
    if (hasSalleConflict) {
      Helpers.showSnackBar(context, 'Cette salle est déjà occupée à cette heure', isError: true);
      return;
    }

    // Vérifier conflit mémoire
    bool hasMemoireConflict = false;
    try {
      hasMemoireConflict = soutenanceProvider.hasMemoireConflict?.call(
        _selectedMemoireId!,
        dateHeure,
        excludeId: widget.soutenance?.id,
      ) ?? false;
    } catch (e) {
      print('Erreur lors de la vérification de conflit mémoire: $e');
    }
    
    if (hasMemoireConflict) {
      Helpers.showSnackBar(context, 'Ce mémoire a déjà une soutenance prévue', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<SoutenanceProvider>(context, listen: false);
      final soutenance = Soutenance(
        id: widget.soutenance?.id ?? _uuid.v4(),
        memoireId: _selectedMemoireId!,
        salleId: _selectedSalleId!,
        dateHeure: dateHeure,
        jury: _juryController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.soutenance == null) {
        await provider.addSoutenance(soutenance);
        
        // Mettre à jour l'état du mémoire
        final memoireProvider = Provider.of<MemoireProvider>(context, listen: false);
        final memoire = memoireProvider.getMemoireById(_selectedMemoireId!);
        if (memoire != null) {
          // Créer une nouvelle instance avec l'état mis à jour
          final memoireMisAJour = Memoire(
            id: memoire.id,
            etudiantId: memoire.etudiantId,
            theme: memoire.theme,
            description: memoire.description,
            encadreur: memoire.encadreur,
            etat: EtatMemoire.valide, // Mettre à jour l'état
            dateDebut: memoire.dateDebut,
            dateSoutenance: dateHeure, // Ajouter la date de soutenance
          );
          await memoireProvider.updateMemoire(memoireMisAJour);
        }
        
        Helpers.showSnackBar(context, 'Soutenance planifiée avec succès');
      } else {
        await provider.updateSoutenance(soutenance);
        Helpers.showSnackBar(context, 'Soutenance modifiée avec succès');
      }

      Navigator.pop(context);
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Erreur: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier que l'utilisateur est admin
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!Permissions.isAdmin(authProvider)) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Accès refusé'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Accès réservé aux administrateurs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seuls les administrateurs peuvent planifier des soutenances',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _buildPlanifierContent(context);
      },
    );
  }
  
  Widget _buildPlanifierContent(BuildContext context) {
    final memoireProvider = Provider.of<MemoireProvider>(context);
    final salleProvider = Provider.of<SalleProvider>(context);
    
    // Utiliser un filtre simple
    final memoires = memoireProvider.memoires.where((m) {
      return m.etat != EtatMemoire.valide || 
             (widget.soutenance != null && m.id == widget.soutenance!.memoireId);
    }).toList();
    
    final salles = salleProvider.salles;

    // Afficher un message si pas de données - CORRECTION ICI
    if (!_isInitialized && memoireProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Planification')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.soutenance == null 
            ? 'Planifier une soutenance' 
            : 'Modifier la soutenance',
        ),
        actions: [
          if (widget.soutenance != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Sélection du mémoire
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mémoire *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMemoireId,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        hint: const Text('Sélectionnez un mémoire'),
                        items: memoires.isEmpty
                            ? [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: const Text(
                                    'Aucun mémoire disponible',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              ]
                            : memoires.map((memoire) {
                          return DropdownMenuItem<String>(
                            value: memoire.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  memoire.theme,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'État: ${memoire.etat.displayName}',
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: memoire.etat.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: memoires.isEmpty 
                            ? null 
                            : (value) {
                                setState(() {
                                  _selectedMemoireId = value;
                                });
                              },
                      ),
                    ),
                  ),
                  if (memoires.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Aucun mémoire disponible pour soutenance. '
                        'Assurez-vous d\'avoir des mémoires en préparation.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_selectedMemoireId == null && _formKey.currentState?.validate() == false)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Veuillez sélectionner un mémoire',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Sélection de la salle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Salle *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSalleId,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        hint: const Text('Sélectionnez une salle'),
                        items: salles.isEmpty
                            ? [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: const Text(
                                    'Aucune salle disponible',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              ]
                            : salles.map((salle) {
                          return DropdownMenuItem<String>(
                            value: salle.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(salle.nom),
                                const SizedBox(height: 4),
                                Text(
                                  '${salle.capacite} places',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: salles.isEmpty 
                            ? null 
                            : (value) {
                                setState(() {
                                  _selectedSalleId = value;
                                });
                              },
                      ),
                    ),
                  ),
                  if (salles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Aucune salle disponible. Veuillez d\'abord créer des salles.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_selectedSalleId == null && _formKey.currentState?.validate() == false)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Veuillez sélectionner une salle',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Date et heure
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedDate == null 
                                  ? Colors.grey 
                                  : Colors.blue,
                                width: _selectedDate == null ? 1.0 : 2.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today, 
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? Helpers.formatDate(_selectedDate!)
                                        : 'Sélectionner une date',
                                    style: TextStyle(
                                      color: _selectedDate == null 
                                        ? Colors.grey 
                                        : Colors.black87,
                                      fontWeight: _selectedDate == null 
                                        ? FontWeight.normal 
                                        : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_selectedDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Heure *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedTime == null 
                                  ? Colors.grey 
                                  : Colors.blue,
                                width: _selectedTime == null ? 1.0 : 2.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time, 
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedTime != null
                                        ? _formatTime(_selectedTime!)
                                        : 'Sélectionner une heure',
                                    style: TextStyle(
                                      color: _selectedTime == null 
                                        ? Colors.grey 
                                        : Colors.black87,
                                      fontWeight: _selectedTime == null 
                                        ? FontWeight.normal 
                                        : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_selectedTime != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedTime = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Membres du jury (séparés par des virgules) *',
                controller: _juryController,
                maxLines: 3,
                minLines: 2,
                hintText: 'Ex: Pr. Dupont, Dr. Martin, M. Durand',
                validator: (value) => Validators.validateRequired(
                  value, 
                  fieldName: 'Les membres du jury'
                ),
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Notes (optionnel)',
                controller: _notesController,
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 32),

              // CORRECTION DU BOUTON - Version simplifiée
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || memoires.isEmpty || salles.isEmpty)
                      ? null
                      : () => _saveSoutenance(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.soutenance == null ? 'Planifier' : 'Modifier',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode helper pour formater l'heure
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette soutenance ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final provider = Provider.of<SoutenanceProvider>(
                    context, 
                    listen: false,
                  );
                  await provider.deleteSoutenance(widget.soutenance!.id);
                  Helpers.showSnackBar(
                    context, 
                    'Soutenance supprimée avec succès'
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