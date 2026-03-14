import 'package:flutter/material.dart' hide MaterialType;
import '../../constants/app_constants.dart';
import '../../constants/beer_styles.dart';
import '../../models/mash_step.dart';
import '../../models/raw_material.dart';
import '../../models/recipe.dart';
import '../../models/recipe_addition.dart';
import '../../models/recipe_grain.dart';
import '../../models/recipe_hop.dart';
import '../../models/recipe_yeast.dart';
import '../../services/calculation_service.dart';
import '../../services/raw_material_service.dart';
import '../../services/recipe_service.dart';
import '../../widgets/brewing/style_gauge.dart';
import '../../widgets/common/app_text_field.dart';

/// Page unifiée création/édition recette + ingrédients
class RecipeEditorPage extends StatefulWidget {
  final String? recipeId;

  const RecipeEditorPage({super.key, this.recipeId});

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipeService = RecipeService();
  final _materialService = RawMaterialService();

  // Saved recipe ID (null = not yet saved to DB)
  String? _recipeId;

  // Loaded complete recipe data
  RecipeComplete? _recipe;
  List<RawMaterial> _materials = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _volumeController;
  late TextEditingController _boilTimeController;
  late TextEditingController _efficiencyController;
  late TextEditingController _initialWaterController;
  late TextEditingController _notesController;

  // Style selection
  String? _selectedStyle;
  BeerStyle? _selectedBeerStyle;
  bool _styleGuideExpanded = true;
  bool _gaugesExpanded = true;

  // Calculated stats
  double? _calculatedOg;
  double? _calculatedFg;
  double? _calculatedIbu;
  double? _calculatedEbc;
  double? _calculatedAbv;

  bool get _isEditing => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    _recipeId = widget.recipeId;

    _nameController = TextEditingController();
    _volumeController = TextEditingController(
      text: AppConstants.defaultVolume.toStringAsFixed(0),
    );
    _boilTimeController = TextEditingController(
      text: AppConstants.defaultBoilTime.toString(),
    );
    _efficiencyController = TextEditingController(
      text: AppConstants.defaultEfficiency.toStringAsFixed(0),
    );
    _initialWaterController = TextEditingController();
    _notesController = TextEditingController();

    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _volumeController.dispose();
    _boilTimeController.dispose();
    _efficiencyController.dispose();
    _initialWaterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final materials = await _materialService.getAll();

      RecipeComplete? recipe;
      if (_recipeId != null) {
        recipe = await _recipeService.getComplete(_recipeId!);
        if (recipe != null) {
          final r = recipe.recipe;
          _nameController.text = r.name;
          _volumeController.text = r.volumeLiters.toStringAsFixed(0);
          _boilTimeController.text = r.boilTime.toString();
          _efficiencyController.text = r.efficiency.toStringAsFixed(0);
          _initialWaterController.text = r.initialWater?.toStringAsFixed(1) ?? '';
          _notesController.text = r.notes ?? '';
          _selectedStyle = r.beerStyle;
          if (_selectedStyle != null) {
            _selectedBeerStyle = BeerStyles.findByName(_selectedStyle!);
          }
        }
      }

      setState(() {
        _recipe = recipe;
        _materials = materials;
        _isLoading = false;
      });

      if (recipe != null) _recalculate();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _recalculate() {
    if (_recipe == null) return;
    final r = _recipe!;

    final volume =
        double.tryParse(_volumeController.text) ?? AppConstants.defaultVolume;
    final efficiency =
        double.tryParse(_efficiencyController.text) ??
        AppConstants.defaultEfficiency;

    final og = CalculationService.calculateOG(
      grains: r.grains,
      volumeLiters: volume,
      efficiency: efficiency,
    );
    final attenuation =
        r.yeasts.isNotEmpty
            ? (r.yeasts.first.materialAttenuation ?? 75.0)
            : 75.0;
    final fg = CalculationService.estimateFG(og, attenuation);
    final ibu = CalculationService.calculateIBU(
      hops: r.hops,
      volumeLiters: volume,
      og: og,
    );
    final ebc = CalculationService.calculateEBC(
      grains: r.grains,
      volumeLiters: volume,
    );
    final abv = CalculationService.calculateAbv(og, fg);

    setState(() {
      _calculatedOg = og;
      _calculatedFg = fg;
      _calculatedIbu = ibu;
      _calculatedEbc = ebc;
      _calculatedAbv = abv;
    });
  }

  // ── Ensure recipe is saved before adding ingredients ──────────────────────

  /// Returns true if the recipe is ready (has a DB record).
  /// Creates a draft if not yet saved. Returns false if validation fails.
  Future<bool> _ensureSaved() async {
    if (_recipeId != null) return true;

    if (!_formKey.currentState!.validate()) return false;

    try {
      final recipe = Recipe(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Brouillon',
        beerStyle: _selectedStyle,
        volumeLiters:
            double.tryParse(_volumeController.text) ??
            AppConstants.defaultVolume,
        initialWater: double.tryParse(
          _initialWaterController.text.replaceAll(',', '.'),
        ),
        boilTime:
            int.tryParse(_boilTimeController.text) ??
            AppConstants.defaultBoilTime,
        efficiency:
            double.tryParse(_efficiencyController.text) ??
            AppConstants.defaultEfficiency,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      final saved = await _recipeService.create(recipe);
      _recipeId = saved.id;

      // Reload to get full RecipeComplete
      final complete = await _recipeService.getComplete(_recipeId!);
      setState(() => _recipe = complete);
      _recalculate();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de sauvegarder: $e')),
        );
      }
      return false;
    }
  }

  // ── Save recipe metadata ───────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final recipe = Recipe(
        id: _recipeId,
        name: _nameController.text.trim(),
        beerStyle: _selectedStyle,
        volumeLiters:
            double.tryParse(_volumeController.text) ??
            AppConstants.defaultVolume,
        initialWater: double.tryParse(
          _initialWaterController.text.replaceAll(',', '.'),
        ),
        boilTime:
            int.tryParse(_boilTimeController.text) ??
            AppConstants.defaultBoilTime,
        efficiency:
            double.tryParse(_efficiencyController.text) ??
            AppConstants.defaultEfficiency,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        targetOg: _recipe?.recipe.targetOg,
        targetFg: _recipe?.recipe.targetFg,
        targetIbu: _recipe?.recipe.targetIbu,
        targetEbc: _recipe?.recipe.targetEbc,
        targetAbv: _recipe?.recipe.targetAbv,
      );

      if (_recipeId != null) {
        await _recipeService.update(recipe);
        await _recipeService.recalculateStats(recipe.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recette mise à jour')),
          );
        }
      } else {
        final saved = await _recipeService.create(recipe);
        _recipeId = saved.id;
        final complete = await _recipeService.getComplete(_recipeId!);
        setState(() => _recipe = complete);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recette créée')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la recette' : 'Nouvelle recette'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Sauvegarder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(
                  left: AppConstants.paddingM,
                  right: AppConstants.paddingM,
                  top: AppConstants.paddingM,
                  bottom: 80,
                ),
                children: [
                  // ── Style de bière ─────────────────────────────────────
                  _buildSectionHeader('Style de bière', '🍺'),
                  const SizedBox(height: AppConstants.paddingS),
                  _buildStyleSelector(),

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

                  // ── Jauges live ────────────────────────────────────────
                  if (_selectedBeerStyle != null &&
                      _recipe != null &&
                      (_calculatedOg ?? 0) > 1.0) ...[
                    const SizedBox(height: AppConstants.paddingM),
                    _buildGaugesCard(),
                  ],

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Paramètres recette ─────────────────────────────────
                  _buildSectionHeader('Paramètres', '⚙️'),
                  const SizedBox(height: AppConstants.paddingS),

                  AppTextField(
                    label: 'Nom de la bière *',
                    controller: _nameController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Le nom est requis'
                            : null,
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  Row(
                    children: [
                      Expanded(
                        child: AppNumberField(
                          label: 'Volume final (L) *',
                          controller: _volumeController,
                          decimals: 1,
                          min: AppConstants.minVolume,
                          max: AppConstants.maxVolume,
                          onChanged: (_) => _recalculate(),
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
                          onChanged: (_) => _recalculate(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  AppTextField(
                    label: 'Notes',
                    controller: _notesController,
                    maxLines: 3,
                    hint: 'Instructions, remarques, historique...',
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Céréales & Sucres ──────────────────────────────────
                  _buildSectionHeader(
                    'Céréales & Sucres',
                    '🌾',
                    onAdd: () => _addGrain(),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),

                  // Mash steps (collapsible sub-section)
                  if (_recipe != null && _recipe!.mashSteps.isNotEmpty) ...[
                    _buildSubSectionLabel('Empâtage'),
                    ..._recipe!.mashSteps.asMap().entries.map(
                      (e) => _buildMashStepTile(e.value, e.key),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                  ],

                  // Grains
                  if (_recipe != null && _recipe!.grains.isNotEmpty) ...[
                    _buildSubSectionLabel(
                      'Malts (${_recipe!.totalGrainsKg.toStringAsFixed(2)} kg)',
                    ),
                    ..._recipe!.grains.map(
                      (g) => _buildGrainTile(g),
                    ),
                  ],

                  if (_recipe == null ||
                      (_recipe!.grains.isEmpty &&
                          _recipe!.mashSteps.isEmpty))
                    _buildEmptyHint(
                      'Aucune céréale',
                      'Appuyez sur + pour ajouter',
                    ),

                  _buildAddRowButton(
                    'Ajouter un malt',
                    AppConstants.grainColor,
                    () => _addGrain(),
                  ),

                  const SizedBox(height: AppConstants.paddingS),
                  _buildAddRowButton(
                    'Ajouter un palier d\'empâtage',
                    AppConstants.primaryColor,
                    () => _addMashStep(),
                    icon: Icons.thermostat,
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Houblons ───────────────────────────────────────────
                  _buildSectionHeader(
                    'Houblons',
                    '🌿',
                    onAdd: () => _addHop(),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),

                  if (_recipe != null && _recipe!.hops.isNotEmpty) ...[
                    // Ébullition
                    ..._buildHopSubSection(
                      HopUse.boil,
                      'Ébullition',
                      () => _addHopWithUse(HopUse.boil),
                    ),
                    // Aromatique / Whirlpool
                    ..._buildHopSubSection(
                      HopUse.whirlpool,
                      'Aromatique (Hors flamme)',
                      () => _addHopWithUse(HopUse.whirlpool),
                    ),
                    // Dry Hopping
                    ..._buildHopSubSection(
                      HopUse.dryHop,
                      'Dry Hopping',
                      () => _addHopWithUse(HopUse.dryHop),
                    ),
                  ],

                  if (_recipe == null || _recipe!.hops.isEmpty)
                    _buildEmptyHint('Aucun houblon', 'Appuyez sur + pour ajouter'),

                  _buildAddRowButton(
                    'Ajouter un houblon',
                    AppConstants.hopColor,
                    () => _addHop(),
                    icon: Icons.eco,
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Levures ────────────────────────────────────────────
                  _buildSectionHeader(
                    'Levures',
                    '🧫',
                    onAdd: () => _addYeast(),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),

                  if (_recipe != null && _recipe!.yeasts.isNotEmpty) ...[
                    ..._recipe!.yeasts.map((y) => _buildYeastTile(y)),
                  ],

                  if (_recipe == null || _recipe!.yeasts.isEmpty)
                    _buildEmptyHint('Aucune levure', 'Appuyez sur + pour ajouter'),

                  _buildAddRowButton(
                    'Ajouter une levure',
                    AppConstants.yeastColor,
                    () => _addYeast(),
                    icon: Icons.bubble_chart,
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Divers ─────────────────────────────────────────────
                  _buildSectionHeader(
                    'Divers',
                    '➕',
                    onAdd: () => _addAddition(),
                  ),
                  const SizedBox(height: AppConstants.paddingXS),

                  if (_recipe != null && _recipe!.additions.isNotEmpty) ...[
                    ..._recipe!.additions.map((a) => _buildAdditionTile(a)),
                  ],

                  if (_recipe == null || _recipe!.additions.isEmpty)
                    _buildEmptyHint(
                      'Aucun autre ingrédient',
                      'Appuyez sur + pour ajouter',
                    ),

                  _buildAddRowButton(
                    'Ajouter un ingrédient',
                    Colors.grey,
                    () => _addAddition(),
                  ),
                ],
              ),
            ),
    );
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String emoji, {VoidCallback? onAdd}) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const Spacer(),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppConstants.primaryColor,
            onPressed: onAdd,
            tooltip: 'Ajouter',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildSubSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppConstants.paddingS,
        bottom: AppConstants.paddingXS,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyHint(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Row(
        children: [
          Icon(Icons.add_circle_outline, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRowButton(
    String label,
    Color color,
    VoidCallback onTap, {
    IconData icon = Icons.grain,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.add, size: 16, color: color.withValues(alpha: 0.8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugesCard() {
    final hasValues = (_calculatedOg ?? 0) > 1.0;
    if (!hasValues || _selectedBeerStyle == null) return const SizedBox.shrink();

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _gaugesExpanded = !_gaugesExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('OG', _calculatedOg!.toStringAsFixed(3),
                    _selectedBeerStyle?.isOgInRange(_calculatedOg)),
                _buildStatChip('FG', _calculatedFg!.toStringAsFixed(3),
                    _selectedBeerStyle?.isFgInRange(_calculatedFg)),
                _buildStatChip('IBU', _calculatedIbu!.toStringAsFixed(0),
                    _selectedBeerStyle?.isIbuInRange(_calculatedIbu)),
                _buildStatChip('EBC', _calculatedEbc!.toStringAsFixed(0),
                    _selectedBeerStyle?.isEbcInRange(_calculatedEbc)),
                _buildStatChip('ABV', '${_calculatedAbv!.toStringAsFixed(1)}%',
                    _selectedBeerStyle?.isAbvInRange(_calculatedAbv)),
                AnimatedRotation(
                  turns: _gaugesExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more,
                    size: 20,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_gaugesExpanded)
          StyleGaugesCard(
            style: _selectedBeerStyle!,
            og: _calculatedOg,
            fg: _calculatedFg,
            ibu: _calculatedIbu,
            ebc: _calculatedEbc,
            abv: _calculatedAbv,
            showAllGauges: false,
          ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, bool? inRange) {
    Color valueColor;
    if (inRange == null) {
      valueColor = AppConstants.textColor;
    } else {
      valueColor = inRange ? AppConstants.successColor : AppConstants.errorColor;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: valueColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  // ── Style selector ─────────────────────────────────────────────────────────

  Widget _buildStyleSelector() {
    return InkWell(
      onTap: _openStylePicker,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingM,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
            if (_selectedBeerStyle != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                color: Colors.grey[500],
                onPressed: () => setState(() {
                  _selectedStyle = null;
                  _selectedBeerStyle = null;
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  // ── Ingredient tiles ───────────────────────────────────────────────────────

  Widget _buildMashStepTile(MashStep step, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingXS),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: AppConstants.primaryColor,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(step.description ?? 'Palier ${index + 1}'),
        subtitle: Text(
          '${step.temperature.toStringAsFixed(0)}°C • ${step.durationMin} min',
        ),
        trailing: _buildEditDeleteRow(
          () => _editMashStep(step),
          () => _deleteMashStep(step),
        ),
      ),
    );
  }

  Widget _buildGrainTile(RecipeGrain grain) {
    final totalKg = _recipe?.totalGrainsKg ?? 0;
    final pct = grain.percentageOf(totalKg);
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingXS),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: AppConstants.grainColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(grain.materialName ?? 'Malt inconnu'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${grain.quantityKg.toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.grainColor,
              ),
            ),
            Text(
              '  ${pct.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            ..._editDeleteButtons(
              () => _editGrain(grain),
              () => _deleteGrain(grain),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHopSubSection(
    HopUse use,
    String label,
    VoidCallback onAdd,
  ) {
    final hops = _recipe!.hops.where((h) => h.hopUse == use).toList();
    if (hops.isEmpty) return [];
    return [
      _buildSubSectionLabel(label),
      ...hops.map((h) => _buildHopTile(h)),
    ];
  }

  Widget _buildHopTile(RecipeHop hop) {
    final timeLabel = hop.hopUse == HopUse.dryHop
        ? '${hop.timeValue.toStringAsFixed(0)} ${hop.hopUse.timeUnit} avant fin'
        : '${hop.timeValue.toStringAsFixed(0)} ${hop.hopUse.timeUnit}';
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingXS),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: AppConstants.hopColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(hop.materialName ?? 'Houblon inconnu'),
        subtitle: Text(timeLabel),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${hop.quantityG.toStringAsFixed(0)} g',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.hopColor,
              ),
            ),
            ..._editDeleteButtons(
              () => _editHop(hop),
              () => _deleteHop(hop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYeastTile(RecipeYeast yeast) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingXS),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: AppConstants.yeastColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(yeast.materialName ?? 'Levure inconnue'),
        subtitle: Text(yeast.form.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${yeast.quantity.toStringAsFixed(0)} ${yeast.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._editDeleteButtons(
              () => _editYeast(yeast),
              () => _deleteYeast(yeast),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionTile(RecipeAddition addition) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingXS),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            addition.additionStep.label,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        title: Text(addition.materialName ?? 'Ingrédient inconnu'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${addition.quantity.toStringAsFixed(1)} ${addition.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._editDeleteButtons(
              () => _editAddition(addition),
              () => _deleteAddition(addition),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditDeleteRow(VoidCallback onEdit, VoidCallback onDelete) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _editDeleteButtons(onEdit, onDelete),
    );
  }

  List<Widget> _editDeleteButtons(VoidCallback onEdit, VoidCallback onDelete) {
    return [
      IconButton(
        icon: const Icon(Icons.edit, size: 18),
        color: Colors.grey[600],
        onPressed: onEdit,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: Colors.red[300],
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    ];
  }

  // ── Ingredient actions ─────────────────────────────────────────────────────

  List<RawMaterial> _getMaterialsByType(MaterialType type) =>
      _materials.where((m) => m.type == type).toList();

  Future<void> _reloadIngredients() async {
    if (_recipeId == null) return;
    final recipe = await _recipeService.getComplete(_recipeId!);
    setState(() => _recipe = recipe);
    _recalculate();
    // Persist calculated stats
    if (_recipe != null) {
      await _recipeService.update(_recipe!.recipe.copyWith(
        targetOg: _calculatedOg,
        targetFg: _calculatedFg,
        targetIbu: _calculatedIbu,
        targetEbc: _calculatedEbc,
        targetAbv: _calculatedAbv,
      ));
    }
  }

  // Mash steps ----------------------------------------------------------------
  Future<void> _addMashStep() async {
    if (!await _ensureSaved()) return;
    final result = await _showMashStepDialog(null);
    if (result != null) {
      await _recipeService.addMashStep(result);
      _reloadIngredients();
    }
  }

  Future<void> _editMashStep(MashStep step) async {
    final result = await _showMashStepDialog(step);
    if (result != null) {
      await _recipeService.updateMashStep(result);
      _reloadIngredients();
    }
  }

  Future<void> _deleteMashStep(MashStep step) async {
    if (await _confirmDelete('ce palier d\'empâtage')) {
      await _recipeService.deleteMashStep(step.id);
      _reloadIngredients();
    }
  }

  Future<MashStep?> _showMashStepDialog(MashStep? existing) async {
    final tempController = TextEditingController(
      text: existing?.temperature.toStringAsFixed(0) ?? '67',
    );
    final durationController = TextEditingController(
      text: existing?.durationMin.toString() ?? '60',
    );
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );

    return showDialog<MashStep>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Ajouter un palier' : 'Modifier le palier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Description', controller: descController),
              const SizedBox(height: AppConstants.paddingM),
              Row(
                children: [
                  Expanded(
                    child: AppNumberField(
                      label: 'Température (°C)',
                      controller: tempController,
                      decimals: 0,
                      min: 20,
                      max: 100,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: AppNumberField(
                      label: 'Durée (min)',
                      controller: durationController,
                      decimals: 0,
                      min: 1,
                      max: 120,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              MashStep(
                id: existing?.id,
                recipeId: _recipeId!,
                stepOrder: existing?.stepOrder ?? (_recipe?.mashSteps.length ?? 0) + 1,
                temperature: double.tryParse(tempController.text) ?? 67,
                durationMin: int.tryParse(durationController.text) ?? 60,
                description: descController.text.trim().isNotEmpty
                    ? descController.text.trim()
                    : null,
              ),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // Grains --------------------------------------------------------------------
  Future<void> _addGrain() async {
    final grains = _getMaterialsByType(MaterialType.grain);
    if (grains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun malt disponible. Ajoutez-en d\'abord dans Stock.'),
        ),
      );
      return;
    }
    if (!await _ensureSaved()) return;
    final result = await _showGrainDialog(null, grains);
    if (result != null) {
      await _recipeService.addGrain(result);
      _reloadIngredients();
    }
  }

  Future<void> _editGrain(RecipeGrain grain) async {
    final grains = _getMaterialsByType(MaterialType.grain);
    final result = await _showGrainDialog(grain, grains);
    if (result != null) {
      await _recipeService.updateGrain(result);
      _reloadIngredients();
    }
  }

  Future<void> _deleteGrain(RecipeGrain grain) async {
    if (await _confirmDelete('ce malt')) {
      await _recipeService.deleteGrain(grain.id);
      _reloadIngredients();
    }
  }

  Future<RecipeGrain?> _showGrainDialog(
    RecipeGrain? existing,
    List<RawMaterial> materials,
  ) async {
    RawMaterial? selected = existing != null
        ? materials.firstWhere(
            (m) => m.id == existing.materialId,
            orElse: () => materials.first,
          )
        : null;
    final qtyController = TextEditingController(
      text: existing?.quantityKg.toStringAsFixed(2) ?? '1.00',
    );

    return showDialog<RecipeGrain>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(existing == null ? 'Ajouter un malt' : 'Modifier le malt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RawMaterial>(
                  initialValue: selected,
                  hint: const Text('Sélectionner un malt'),
                  items: materials
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                  onChanged: (m) => setS(() => selected = m),
                  decoration: const InputDecoration(labelText: 'Malt'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                AppNumberField(
                  label: 'Quantité (kg)',
                  controller: qtyController,
                  decimals: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(
                        context,
                        RecipeGrain(
                          id: existing?.id,
                          recipeId: _recipeId!,
                          materialId: selected!.id,
                          quantityKg:
                              double.tryParse(qtyController.text) ?? 1.0,
                        ),
                      ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // Hops ----------------------------------------------------------------------
  Future<void> _addHop() => _addHopWithUse(HopUse.boil);

  Future<void> _addHopWithUse(HopUse defaultUse) async {
    final hops = _getMaterialsByType(MaterialType.hop);
    if (hops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucun houblon disponible. Ajoutez-en d\'abord dans Stock.',
          ),
        ),
      );
      return;
    }
    if (!await _ensureSaved()) return;
    final result = await _showHopDialog(null, hops, defaultUse: defaultUse);
    if (result != null) {
      await _recipeService.addHop(result);
      _reloadIngredients();
    }
  }

  Future<void> _editHop(RecipeHop hop) async {
    final hops = _getMaterialsByType(MaterialType.hop);
    final result = await _showHopDialog(hop, hops);
    if (result != null) {
      await _recipeService.updateHop(result);
      _reloadIngredients();
    }
  }

  Future<void> _deleteHop(RecipeHop hop) async {
    if (await _confirmDelete('ce houblon')) {
      await _recipeService.deleteHop(hop.id);
      _reloadIngredients();
    }
  }

  Future<RecipeHop?> _showHopDialog(
    RecipeHop? existing,
    List<RawMaterial> materials, {
    HopUse defaultUse = HopUse.boil,
  }) async {
    RawMaterial? selected = existing != null
        ? materials.firstWhere(
            (m) => m.id == existing.materialId,
            orElse: () => materials.first,
          )
        : null;
    final qtyController = TextEditingController(
      text: existing?.quantityG.toStringAsFixed(0) ?? '30',
    );
    final timeController = TextEditingController(
      text: existing?.timeValue.toStringAsFixed(0) ?? '60',
    );
    final tempController = TextEditingController(
      text: existing?.temperature?.toStringAsFixed(0) ?? '80',
    );
    HopUse hopUse = existing?.hopUse ?? defaultUse;

    return showDialog<RecipeHop>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(
            existing == null ? 'Ajouter un houblon' : 'Modifier le houblon',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RawMaterial>(
                  initialValue: selected,
                  hint: const Text('Sélectionner un houblon'),
                  items: materials
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text('${m.name} (${m.alphaAcid}% AA)'),
                        ),
                      )
                      .toList(),
                  onChanged: (m) => setS(() => selected = m),
                  decoration: const InputDecoration(labelText: 'Houblon'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<HopUse>(
                  initialValue: hopUse,
                  items: HopUse.values
                      .map(
                        (u) => DropdownMenuItem(value: u, child: Text(u.label)),
                      )
                      .toList(),
                  onChanged: (u) {
                    setS(() {
                      hopUse = u!;
                      if (u == HopUse.dryHop) {
                        timeController.text =
                            existing?.hopUse == HopUse.dryHop
                                ? existing!.timeValue.toStringAsFixed(0)
                                : '3';
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Utilisation'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: AppNumberField(
                        label: 'Quantité (g)',
                        controller: qtyController,
                        decimals: 0,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: AppNumberField(
                        label: hopUse == HopUse.dryHop
                            ? 'Jours avant fin'
                            : 'Temps (${hopUse.timeUnit})',
                        controller: timeController,
                        decimals: 0,
                      ),
                    ),
                  ],
                ),
                if (hopUse == HopUse.whirlpool) ...[
                  const SizedBox(height: AppConstants.paddingM),
                  AppNumberField(
                    label: 'Température (°C)',
                    controller: tempController,
                    decimals: 0,
                    hint: '80',
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(
                        context,
                        RecipeHop(
                          id: existing?.id,
                          recipeId: _recipeId!,
                          materialId: selected!.id,
                          quantityG: double.tryParse(qtyController.text) ?? 30,
                          hopUse: hopUse,
                          timeValue:
                              double.tryParse(timeController.text) ?? 60,
                          temperature: hopUse == HopUse.whirlpool
                              ? (double.tryParse(tempController.text) ?? 80.0)
                              : hopUse.defaultTemperature,
                        ),
                      ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // Yeasts --------------------------------------------------------------------
  Future<void> _addYeast() async {
    final yeasts = _getMaterialsByType(MaterialType.yeast);
    if (yeasts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune levure disponible. Ajoutez-en d\'abord dans Stock.',
          ),
        ),
      );
      return;
    }
    if (!await _ensureSaved()) return;
    final result = await _showYeastDialog(null, yeasts);
    if (result != null) {
      await _recipeService.addYeast(result);
      _reloadIngredients();
    }
  }

  Future<void> _editYeast(RecipeYeast yeast) async {
    final yeasts = _getMaterialsByType(MaterialType.yeast);
    final result = await _showYeastDialog(yeast, yeasts);
    if (result != null) {
      await _recipeService.updateYeast(result);
      _reloadIngredients();
    }
  }

  Future<void> _deleteYeast(RecipeYeast yeast) async {
    if (await _confirmDelete('cette levure')) {
      await _recipeService.deleteYeast(yeast.id);
      _reloadIngredients();
    }
  }

  Future<RecipeYeast?> _showYeastDialog(
    RecipeYeast? existing,
    List<RawMaterial> materials,
  ) async {
    RawMaterial? selected = existing != null
        ? materials.firstWhere(
            (m) => m.id == existing.materialId,
            orElse: () => materials.first,
          )
        : null;
    final qtyController = TextEditingController(
      text: existing?.quantity.toStringAsFixed(0) ?? '11',
    );
    String unit = existing?.unit ?? 'g';

    return showDialog<RecipeYeast>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(
            existing == null ? 'Ajouter une levure' : 'Modifier la levure',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RawMaterial>(
                  initialValue: selected,
                  hint: const Text('Sélectionner une levure'),
                  items: materials
                      .map(
                        (m) =>
                            DropdownMenuItem(value: m, child: Text(m.name)),
                      )
                      .toList(),
                  onChanged: (m) => setS(() => selected = m),
                  decoration: const InputDecoration(labelText: 'Levure'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: AppNumberField(
                        label: 'Quantité',
                        controller: qtyController,
                        decimals: 0,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('grammes')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(
                            value: 'sachet',
                            child: Text('sachet'),
                          ),
                        ],
                        onChanged: (u) => setS(() => unit = u!),
                        decoration: const InputDecoration(labelText: 'Unité'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(
                        context,
                        RecipeYeast(
                          id: existing?.id,
                          recipeId: _recipeId!,
                          materialId: selected!.id,
                          quantity: double.tryParse(qtyController.text) ?? 11,
                          unit: unit,
                          form: selected!.form ?? YeastForm.dry,
                        ),
                      ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // Additions -----------------------------------------------------------------
  Future<void> _addAddition() async {
    if (!await _ensureSaved()) return;
    final others = _getMaterialsByType(MaterialType.other);
    final result = await _showAdditionDialog(null, others);
    if (result != null) {
      await _recipeService.addAddition(result);
      _reloadIngredients();
    }
  }

  Future<void> _editAddition(RecipeAddition addition) async {
    final others = _getMaterialsByType(MaterialType.other);
    final result = await _showAdditionDialog(addition, others);
    if (result != null) {
      await _recipeService.updateAddition(result);
      _reloadIngredients();
    }
  }

  Future<void> _deleteAddition(RecipeAddition addition) async {
    if (await _confirmDelete('cet ajout')) {
      await _recipeService.deleteAddition(addition.id);
      _reloadIngredients();
    }
  }

  Future<RecipeAddition?> _showAdditionDialog(
    RecipeAddition? existing,
    List<RawMaterial> materials,
  ) async {
    RawMaterial? selected = existing != null && materials.isNotEmpty
        ? materials.firstWhere(
            (m) => m.id == existing.materialId,
            orElse: () => materials.first,
          )
        : null;
    final qtyController = TextEditingController(
      text: existing?.quantity.toStringAsFixed(1) ?? '1.0',
    );
    final nameController = TextEditingController();
    String unit = existing?.unit ?? 'g';
    AdditionStep step = existing?.additionStep ?? AdditionStep.boil;

    return showDialog<RecipeAddition>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(
            existing == null
                ? 'Ajouter un ingrédient'
                : 'Modifier l\'ingrédient',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (materials.isNotEmpty)
                  DropdownButtonFormField<RawMaterial>(
                    initialValue: selected,
                    hint: const Text('Sélectionner (optionnel)'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Autre (saisie manuelle)'),
                      ),
                      ...materials.map(
                        (m) =>
                            DropdownMenuItem(value: m, child: Text(m.name)),
                      ),
                    ],
                    onChanged: (m) => setS(() => selected = m),
                    decoration: const InputDecoration(labelText: 'Ingrédient'),
                  ),
                if (selected == null) ...[
                  const SizedBox(height: AppConstants.paddingM),
                  AppTextField(
                    label: 'Nom de l\'ingrédient',
                    controller: nameController,
                  ),
                ],
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<AdditionStep>(
                  initialValue: step,
                  items: AdditionStep.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (s) => setS(() => step = s!),
                  decoration: const InputDecoration(labelText: 'Étape'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: AppNumberField(
                        label: 'Quantité',
                        controller: qtyController,
                        decimals: 1,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(
                            value: 'unité',
                            child: Text('unité'),
                          ),
                        ],
                        onChanged: (u) => setS(() => unit = u!),
                        decoration: const InputDecoration(labelText: 'Unité'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                RecipeAddition(
                  id: existing?.id,
                  recipeId: _recipeId!,
                  materialId: selected?.id ?? '',
                  quantity: double.tryParse(qtyController.text) ?? 1.0,
                  unit: unit,
                  additionStep: step,
                ),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<bool> _confirmDelete(String item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer $item ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
