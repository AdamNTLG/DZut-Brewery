import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/beer_styles.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../widgets/brewing/style_gauge.dart';
import '../../widgets/common/app_text_field.dart';

/// Page de formulaire pour créer/modifier une recette
class RecipeFormPage extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormPage({super.key, this.recipe});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = RecipeService();

  late TextEditingController _nameController;
  late TextEditingController _volumeController;
  late TextEditingController _initialWaterController;
  late TextEditingController _finalWaterController;
  late TextEditingController _boilTimeController;
  late TextEditingController _efficiencyController;
  late TextEditingController _notesController;

  String? _selectedStyle;
  BeerStyle? _selectedBeerStyle;
  bool _isSaving = false;
  bool _styleGuideExpanded = true;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;

    _nameController = TextEditingController(text: r?.name ?? '');
    _volumeController = TextEditingController(
      text: (r?.volumeLiters ?? AppConstants.defaultVolume).toStringAsFixed(0),
    );
    _initialWaterController = TextEditingController(
      text: r?.initialWater?.toStringAsFixed(1) ?? '',
    );
    _finalWaterController = TextEditingController(
      text: r?.finalWater?.toStringAsFixed(1) ?? '',
    );
    _boilTimeController = TextEditingController(
      text: (r?.boilTime ?? AppConstants.defaultBoilTime).toString(),
    );
    _efficiencyController = TextEditingController(
      text: (r?.efficiency ?? AppConstants.defaultEfficiency).toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: r?.notes ?? '');

    _selectedStyle = r?.beerStyle;
    if (_selectedStyle != null) {
      _selectedBeerStyle = BeerStyles.findByName(_selectedStyle!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _volumeController.dispose();
    _initialWaterController.dispose();
    _finalWaterController.dispose();
    _boilTimeController.dispose();
    _efficiencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la recette' : 'Nouvelle recette'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // Section: Style de bière (en premier — guide le brasseur)
            _buildSectionTitle('Style de bière'),
            _buildStyleSelector(),

            // Fiche guide du style (visible si style sélectionné)
            if (_selectedBeerStyle != null) ...[
              const SizedBox(height: AppConstants.paddingM),
              StyleGuideCard(
                style: _selectedBeerStyle!,
                isExpanded: _styleGuideExpanded,
                onToggle: () => setState(
                  () => _styleGuideExpanded = !_styleGuideExpanded,
                ),
              ),
            ],

            const SizedBox(height: AppConstants.paddingL),

            // Section: Informations générales
            _buildSectionTitle('Informations générales'),

            AppTextField(
              label: 'Nom de la bière *',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.paddingL),

            // Section: Volumes
            _buildSectionTitle('Volumes & paramètres'),

            Row(
              children: [
                Expanded(
                  child: AppNumberField(
                    label: 'Volume final (L) *',
                    controller: _volumeController,
                    decimals: 1,
                    min: AppConstants.minVolume,
                    max: AppConstants.maxVolume,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: AppNumberField(
                    label: 'Ébullition (min)',
                    controller: _boilTimeController,
                    decimals: 0,
                    min: 0,
                    max: 180,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingM),

            Row(
              children: [
                Expanded(
                  child: AppNumberField(
                    label: 'Eau initiale (L)',
                    controller: _initialWaterController,
                    decimals: 1,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: AppNumberField(
                    label: 'Efficacité (%)',
                    controller: _efficiencyController,
                    decimals: 0,
                    min: 50,
                    max: 100,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingL),

            // Section: Notes
            _buildSectionTitle('Notes'),

            AppTextField(
              label: 'Notes de brassage',
              controller: _notesController,
              maxLines: 4,
              hint: 'Instructions, remarques, historique...',
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
                    : Text(_isEditing ? 'Mettre à jour' : 'Créer la recette'),
              ),
            ),

            const SizedBox(height: AppConstants.paddingM),

            if (!_isEditing)
              Text(
                'Vous pourrez ajouter les ingrédients après avoir créé la recette.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton de sélection du style
        InkWell(
          onTap: _openStylePicker,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
              border: Border.all(
                color: _selectedBeerStyle != null
                    ? AppConstants.primaryColor.withValues(alpha: 0.5)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_bar,
                  color: _selectedBeerStyle != null
                      ? AppConstants.primaryColor
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _selectedBeerStyle != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedBeerStyle!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_selectedBeerStyle!.fermentationType ?? ''} · ${_selectedBeerStyle!.category}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : Text(
                          'Choisir un style de bière...',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[500],
                ),
                if (_selectedBeerStyle != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    color: Colors.grey[500],
                    onPressed: () {
                      setState(() {
                        _selectedStyle = null;
                        _selectedBeerStyle = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openStylePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            // Poignée
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Choisir un style',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StyleSelector(
                selectedStyle: _selectedBeerStyle,
                styles: BeerStyles.all,
                onChanged: (style) {
                  setState(() {
                    _selectedBeerStyle = style;
                    _selectedStyle = style?.name;
                    _styleGuideExpanded = true;
                  });
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  int? _parseInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final recipe = Recipe(
        id: widget.recipe?.id,
        name: _nameController.text.trim(),
        beerStyle: _selectedStyle,
        volumeLiters:
            _parseDouble(_volumeController.text) ?? AppConstants.defaultVolume,
        initialWater: _parseDouble(_initialWaterController.text),
        finalWater: _parseDouble(_finalWaterController.text),
        targetOg: widget.recipe?.targetOg,
        targetFg: widget.recipe?.targetFg,
        targetIbu: widget.recipe?.targetIbu,
        targetEbc: widget.recipe?.targetEbc,
        targetAbv: widget.recipe?.targetAbv,
        boilTime: _parseInt(_boilTimeController.text) ??
            AppConstants.defaultBoilTime,
        efficiency: _parseDouble(_efficiencyController.text) ??
            AppConstants.defaultEfficiency,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (_isEditing) {
        await _service.update(recipe);
        await _service.recalculateStats(recipe.id);
      } else {
        await _service.create(recipe);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(_isEditing ? 'Recette modifiée' : 'Recette créée')),
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
}
