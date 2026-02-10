import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/beer_styles.dart';
import '../../models/recipe_hop.dart';
import '../../services/recipe_service.dart';
import '../../widgets/common/beer_color_indicator.dart';
import '../../widgets/brewing/style_gauge.dart';
import '../../utils/formatters.dart';
import 'recipe_form_page.dart';
import 'recipe_ingredients_page.dart';
import '../batches/batch_form_page.dart';

/// Recipe detail page
class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final _service = RecipeService();

  RecipeComplete? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recipe = await _service.getComplete(widget.recipeId);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe?.recipe.name ?? 'Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _recipe != null ? _editRecipe : null,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'brew':
                  _startBrew();
                  break;
                case 'duplicate':
                  _duplicateRecipe();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'brew',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Start a Batch'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipe == null
              ? const Center(child: Text('Recipe not found'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildContent(),
                ),
      floatingActionButton: _recipe != null
          ? FloatingActionButton.extended(
              onPressed: _editIngredients,
              icon: const Icon(Icons.edit),
              label: const Text('Ingredients'),
            )
          : null,
    );
  }

  Widget _buildContent() {
    final r = _recipe!;

    BeerStyle? style;
    if (r.recipe.beerStyle != null) {
      style = BeerStyles.findByName(r.recipe.beerStyle!);
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        _buildHeader(r),

        const SizedBox(height: AppConstants.paddingM),

        // BJCP style gauges
        if (style != null)
          StyleGaugesCard(
            style: style,
            og: r.recipe.targetOg,
            fg: r.recipe.targetFg,
            ibu: r.recipe.targetIbu,
            ebc: r.recipe.targetEbc,
            abv: r.recipe.targetAbv,
          ),

        const SizedBox(height: AppConstants.paddingM),

        // Mash steps
        if (r.mashSteps.isNotEmpty) ...[
          _buildSection(
            title: 'Mashing',
            icon: Icons.thermostat,
            child: _buildMashSteps(r),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],

        // Grains
        if (r.grains.isNotEmpty) ...[
          _buildSection(
            title: 'Malts & Grains (${Formatters.formatWeightKg(r.totalGrainsKg)})',
            icon: Icons.grain,
            child: _buildGrainsList(r),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],

        // Hops
        if (r.hops.isNotEmpty) ...[
          _buildSection(
            title: 'Hops (${Formatters.formatWeightG(r.totalHopsG)})',
            icon: Icons.eco,
            child: _buildHopsList(r),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],

        // Yeasts
        if (r.yeasts.isNotEmpty) ...[
          _buildSection(
            title: 'Yeasts',
            icon: Icons.bubble_chart,
            child: _buildYeastsList(r),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],

        // Other additions
        if (r.additions.isNotEmpty) ...[
          _buildSection(
            title: 'Other Additions',
            icon: Icons.add_circle_outline,
            child: _buildAdditionsList(r),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],

        // Notes
        if (r.recipe.notes != null && r.recipe.notes!.isNotEmpty) ...[
          _buildSection(
            title: 'Notes',
            icon: Icons.note,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Text(r.recipe.notes!),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],

        // Space for FAB
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeader(RecipeComplete r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                BeerColorIndicator(ebc: r.recipe.targetEbc, size: 60, showLabel: true),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r.recipe.beerStyle != null)
                        Text(
                          r.recipe.beerStyle!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      Text(
                        '${r.recipe.volumeLiters.toStringAsFixed(0)} L',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${r.recipe.boilTime} min boil',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            const Divider(),
            const SizedBox(height: AppConstants.paddingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpecItem('OG', Formatters.formatGravity(r.recipe.targetOg)),
                _buildSpecItem('FG', Formatters.formatGravity(r.recipe.targetFg)),
                _buildSpecItem('ABV', Formatters.formatAbv(r.recipe.targetAbv)),
                _buildSpecItem('IBU', r.recipe.targetIbu?.toStringAsFixed(0) ?? '-'),
                _buildSpecItem('EBC', r.recipe.targetEbc?.toStringAsFixed(0) ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor, size: 20),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildMashSteps(RecipeComplete r) {
    return Column(
      children: r.mashSteps.map((step) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              '${step.stepOrder}',
              style: const TextStyle(color: AppConstants.primaryColor),
            ),
          ),
          title: Text(step.description ?? 'Step ${step.stepOrder}'),
          subtitle: Text('${step.temperature.toStringAsFixed(0)}°C for ${step.durationMin} min'),
        );
      }).toList(),
    );
  }

  Widget _buildGrainsList(RecipeComplete r) {
    return Column(
      children: r.grains.map((grain) {
        final percentage = grain.percentageOf(r.totalGrainsKg);
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  grain.materialName ?? 'Unknown malt',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${grain.quantityKg.toStringAsFixed(2)} kg',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.grainColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHopsList(RecipeComplete r) {
    // Sort: Boil first, then Whirlpool, then Dry Hop
    final sortedHops = List.of(r.hops)..sort((a, b) {
      const order = {HopUse.boil: 0, HopUse.whirlpool: 1, HopUse.dryHop: 2};
      final cmp = order[a.hopUse]!.compareTo(order[b.hopUse]!);
      if (cmp != 0) return cmp;
      return b.timeValue.compareTo(a.timeValue);
    });

    return Column(
      children: sortedHops.map((hop) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.hopColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              hop.hopUse.label,
              style: const TextStyle(
                fontSize: 10,
                color: AppConstants.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(hop.materialName ?? 'Unknown hop'),
          subtitle: Text(
            '${hop.timeValue.toStringAsFixed(0)} ${hop.hopUse.timeUnit}${hop.materialAlphaAcid != null ? ' • ${hop.materialAlphaAcid}% AA' : ''}',
          ),
          trailing: Text(
            '${hop.quantityG.toStringAsFixed(0)} g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYeastsList(RecipeComplete r) {
    return Column(
      children: r.yeasts.map((yeast) {
        return ListTile(
          leading: const Icon(Icons.bubble_chart, color: AppConstants.yeastColor),
          title: Text(yeast.materialName ?? 'Unknown yeast'),
          subtitle: Text(
            '${yeast.form.label}${yeast.materialAttenuation != null ? ' • ${yeast.materialAttenuation}% att.' : ''}',
          ),
          trailing: Text(
            '${yeast.quantity.toStringAsFixed(0)} ${yeast.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdditionsList(RecipeComplete r) {
    return Column(
      children: r.additions.map((addition) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              addition.additionStep.label,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          title: Text(addition.materialName ?? 'Unknown ingredient'),
          trailing: Text(
            '${addition.quantity.toStringAsFixed(1)} ${addition.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  void _editRecipe() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecipeFormPage(recipe: _recipe?.recipe),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _editIngredients() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeIngredientsPage(recipeId: widget.recipeId),
      ),
    );
    // Always reload since ingredients may have changed
    _loadData();
  }

  void _startBrew() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BatchFormPage(recipeId: widget.recipeId),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch created successfully')),
      );
    }
  }

  void _duplicateRecipe() async {
    // TODO: Implement duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Delete this recipe and all its ingredients?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(widget.recipeId);
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
