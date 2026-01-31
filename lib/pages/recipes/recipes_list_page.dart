import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../widgets/common/beer_color_indicator.dart';
import 'recipe_form_page.dart';
import 'recipe_detail_page.dart';

/// Page listant toutes les recettes
class RecipesListPage extends StatefulWidget {
  const RecipesListPage({super.key});

  @override
  State<RecipesListPage> createState() => _RecipesListPageState();
}

class _RecipesListPageState extends State<RecipesListPage> {
  final _service = RecipeService();
  
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _service.getAll();
      setState(() {
        _recipes = recipes;
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

  List<Recipe> get _filteredRecipes {
    if (_searchQuery.isEmpty) return _recipes;
    return _recipes.where((r) =>
      r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (r.beerStyle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes recettes'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Liste des recettes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecipes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredRecipes.length,
                          itemBuilder: (context, index) {
                            return _buildRecipeCard(_filteredRecipes[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle recette'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            _searchQuery.isEmpty
                ? 'Aucune recette'
                : 'Aucun résultat pour "$_searchQuery"',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: AppConstants.paddingM),
            TextButton.icon(
              onPressed: () => _openForm(null),
              icon: const Icon(Icons.add),
              label: const Text('Créer ma première recette'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingXS,
      ),
      child: InkWell(
        onTap: () => _openDetail(recipe),
        onLongPress: () => _showOptions(recipe),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              // Indicateur couleur
              BeerColorIndicator(ebc: recipe.targetEbc, size: 50),
              
              const SizedBox(width: AppConstants.paddingM),
              
              // Infos recette
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (recipe.beerStyle != null)
                      Text(
                        recipe.beerStyle!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: AppConstants.paddingXS),
                    // Specs
                    Wrap(
                      spacing: AppConstants.paddingS,
                      runSpacing: AppConstants.paddingXS,
                      children: [
                        if (recipe.volumeLiters > 0)
                          _buildSpecChip('${recipe.volumeLiters.toStringAsFixed(0)}L'),
                        if (recipe.targetAbv != null)
                          _buildSpecChip('${recipe.targetAbv!.toStringAsFixed(1)}%'),
                        if (recipe.targetIbu != null)
                          _buildSpecChip('${recipe.targetIbu!.toStringAsFixed(0)} IBU'),
                      ],
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  void _openForm(Recipe? recipe) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecipeFormPage(recipe: recipe),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _openDetail(Recipe recipe) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(recipeId: recipe.id),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _showOptions(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _openForm(recipe);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Dupliquer'),
              onTap: () async {
                Navigator.pop(context);
                await _duplicateRecipe(recipe);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Démarrer un brassin'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Créer brassin
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(recipe);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _duplicateRecipe(Recipe recipe) async {
    final newName = await _showNameDialog('Nom de la copie', '${recipe.name} (copie)');
    if (newName == null || newName.isEmpty) return;
    
    try {
      await _service.duplicate(recipe.id, newName);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette dupliquée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<String?> _showNameDialog(String title, String initialValue) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nom',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer "${recipe.name}" ?\n\nCette action supprimera également tous les ingrédients associés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(recipe.id);
              _loadData();
              if (mounted) {
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
