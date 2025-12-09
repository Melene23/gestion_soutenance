import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/salle.dart';
import '../../providers/salle_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

class AddSallePage extends StatefulWidget {
  final Salle? salle;

  const AddSallePage({super.key, this.salle});

  @override
  State<AddSallePage> createState() => _AddSallePageState();
}

class _AddSallePageState extends State<AddSallePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _capaciteController = TextEditingController();
  final _equipementsController = TextEditingController();
  
  bool _disponible = true;
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.salle != null) {
      _nomController.text = widget.salle!.nom;
      _capaciteController.text = widget.salle!.capacite.toString();
      _equipementsController.text = widget.salle!.equipements.join(', ');
      _disponible = widget.salle!.disponible;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _capaciteController.dispose();
    _equipementsController.dispose();
    super.dispose();
  }

  Future<void> _saveSalle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<SalleProvider>(context, listen: false);
      final salle = Salle(
        id: widget.salle?.id ?? _uuid.v4(),
        nom: _nomController.text.trim(),
        capacite: int.parse(_capaciteController.text.trim()),
        equipements: _equipementsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        disponible: _disponible,
      );

      if (widget.salle == null) {
        await provider.addSalle(salle);
        Helpers.showSnackBar(context, 'Salle ajoutée avec succès');
      } else {
        await provider.updateSalle(salle);
        Helpers.showSnackBar(context, 'Salle modifiée avec succès');
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
          widget.salle == null 
            ? 'Ajouter une salle' 
            : 'Modifier la salle',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(
                label: 'Nom de la salle',
                controller: _nomController,
                validator: (value) => Validators.validateRequired(value, fieldName: 'Le nom'),
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Capacité (nombre de places)',
                controller: _capaciteController,
                keyboardType: TextInputType.number,
                validator: Validators.validateNumber,
              ),
              const SizedBox(height: 16),

              CustomInput(
                label: 'Équipements (séparés par des virgules)',
                controller: _equipementsController,
                maxLines: 2,
                minLines: 2,
                hintText: 'Ex: Projecteur, Tableau, Micro, Ordinateur',
              ),
              const SizedBox(height: 16),

              // Switch pour disponibilité
              Row(
                children: [
                  Switch(
                    value: _disponible,
                    onChanged: (value) {
                      setState(() {
                        _disponible = value;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Salle disponible',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: widget.salle == null ? 'Ajouter' : 'Modifier',
                onPressed: _saveSalle,
                loading: _isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}