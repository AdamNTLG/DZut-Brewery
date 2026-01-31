import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/fermenter.dart';
import '../../services/fermenter_service.dart';
import 'fermenter_form_page.dart';

/// Page listant tous les fermenteurs
class FermentersListPage extends StatefulWidget {
  const FermentersListPage({super.key});

  @override
  State<FermentersListPage> createState() => _FermentersListPageState();
}

class _FermentersListPageState extends State<FermentersListPage> {
  final _service = FermenterService();
  
  List<Fermenter> _fermenters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final fermenters = await _service.getAll();
      setState(() {
        _fermenters = fermenters;
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

  int get _availableCount => _fermenters.where((f) => f.isAvailable).length;
  int get _occupiedCount => _fermenters.where((f) => !f.isAvailable).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fermenteurs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Résumé
                _buildSummary(),
                
                // Liste
                Expanded(
                  child: _fermenters.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _fermenters.length,
                            itemBuilder: (context, index) {
                              return _buildFermenterCard(_fermenters[index]);
                            },
                          ),
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

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      color: AppConstants.primaryColor.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.check_circle,
            color: AppConstants.successColor,
            value: '$_availableCount',
            label: 'Disponibles',
          ),
          _buildSummaryItem(
            icon: Icons.science,
            color: Colors.orange,
            value: '$_occupiedCount',
            label: 'Occupés',
          ),
          _buildSummaryItem(
            icon: Icons.water_drop,
            color: AppConstants.primaryColor,
            value: '${_fermenters.length}',
            label: 'Total',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            'Aucun fermenteur',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.paddingM),
          TextButton.icon(
            onPressed: () => _openForm(null),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un fermenteur'),
          ),
        ],
      ),
    );
  }

  Widget _buildFermenterCard(Fermenter fermenter) {
    final isAvailable = fermenter.isAvailable;
    final statusColor = isAvailable ? AppConstants.successColor : Colors.orange;
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingXS,
      ),
      child: InkWell(
        onTap: () => _openForm(fermenter),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              // Icône avec statut
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: AppConstants.primaryColor,
                      size: 28,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        isAvailable ? Icons.check : Icons.science,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: AppConstants.paddingM),
              
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fermenter.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          '${fermenter.capacityLiters.toStringAsFixed(0)} L',
                          Icons.straighten,
                        ),
                        const SizedBox(width: 8),
                        if (fermenter.material != null)
                          _buildInfoChip(
                            fermenter.material!.label,
                            Icons.category,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAvailable ? 'Disponible' : 'Occupé',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _openForm(Fermenter? fermenter) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FermenterFormPage(fermenter: fermenter),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }
}
