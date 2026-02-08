import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/fermenter.dart';
import '../../services/fermenter_service.dart';
import '../../widgets/common/app_text_field.dart';

/// Page de formulaire pour créer/modifier un fermenteur
class FermenterFormPage extends StatefulWidget {
  final Fermenter? fermenter;

  const FermenterFormPage({super.key, this.fermenter});

  @override
  State<FermenterFormPage> createState() => _FermenterFormPageState();
}

class _FermenterFormPageState extends State<FermenterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = FermenterService();
  
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _notesController;
  
  FermenterMaterial _material = FermenterMaterial.plastic;
  bool _isAvailable = true;
  bool _isSaving = false;

  bool get _isEditing => widget.fermenter != null;

  @override
  void initState() {
    super.initState();
    final f = widget.fermenter;
    
    _nameController = TextEditingController(text: f?.name ?? '');
    _capacityController = TextEditingController(
      text: f?.capacityLiters.toStringAsFixed(0) ?? '30',
    );
    _notesController = TextEditingController(text: f?.notes ?? '');
    
    if (f != null) {
      _material = f.material ?? FermenterMaterial.plastic;
      _isAvailable = f.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le fermenteur' : 'Nouveau fermenteur'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // Nom
            AppTextField(
              label: 'Nom *',
              controller: _nameController,
              hint: 'Ex: Fermenteur principal, Cuve inox...',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Capacité et matériau
            Row(
              children: [
                Expanded(
                  child: AppNumberField(
                    label: 'Capacité (L) *',
                    controller: _capacityController,
                    decimals: 0,
                    min: 1,
                    max: 10000,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: AppDropdown<FermenterMaterial>(
                    label: 'Matériau',
                    value: _material,
                    items: FermenterMaterial.values.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _material = value!);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Disponibilité
            SwitchListTile(
              title: const Text('Disponible'),
              subtitle: Text(
                _isAvailable 
                    ? 'Peut être utilisé pour un nouveau brassin'
                    : 'Actuellement occupé',
              ),
              value: _isAvailable,
              onChanged: (value) {
                setState(() => _isAvailable = value);
              },
              activeThumbColor: AppConstants.primaryColor,
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Notes
            AppTextField(
              label: 'Notes',
              controller: _notesController,
              maxLines: 3,
              hint: 'Emplacement, caractéristiques particulières...',
            ),
            
            const SizedBox(height: AppConstants.paddingXL),
            
            // Bouton de sauvegarde
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Mettre à jour' : 'Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final fermenter = Fermenter(
        id: widget.fermenter?.id,
        name: _nameController.text.trim(),
        capacityLiters: double.tryParse(_capacityController.text) ?? 30,
        material: _material,
        isAvailable: _isAvailable,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      
      if (_isEditing) {
        await _service.update(fermenter);
      } else {
        await _service.create(fermenter);
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Modifié' : 'Créé')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _confirmDelete() async {
    // Vérifier si le fermenteur est utilisé
    final inUse = await _service.isInUse(widget.fermenter!.id);
    
    if (inUse) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce fermenteur est utilisé par un brassin actif'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer "${widget.fermenter!.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(widget.fermenter!.id);
              if (mounted) {
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supprimé')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
