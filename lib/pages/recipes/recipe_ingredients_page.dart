import 'package:flutter/material.dart' hide MaterialType;
import '../../constants/app_constants.dart';
import '../../models/raw_material.dart';
import '../../models/recipe_grain.dart';
import '../../models/recipe_hop.dart';
import '../../models/recipe_yeast.dart';
import '../../models/recipe_addition.dart';
import '../../models/mash_step.dart';
import '../../services/recipe_service.dart';
import '../../services/raw_material_service.dart';
import '../../widgets/common/app_text_field.dart';

/// Page pour éditer les ingrédients d'une recette
class RecipeIngredientsPage extends StatefulWidget {
  final String recipeId;

  const RecipeIngredientsPage({super.key, required this.recipeId});

  @override
  State<RecipeIngredientsPage> createState() => _RecipeIngredientsPageState();
}

class _RecipeIngredientsPageState extends State<RecipeIngredientsPage>
    with SingleTickerProviderStateMixin {
  final _recipeService = RecipeService();
  final _materialService = RawMaterialService();
  
  late TabController _tabController;
  RecipeComplete? _recipe;
  List<RawMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recipe = await _recipeService.getComplete(widget.recipeId);
      final materials = await _materialService.getAll();
      setState(() {
        _recipe = recipe;
        _materials = materials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  List<RawMaterial> _getMaterialsByType(MaterialType type) {
    return _materials.where((m) => m.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe?.recipe.name ?? 'Ingrédients'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: '🌡️ Empâtage (${_recipe?.mashSteps.length ?? 0})'),
            Tab(text: '🌾 Malts (${_recipe?.grains.length ?? 0})'),
            Tab(text: '🌿 Houblons (${_recipe?.hops.length ?? 0})'),
            Tab(text: '🧫 Levures (${_recipe?.yeasts.length ?? 0})'),
            Tab(text: '➕ Autres (${_recipe?.additions.length ?? 0})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipe == null
              ? const Center(child: Text('Recette non trouvée'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMashStepsTab(),
                    _buildGrainsTab(),
                    _buildHopsTab(),
                    _buildYeastsTab(),
                    _buildAdditionsTab(),
                  ],
                ),
    );
  }

  // === ONGLET EMPÂTAGE ===
  Widget _buildMashStepsTab() {
    final steps = _recipe!.mashSteps;
    
    return Column(
      children: [
        Expanded(
          child: steps.isEmpty
              ? _buildEmptyState('Aucun palier d\'empâtage', Icons.thermostat)
              : ReorderableListView.builder(
                  itemCount: steps.length,
                  onReorder: (oldIndex, newIndex) async {
                    // TODO: Réordonner les paliers
                  },
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return _buildMashStepCard(step, index);
                  },
                ),
        ),
        _buildAddButton('Ajouter un palier', () => _addMashStep()),
      ],
    );
  }

  Widget _buildMashStepCard(MashStep step, int index) {
    return Card(
      key: ValueKey(step.id),
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingXS,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(step.description ?? 'Palier ${index + 1}'),
        subtitle: Text('${step.temperature.toStringAsFixed(0)}°C • ${step.durationMin} min'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editMashStep(step),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteMashStep(step),
            ),
          ],
        ),
      ),
    );
  }

  // === ONGLET GRAINS ===
  Widget _buildGrainsTab() {
    final grains = _recipe!.grains;
    final totalKg = _recipe!.totalGrainsKg;
    
    return Column(
      children: [
        if (grains.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppConstants.grainColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.grain, color: AppConstants.grainColor),
                const SizedBox(width: 8),
                Text(
                  'Total: ${totalKg.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.grainColor,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: grains.isEmpty
              ? _buildEmptyState('Aucun malt', Icons.grain)
              : ListView.builder(
                  itemCount: grains.length,
                  itemBuilder: (context, index) {
                    final grain = grains[index];
                    final pct = grain.percentageOf(totalKg);
                    return _buildIngredientCard(
                      name: grain.materialName ?? 'Malt inconnu',
                      subtitle: '${grain.quantityKg.toStringAsFixed(2)} kg (${pct.toStringAsFixed(1)}%)',
                      color: AppConstants.grainColor,
                      onEdit: () => _editGrain(grain),
                      onDelete: () => _deleteGrain(grain),
                    );
                  },
                ),
        ),
        _buildAddButton('Ajouter un malt', () => _addGrain()),
      ],
    );
  }

  // === ONGLET HOUBLONS ===
  Widget _buildHopsTab() {
    final hops = _recipe!.hops;
    
    return Column(
      children: [
        if (hops.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppConstants.hopColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, color: AppConstants.hopColor),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_recipe!.totalHopsG.toStringAsFixed(0)} g',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.hopColor,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: hops.isEmpty
              ? _buildEmptyState('Aucun houblon', Icons.eco)
              : ListView.builder(
                  itemCount: hops.length,
                  itemBuilder: (context, index) {
                    final hop = hops[index];
                    return _buildIngredientCard(
                      name: hop.materialName ?? 'Houblon inconnu',
                      subtitle: '${hop.quantityG.toStringAsFixed(0)} g • ${hop.hopUse.label} ${hop.timeValue.toStringAsFixed(0)} ${hop.hopUse.timeUnit}',
                      color: AppConstants.hopColor,
                      badge: hop.hopUse.label,
                      onEdit: () => _editHop(hop),
                      onDelete: () => _deleteHop(hop),
                    );
                  },
                ),
        ),
        _buildAddButton('Ajouter un houblon', () => _addHop()),
      ],
    );
  }

  // === ONGLET LEVURES ===
  Widget _buildYeastsTab() {
    final yeasts = _recipe!.yeasts;
    
    return Column(
      children: [
        Expanded(
          child: yeasts.isEmpty
              ? _buildEmptyState('Aucune levure', Icons.bubble_chart)
              : ListView.builder(
                  itemCount: yeasts.length,
                  itemBuilder: (context, index) {
                    final yeast = yeasts[index];
                    return _buildIngredientCard(
                      name: yeast.materialName ?? 'Levure inconnue',
                      subtitle: '${yeast.quantity.toStringAsFixed(0)} ${yeast.unit} • ${yeast.form.label}',
                      color: AppConstants.yeastColor,
                      onEdit: () => _editYeast(yeast),
                      onDelete: () => _deleteYeast(yeast),
                    );
                  },
                ),
        ),
        _buildAddButton('Ajouter une levure', () => _addYeast()),
      ],
    );
  }

  // === ONGLET AJOUTS ===
  Widget _buildAdditionsTab() {
    final additions = _recipe!.additions;
    
    return Column(
      children: [
        Expanded(
          child: additions.isEmpty
              ? _buildEmptyState('Aucun ajout', Icons.add_circle_outline)
              : ListView.builder(
                  itemCount: additions.length,
                  itemBuilder: (context, index) {
                    final addition = additions[index];
                    return _buildIngredientCard(
                      name: addition.materialName ?? 'Ingrédient inconnu',
                      subtitle: '${addition.quantity.toStringAsFixed(1)} ${addition.unit} • ${addition.additionStep.label}',
                      color: AppConstants.otherColor,
                      badge: addition.additionStep.label,
                      onEdit: () => _editAddition(addition),
                      onDelete: () => _deleteAddition(addition),
                    );
                  },
                ),
        ),
        _buildAddButton('Ajouter un ingrédient', () => _addAddition()),
      ],
    );
  }

  // === WIDGETS COMMUNS ===
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.paddingM),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientCard({
    required String name,
    required String subtitle,
    required Color color,
    String? badge,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingXS,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.circle, color: color, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                ),
              ),
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }

  // === ACTIONS EMPÂTAGE ===
  Future<void> _addMashStep() async {
    final result = await _showMashStepDialog(null);
    if (result != null) {
      await _recipeService.addMashStep(result);
      _loadData();
    }
  }

  Future<void> _editMashStep(MashStep step) async {
    final result = await _showMashStepDialog(step);
    if (result != null) {
      await _recipeService.updateMashStep(result);
      _loadData();
    }
  }

  Future<void> _deleteMashStep(MashStep step) async {
    final confirm = await _confirmDelete('ce palier');
    if (confirm) {
      await _recipeService.deleteMashStep(step.id);
      _loadData();
    }
  }

  Future<MashStep?> _showMashStepDialog(MashStep? existing) async {
    final tempController = TextEditingController(text: existing?.temperature.toStringAsFixed(0) ?? '65');
    final durationController = TextEditingController(text: existing?.durationMin.toString() ?? '20');
    final descController = TextEditingController(text: existing?.description ?? '');

    return showDialog<MashStep>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Nouveau palier' : 'Modifier le palier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppNumberField(label: 'Température (°C)', controller: tempController, decimals: 0),
              const SizedBox(height: AppConstants.paddingM),
              AppNumberField(label: 'Durée (min)', controller: durationController, decimals: 0),
              const SizedBox(height: AppConstants.paddingM),
              AppTextField(label: 'Description', controller: descController, hint: 'Ex: Saccharification'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, MashStep(
                id: existing?.id,
                recipeId: widget.recipeId,
                stepOrder: existing?.stepOrder ?? (_recipe!.mashSteps.length + 1),
                temperature: double.tryParse(tempController.text) ?? 65,
                durationMin: int.tryParse(durationController.text) ?? 20,
                description: descController.text.isNotEmpty ? descController.text : null,
              ));
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // === ACTIONS GRAINS ===
  Future<void> _addGrain() async {
    final grains = _getMaterialsByType(MaterialType.grain);
    if (grains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun malt disponible. Ajoutez-en d\'abord dans Stock.')),
      );
      return;
    }
    final result = await _showGrainDialog(null, grains);
    if (result != null) {
      await _recipeService.addGrain(result);
      _loadData();
    }
  }

  Future<void> _editGrain(RecipeGrain grain) async {
    final grains = _getMaterialsByType(MaterialType.grain);
    final result = await _showGrainDialog(grain, grains);
    if (result != null) {
      await _recipeService.updateGrain(result);
      _loadData();
    }
  }

  Future<void> _deleteGrain(RecipeGrain grain) async {
    final confirm = await _confirmDelete('ce malt');
    if (confirm) {
      await _recipeService.deleteGrain(grain.id);
      _loadData();
    }
  }

  Future<RecipeGrain?> _showGrainDialog(RecipeGrain? existing, List<RawMaterial> materials) async {
    RawMaterial? selected = existing != null
        ? materials.firstWhere((m) => m.id == existing.materialId, orElse: () => materials.first)
        : null;
    final qtyController = TextEditingController(text: existing?.quantityKg.toStringAsFixed(2) ?? '1.00');

    return showDialog<RecipeGrain>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Ajouter un malt' : 'Modifier le malt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RawMaterial>(
                  initialValue: selected,
                  hint: const Text('Sélectionner un malt'),
                  items: materials.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (m) => setState(() => selected = m),
                  decoration: const InputDecoration(labelText: 'Malt'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                AppNumberField(label: 'Quantité (kg)', controller: qtyController, decimals: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: selected == null ? null : () {
                Navigator.pop(context, RecipeGrain(
                  id: existing?.id,
                  recipeId: widget.recipeId,
                  materialId: selected!.id,
                  quantityKg: double.tryParse(qtyController.text) ?? 1.0,
                ));
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // === ACTIONS HOUBLONS ===
  Future<void> _addHop() async {
    final hops = _getMaterialsByType(MaterialType.hop);
    if (hops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun houblon disponible. Ajoutez-en d\'abord dans Stock.')),
      );
      return;
    }
    final result = await _showHopDialog(null, hops);
    if (result != null) {
      await _recipeService.addHop(result);
      _loadData();
    }
  }

  Future<void> _editHop(RecipeHop hop) async {
    final hops = _getMaterialsByType(MaterialType.hop);
    final result = await _showHopDialog(hop, hops);
    if (result != null) {
      await _recipeService.updateHop(result);
      _loadData();
    }
  }

  Future<void> _deleteHop(RecipeHop hop) async {
    final confirm = await _confirmDelete('ce houblon');
    if (confirm) {
      await _recipeService.deleteHop(hop.id);
      _loadData();
    }
  }

  Future<RecipeHop?> _showHopDialog(RecipeHop? existing, List<RawMaterial> materials) async {
    RawMaterial? selected = existing != null
        ? materials.firstWhere((m) => m.id == existing.materialId, orElse: () => materials.first)
        : null;
    final qtyController = TextEditingController(text: existing?.quantityG.toStringAsFixed(0) ?? '30');
    final timeController = TextEditingController(text: existing?.timeValue.toStringAsFixed(0) ?? '60');
    HopUse hopUse = existing?.hopUse ?? HopUse.boil;

    return showDialog<RecipeHop>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Ajouter un houblon' : 'Modifier le houblon'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RawMaterial>(
                  initialValue: selected,
                  hint: const Text('Sélectionner un houblon'),
                  items: materials.map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.alphaAcid}% AA)'))).toList(),
                  onChanged: (m) => setState(() => selected = m),
                  decoration: const InputDecoration(labelText: 'Houblon'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<HopUse>(
                  initialValue: hopUse,
                  items: HopUse.values.map((u) => DropdownMenuItem(value: u, child: Text(u.label))).toList(),
                  onChanged: (u) => setState(() => hopUse = u!),
                  decoration: const InputDecoration(labelText: 'Utilisation'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    Expanded(child: AppNumberField(label: 'Quantité (g)', controller: qtyController, decimals: 0)),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(child: AppNumberField(label: 'Temps (${hopUse.timeUnit})', controller: timeController, decimals: 0)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: selected == null ? null : () {
                Navigator.pop(context, RecipeHop(
                  id: existing?.id,
                  recipeId: widget.recipeId,
                  materialId: selected!.id,
                  quantityG: double.tryParse(qtyController.text) ?? 30,
                  hopUse: hopUse,
                  timeValue: double.tryParse(timeController.text) ?? 60,
                  temperature: hopUse.defaultTemperature,
                ));
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // === ACTIONS LEVURES ===
  Future<void> _addYeast() async {
    final yeasts = _getMaterialsByType(MaterialType.yeast);
    if (yeasts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune levure disponible. Ajoutez-en d\'abord dans Stock.')),
      );
      return;
    }
    final result = await _showYeastDialog(null, yeasts);
    if (result != null) {
      await _recipeService.addYeast(result);
      _loadData();
    }
  }

  Future<void> _editYeast(RecipeYeast yeast) async {
    final yeasts = _getMaterialsByType(MaterialType.yeast);
    final result = await _showYeastDialog(yeast, yeasts);
    if (result != null) {
      await _recipeService.updateYeast(result);
      _loadData();
    }
  }

  Future<void> _deleteYeast(RecipeYeast yeast) async {
    final confirm = await _confirmDelete('cette levure');
    if (confirm) {
      await _recipeService.deleteYeast(yeast.id);
      _loadData();
    }
  }

  Future<RecipeYeast?> _showYeastDialog(RecipeYeast? existing, List<RawMaterial> materials) async {
    RawMaterial? selected = existing != null
        ? materials.firstWhere((m) => m.id == existing.materialId, orElse: () => materials.first)
        : null;
    final qtyController = TextEditingController(text: existing?.quantity.toStringAsFixed(0) ?? '11');
    String unit = existing?.unit ?? 'g';

    return showDialog<RecipeYeast>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Ajouter une levure' : 'Modifier la levure'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RawMaterial>(
                  initialValue: selected,
                  hint: const Text('Sélectionner une levure'),
                  items: materials.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (m) => setState(() => selected = m),
                  decoration: const InputDecoration(labelText: 'Levure'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    Expanded(child: AppNumberField(label: 'Quantité', controller: qtyController, decimals: 0)),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('grammes')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'sachet', child: Text('sachet')),
                        ],
                        onChanged: (u) => setState(() => unit = u!),
                        decoration: const InputDecoration(labelText: 'Unité'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: selected == null ? null : () {
                Navigator.pop(context, RecipeYeast(
                  id: existing?.id,
                  recipeId: widget.recipeId,
                  materialId: selected!.id,
                  quantity: double.tryParse(qtyController.text) ?? 11,
                  unit: unit,
                  form: selected!.form ?? YeastForm.dry,
                ));
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // === ACTIONS AJOUTS ===
  Future<void> _addAddition() async {
    final others = _getMaterialsByType(MaterialType.other);
    final result = await _showAdditionDialog(null, others);
    if (result != null) {
      await _recipeService.addAddition(result);
      _loadData();
    }
  }

  Future<void> _editAddition(RecipeAddition addition) async {
    final others = _getMaterialsByType(MaterialType.other);
    final result = await _showAdditionDialog(addition, others);
    if (result != null) {
      await _recipeService.updateAddition(result);
      _loadData();
    }
  }

  Future<void> _deleteAddition(RecipeAddition addition) async {
    final confirm = await _confirmDelete('cet ajout');
    if (confirm) {
      await _recipeService.deleteAddition(addition.id);
      _loadData();
    }
  }

  Future<RecipeAddition?> _showAdditionDialog(RecipeAddition? existing, List<RawMaterial> materials) async {
    RawMaterial? selected = existing != null && materials.isNotEmpty
        ? materials.firstWhere((m) => m.id == existing.materialId, orElse: () => materials.first)
        : null;
    final qtyController = TextEditingController(text: existing?.quantity.toStringAsFixed(1) ?? '1.0');
    String unit = existing?.unit ?? 'g';
    AdditionStep step = existing?.additionStep ?? AdditionStep.boil;
    final nameController = TextEditingController();

    return showDialog<RecipeAddition>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Ajouter un ingrédient' : 'Modifier l\'ingrédient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (materials.isNotEmpty)
                  DropdownButtonFormField<RawMaterial>(
                    initialValue: selected,
                    hint: const Text('Sélectionner (optionnel)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Autre (saisie manuelle)')),
                      ...materials.map((m) => DropdownMenuItem(value: m, child: Text(m.name))),
                    ],
                    onChanged: (m) => setState(() => selected = m),
                    decoration: const InputDecoration(labelText: 'Ingrédient'),
                  ),
                if (selected == null) ...[
                  const SizedBox(height: AppConstants.paddingM),
                  AppTextField(label: 'Nom de l\'ingrédient', controller: nameController),
                ],
                const SizedBox(height: AppConstants.paddingM),
                DropdownButtonFormField<AdditionStep>(
                  initialValue: step,
                  items: AdditionStep.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                  onChanged: (s) => setState(() => step = s!),
                  decoration: const InputDecoration(labelText: 'Étape'),
                ),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    Expanded(child: AppNumberField(label: 'Quantité', controller: qtyController, decimals: 1)),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: unit,
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'unité', child: Text('unité')),
                        ],
                        onChanged: (u) => setState(() => unit = u!),
                        decoration: const InputDecoration(labelText: 'Unité'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, RecipeAddition(
                  id: existing?.id,
                  recipeId: widget.recipeId,
                  materialId: selected?.id ?? '',
                  quantity: double.tryParse(qtyController.text) ?? 1.0,
                  unit: unit,
                  additionStep: step,
                ));
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // === HELPERS ===
  Future<bool> _confirmDelete(String item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer $item ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
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
