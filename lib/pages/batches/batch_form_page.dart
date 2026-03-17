import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/recipe.dart';
import '../../models/fermenter.dart';
import '../../services/batch_service.dart';
import '../../services/recipe_service.dart';
import '../../services/fermenter_service.dart';
import '../../widgets/common/app_text_field.dart';

/// Form page to create a new batch
class BatchFormPage extends StatefulWidget {
  final String? recipeId;

  const BatchFormPage({super.key, this.recipeId});

  @override
  State<BatchFormPage> createState() => _BatchFormPageState();
}

class _BatchFormPageState extends State<BatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _batchService = BatchService();
  final _recipeService = RecipeService();
  final _fermenterService = FermenterService();

  List<Recipe> _recipes = [];
  List<Fermenter> _fermenters = [];
  
  Recipe? _selectedRecipe;
  Fermenter? _selectedFermenter;
  DateTime _brewDate = DateTime.now();
  
  final _ogController = TextEditingController();
  final _volumeController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _ogController.dispose();
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _recipeService.getAll();
      final fermenters = await _fermenterService.getAvailable();
      
      setState(() {
        _recipes = recipes;
        _fermenters = fermenters;
        _isLoading = false;
        
        // Pré-sélectionner la recette si fournie
        if (widget.recipeId != null) {
          _selectedRecipe = recipes.firstWhere(
            (r) => r.id == widget.recipeId,
            orElse: () => recipes.first,
          );
          _prefillFromRecipe();
        }
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

  void _prefillFromRecipe() {
    if (_selectedRecipe != null) {
      if (_selectedRecipe!.targetOg != null) {
        _ogController.text = _selectedRecipe!.targetOg!.toStringAsFixed(3);
      }
      _volumeController.text = _selectedRecipe!.volumeLiters.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Batch'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                children: [
                  // Recipe selection
                  _buildRecipeSelector(),

                  const SizedBox(height: AppConstants.paddingL),

                  // Brew date
                  _buildDateSelector(),

                  const SizedBox(height: AppConstants.paddingM),

                  // Fermenter selection
                  _buildFermenterSelector(),

                  const SizedBox(height: AppConstants.paddingL),

                  // Initial measurements
                  _buildSectionTitle('Initial Measurements (optional)'),

                  Row(
                    children: [
                      Expanded(
                        child: AppNumberField(
                          label: 'Original Gravity (OG)',
                          controller: _ogController,
                          decimals: 3,
                          hint: '1.050',
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: AppNumberField(
                          label: 'Volume (L)',
                          controller: _volumeController,
                          decimals: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // Notes
                  AppTextField(
                    label: 'Notes',
                    controller: _notesController,
                    maxLines: 3,
                    hint: 'Observations, adjustments...',
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Create button
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
                          : Text(_brewDate.isAfter(DateTime.now()) ? 'Schedule Batch' : 'Start Brewing'),
                    ),
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

  Widget _buildRecipeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recipe *'),
        if (_recipes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                children: [
                  Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: AppConstants.paddingS),
                  const Text('No recipes available'),
                  const SizedBox(height: AppConstants.paddingS),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Create a recipe first'),
                  ),
                ],
              ),
            ),
          )
        else
          DropdownButtonFormField<Recipe>(
            isExpanded: true,
            initialValue: _selectedRecipe,
            decoration: const InputDecoration(
              hintText: 'Select a recipe',
            ),
            items: _recipes.map((recipe) {
              return DropdownMenuItem(
                value: recipe,
                child: Text(recipe.name),
              );
            }).toList(),
            onChanged: (recipe) {
              setState(() {
                _selectedRecipe = recipe;
                _prefillFromRecipe();
              });
            },
            validator: (value) {
              if (value == null) return 'Please select a recipe';
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brew Date',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_brewDate.day.toString().padLeft(2, '0')}/${_brewDate.month.toString().padLeft(2, '0')}/${_brewDate.year}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFermenterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fermenter (optional)',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        if (_fermenters.isEmpty)
          InputDecorator(
            decoration: const InputDecoration(),
            child: Text(
              'No fermenter available',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          )
        else
          DropdownButtonFormField<Fermenter>(
            isExpanded: true,
            initialValue: _selectedFermenter,
            decoration: const InputDecoration(
              hintText: 'Select a fermenter',
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('None'),
              ),
              ..._fermenters.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text('${f.name} (${f.capacityLiters.toStringAsFixed(0)}L)'),
                );
              }),
            ],
            onChanged: (fermenter) {
              setState(() => _selectedFermenter = fermenter);
            },
          ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _brewDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _brewDate = date);
    }
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // If brew date is in the future, set status to planned
      final isPlanned = _brewDate.isAfter(DateTime.now());

      final batch = Batch(
        recipeId: _selectedRecipe!.id,
        fermenterId: _selectedFermenter?.id,
        brewDate: _brewDate,
        status: isPlanned ? BatchStatus.planned : BatchStatus.brewing,
        actualOg: _parseDouble(_ogController.text),
        actualVolume: _parseDouble(_volumeController.text),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      await _batchService.createWithSteps(batch);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isPlanned ? 'Batch scheduled!' : 'Batch created!')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
