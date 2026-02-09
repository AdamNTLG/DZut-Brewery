import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/app_scaffold.dart';
import '../services/raw_material_service.dart';
import '../services/recipe_service.dart';
import '../services/batch_service.dart';
import '../services/fermenter_service.dart';
import '../models/batch.dart';
import 'raw_materials/raw_materials_list_page.dart';
import 'recipes/recipes_list_page.dart';
import 'batches/batches_list_page.dart';
import 'fermenters/fermenters_list_page.dart';

/// Home page with dashboard
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _rawMaterialService = RawMaterialService();
  final _recipeService = RecipeService();
  final _batchService = BatchService();
  final _fermenterService = FermenterService();

  int _recipesCount = 0;
  int _materialsCount = 0;
  int _activeBatchesCount = 0;
  int _fermentersAvailable = 0;
  List<Batch> _activeBatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final recipes = await _recipeService.getAll();
      final materials = await _rawMaterialService.getAll();
      final activeBatches = await _batchService.getActive();
      final fermenterStats = await _fermenterService.getStats();
      
      setState(() {
        _recipesCount = recipes.length;
        _materialsCount = materials.length;
        _activeBatchesCount = activeBatches.length;
        _fermentersAvailable = fermenterStats['available'] ?? 0;
        _activeBatches = activeBatches.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loading error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: NavIndex.home,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Logo_db.png',
              height: 36,
            ),
            const SizedBox(width: 8),
            const Text(AppConstants.appName),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main statistics
                    _buildStatsGrid(),

                    const SizedBox(height: AppConstants.paddingL),

                    // Active batches
                    _buildActiveBatchesSection(),

                    const SizedBox(height: AppConstants.paddingL),

                    // Quick actions
                    _buildQuickActionsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppConstants.paddingM,
      crossAxisSpacing: AppConstants.paddingM,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Recipes',
          value: '$_recipesCount',
          icon: Icons.menu_book,
          color: AppConstants.primaryColor,
          onTap: () => _navigateTo(const RecipesListPage()),
        ),
        StatCard(
          title: 'Ingredients',
          value: '$_materialsCount',
          icon: Icons.inventory_2,
          color: AppConstants.primaryDark,
          onTap: () => _navigateTo(const RawMaterialsListPage()),
        ),
        StatCard(
          title: 'Active Batches',
          value: '$_activeBatchesCount',
          icon: Icons.science,
          color: Colors.green,
          onTap: () => _navigateTo(const BatchesListPage()),
        ),
        StatCard(
          title: 'Available Fermenters',
          value: '$_fermentersAvailable',
          icon: Icons.water_drop,
          color: Colors.purple,
          onTap: () => _navigateTo(const FermentersListPage()),
        ),
      ],
    );
  }

  Widget _buildActiveBatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Batches',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_activeBatches.isNotEmpty)
              TextButton(
                onPressed: () => _navigateTo(const BatchesListPage()),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingS),
        if (_activeBatches.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.local_drink_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      'No active batches',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    TextButton.icon(
                      onPressed: () => _navigateTo(const BatchesListPage()),
                      icon: const Icon(Icons.add),
                      label: const Text('Create a batch'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_activeBatches.map((batch) => _buildBatchCard(batch))),
      ],
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(batch.status.colorHex).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              batch.status.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          batch.recipeName ?? 'Batch #${batch.id.substring(0, 6)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${batch.status.label} • Day ${batch.daysSinceBrew}',
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
          // TODO: Navigate to batch detail
        },
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingS),
        Wrap(
          spacing: AppConstants.paddingS,
          runSpacing: AppConstants.paddingS,
          children: [
            _buildQuickActionChip(
              icon: Icons.add_circle,
              label: 'New Recipe',
              onTap: () {
                // TODO: Create recipe
              },
            ),
            _buildQuickActionChip(
              icon: Icons.play_arrow,
              label: 'Start a Batch',
              onTap: () {
                // TODO: New batch
              },
            ),
            _buildQuickActionChip(
              icon: Icons.add_shopping_cart,
              label: 'Add Ingredient',
              onTap: () {
                // TODO: Add raw material
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
