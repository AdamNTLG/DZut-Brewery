import 'package:flutter/material.dart' hide MaterialType;
import '../../constants/app_constants.dart';
import '../../models/raw_material.dart';
import '../../services/raw_material_service.dart';
import '../../widgets/common/app_scaffold.dart';
import 'raw_material_form_page.dart';

/// Page listant toutes les matières premières
class RawMaterialsListPage extends StatefulWidget {
  const RawMaterialsListPage({super.key});

  @override
  State<RawMaterialsListPage> createState() => _RawMaterialsListPageState();
}

class _RawMaterialsListPageState extends State<RawMaterialsListPage>
    with SingleTickerProviderStateMixin {
  final _service = RawMaterialService();
  late TabController _tabController;
  
  List<RawMaterial> _allMaterials = [];
  bool _isLoading = true;
  String _searchQuery = '';

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
      final materials = await _service.getAll();
      setState(() {
        _allMaterials = materials;
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

  List<RawMaterial> _getFilteredMaterials(MaterialType? type) {
    var materials = _allMaterials;
    
    if (type != null) {
      materials = materials.where((m) => m.type == type).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      materials = materials.where((m) =>
        m.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return materials;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: NavIndex.stock,
      appBar: AppBar(
        title: const Text('Matières premières'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Tout (${_getFilteredMaterials(null).length})'),
            Tab(text: '🌾 Céréales (${_getFilteredMaterials(MaterialType.grain).length})'),
            Tab(text: '🌿 Houblons (${_getFilteredMaterials(MaterialType.hop).length})'),
            Tab(text: '🧫 Levures (${_getFilteredMaterials(MaterialType.yeast).length})'),
            Tab(text: '📦 Divers (${_getFilteredMaterials(MaterialType.other).length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMaterialsList(null),
                      _buildMaterialsList(MaterialType.grain),
                      _buildMaterialsList(MaterialType.hop),
                      _buildMaterialsList(MaterialType.yeast),
                      _buildMaterialsList(MaterialType.other),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildMaterialsList(MaterialType? type) {
    final materials = _getFilteredMaterials(type);
    
    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'Aucune matière première',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return _buildMaterialCard(material);
        },
      ),
    );
  }

  Widget _buildMaterialCard(RawMaterial material) {
    Color typeColor;
    switch (material.type) {
      case MaterialType.grain:
        typeColor = AppConstants.grainColor;
        break;
      case MaterialType.hop:
        typeColor = AppConstants.hopColor;
        break;
      case MaterialType.yeast:
        typeColor = AppConstants.yeastColor;
        break;
      case MaterialType.other:
        typeColor = AppConstants.otherColor;
        break;
    }

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
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              material.type.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          material.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(material.displaySubtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (material.price > 0)
              Text(
                '${material.price.toStringAsFixed(2)}€/${material.unit}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () => _openForm(material),
        onLongPress: () => _showDeleteDialog(material),
      ),
    );
  }

  void _openForm(RawMaterial? material) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RawMaterialFormPage(material: material),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _showDeleteDialog(RawMaterial material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer "${material.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(material.id);
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
