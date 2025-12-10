import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/soutenance.dart';
import '../../models/memoire.dart';
import '../../providers/soutenance_provider.dart';
import '../../providers/memoire_provider.dart';
import '../../providers/salle_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

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
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.soutenance != null) {
      _selectedMemoireId = widget.soutenance!.memoireId;
      _selectedSalleId = widget.soutenance!.salleId;
      _selectedDate = widget.soutenance!.dateHeure;
      _selectedTime = TimeOfDay.fromDateTime(widget.soutenance!.dateHeure);
      _juryController.text = widget.soutenance!.jury.join(', ');
      _notesController.text = widget.soutenance!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _juryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSoutenance() async {
    if (!_formKey.currentState!.validate()) return;
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
    final hasSalleConflict = soutenanceProvider.hasSalleConflict?.call(
      _selectedSalleId!,
      dateHeure,
      excludeId: widget.soutenance?.id,
    ) ?? false;
    
    if (hasSalleConflict) {
      Helpers.showSnackBar(context, 'Cette salle est déjà occupée à cette heure', isError: true);
      return;
    }

    // Vérifier conflit mémoire
    final hasMemoireConflict = soutenanceProvider.hasMemoireConflict?.call(
      _selectedMemoireId!,
      dateHeure,
      excludeId: widget.soutenance?.id,
    ) ?? false;
    
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
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
    final memoireProvider = Provider.of<MemoireProvider>(context);
    final salleProvider = Provider.of<SalleProvider>(context);
    
    // Filtrer les mémoires qui peuvent avoir une soutenance
    final memoires = memoireProvider.memoires
        .where((m) => m.etat != EtatMemoire.valide) // Exclure les déjà validés
        .toList();
    
    // Obtenir les salles disponibles (ou toutes si pas de méthode spécifique)
    final salles = salleProvider.salles;

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
              icon: const Icon(Icons.delete_outline),
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
                        items: memoires.map((memoire) {
                          return DropdownMenuItem<String>(
                            value: memoire.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  memoire.theme,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'État: ${memoire.etat.displayName}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMemoireId = value;
                          });
                        },
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
                        items: salles.map((salle) {
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
                        onChanged: (value) {
                          setState(() {
                            _selectedSalleId = value;
                          });
                        },
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
                              border: Border.all(color: _selectedDate == null ? Colors.grey : Colors.blue),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? Helpers.formatDate(_selectedDate!)
                                        : 'Sélectionner une date',
                                    style: TextStyle(
                                      color: _selectedDate == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                                if (_selectedDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
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
                              border: Border.all(color: _selectedTime == null ? Colors.grey : Colors.blue),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_outlined, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedTime != null
                                        ? Helpers.formatTime(_selectedTime!)
                                        : 'Sélectionner une heure',
                                    style: TextStyle(
                                      color: _selectedTime == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                                if (_selectedTime != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
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
                validator: (value) => Validators.validateRequired(value, fieldName: 'Les membres du jury'),
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Notes (optionnel)',
                controller: _notesController,
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: widget.soutenance == null ? 'Planifier' : 'Modifier',
                onPressed: _saveSoutenance,
                loading: _isLoading,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
                  final provider = Provider.of<SoutenanceProvider>(context, listen: false);
                  await provider.deleteSoutenance(widget.soutenance!.id);
                  Helpers.showSnackBar(context, 'Soutenance supprimée avec succès');
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