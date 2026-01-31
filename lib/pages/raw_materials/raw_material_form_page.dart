import 'package:flutter/material.dart' hide MaterialType;
import '../../constants/app_constants.dart';
import '../../models/raw_material.dart';
import '../../services/raw_material_service.dart';
import '../../widgets/common/app_text_field.dart';

/// Page de formulaire pour créer/modifier une matière première
class RawMaterialFormPage extends StatefulWidget {
  final RawMaterial? material;

  const RawMaterialFormPage({super.key, this.material});

  @override
  State<RawMaterialFormPage> createState() => _RawMaterialFormPageState();
}

class _RawMaterialFormPageState extends State<RawMaterialFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = RawMaterialService();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  
  // Champs spécifiques
  late TextEditingController _ebcController;
  late TextEditingController _potentialController;
  late TextEditingController _alphaAcidController;
  late TextEditingController _attenuationController;
  
  MaterialType _type = MaterialType.grain;
  YeastForm _yeastForm = YeastForm.dry;
  String _unit = 'kg';
  bool _isSaving = false;

  bool get _isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    final m = widget.material;
    
    _nameController = TextEditingController(text: m?.name ?? '');
    _priceController = TextEditingController(
      text: m?.price != null ? m!.price.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: m?.notes ?? '');
    
    _ebcController = TextEditingController(
      text: m?.ebc?.toStringAsFixed(1) ?? '',
    );
    _potentialController = TextEditingController(
      text: m?.potential?.toStringAsFixed(0) ?? '',
    );
    _alphaAcidController = TextEditingController(
      text: m?.alphaAcid?.toStringAsFixed(1) ?? '',
    );
    _attenuationController = TextEditingController(
      text: m?.attenuation?.toStringAsFixed(0) ?? '',
    );
    
    if (m != null) {
      _type = m.type;
      _unit = m.unit;
      if (m.form != null) _yeastForm = m.form!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _ebcController.dispose();
    _potentialController.dispose();
    _alphaAcidController.dispose();
    _attenuationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier' : 'Nouvelle matière première'),
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
            // Type de matière première
            AppDropdown<MaterialType>(
              label: 'Type',
              value: _type,
              items: MaterialType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _type = value!;
                  // Mettre à jour l'unité par défaut
                  _unit = _type == MaterialType.hop ? 'g' : 'kg';
                });
              },
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Nom
            AppTextField(
              label: 'Nom *',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Prix et unité
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppNumberField(
                    label: 'Prix',
                    unit: '€',
                    controller: _priceController,
                    decimals: 2,
                    min: 0,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Unité',
                    value: _unit,
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'sachet', child: Text('sachet')),
                      DropdownMenuItem(value: 'unité', child: Text('unité')),
                    ],
                    onChanged: (value) => setState(() => _unit = value!),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingL),
            
            // Champs spécifiques selon le type
            _buildTypeSpecificFields(),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Notes
            AppTextField(
              label: 'Notes',
              controller: _notesController,
              maxLines: 3,
              hint: 'Arômes, utilisations, remarques...',
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

  Widget _buildTypeSpecificFields() {
    switch (_type) {
      case MaterialType.grain:
        return _buildGrainFields();
      case MaterialType.hop:
        return _buildHopFields();
      case MaterialType.yeast:
        return _buildYeastFields();
      case MaterialType.other:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGrainFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques du malt',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: AppNumberField(
                label: 'Couleur EBC',
                controller: _ebcController,
                decimals: 1,
                min: 0,
                max: 1500,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: AppNumberField(
                label: 'Potentiel (PPG)',
                controller: _potentialController,
                decimals: 0,
                min: 0,
                max: 50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHopFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques du houblon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        AppNumberField(
          label: 'Alpha Acid (%)',
          controller: _alphaAcidController,
          decimals: 1,
          min: 0,
          max: 30,
        ),
      ],
    );
  }

  Widget _buildYeastFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques de la levure',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: AppDropdown<YeastForm>(
                label: 'Forme',
                value: _yeastForm,
                items: YeastForm.values.map((form) {
                  return DropdownMenuItem(
                    value: form,
                    child: Text(form.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _yeastForm = value!),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: AppNumberField(
                label: 'Atténuation (%)',
                controller: _attenuationController,
                decimals: 0,
                min: 50,
                max: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final material = RawMaterial(
        id: widget.material?.id,
        name: _nameController.text.trim(),
        type: _type,
        price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
        unit: _unit,
        ebc: _type == MaterialType.grain
            ? double.tryParse(_ebcController.text.replaceAll(',', '.'))
            : null,
        potential: _type == MaterialType.grain
            ? double.tryParse(_potentialController.text.replaceAll(',', '.'))
            : null,
        alphaAcid: _type == MaterialType.hop
            ? double.tryParse(_alphaAcidController.text.replaceAll(',', '.'))
            : null,
        attenuation: _type == MaterialType.yeast
            ? double.tryParse(_attenuationController.text.replaceAll(',', '.'))
            : null,
        form: _type == MaterialType.yeast ? _yeastForm : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      
      if (_isEditing) {
        await _service.update(material);
      } else {
        await _service.create(material);
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Modifié' : 'Créé'),
          ),
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer "${widget.material!.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fermer dialog
              await _service.delete(widget.material!.id);
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
