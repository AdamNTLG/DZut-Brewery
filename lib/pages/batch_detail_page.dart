import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/batch_measurement.dart';
import '../../services/batch_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_text_field.dart';

/// Page affichant le détail et le suivi d'un brassin
class BatchDetailPage extends StatefulWidget {
  final String batchId;

  const BatchDetailPage({super.key, required this.batchId});

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage> {
  final _service = BatchService();
  
  Batch? _batch;
  List<BatchMeasurement> _measurements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final batch = await _service.getById(widget.batchId);
      final measurements = await _service.getMeasurements(widget.batchId);
      
      setState(() {
        _batch = batch;
        _measurements = measurements;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_batch?.recipeName ?? 'Brassin'),
        actions: [
          if (_batch != null && _batch!.status.nextStatus != null)
            TextButton.icon(
              onPressed: _advanceStatus,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: Text(
                'Passer à ${_batch!.status.nextStatus!.label}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batch == null
              ? const Center(child: Text('Brassin non trouvé'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildContent(),
                ),
      floatingActionButton: _batch != null &&
              (_batch!.status == BatchStatus.fermenting ||
               _batch!.status == BatchStatus.conditioning)
          ? FloatingActionButton.extended(
              onPressed: _addMeasurement,
              icon: const Icon(Icons.add),
              label: const Text('Mesure'),
            )
          : null,
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      children: [
        // Carte de statut
        _buildStatusCard(),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // Caractéristiques mesurées
        _buildMeasurementsCard(),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // Historique des mesures
        if (_measurements.isNotEmpty) ...[
          _buildMeasurementsHistory(),
          const SizedBox(height: AppConstants.paddingM),
        ],
        
        // Actions
        _buildActionsCard(),
        
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatusCard() {
    final statusColor = Color(_batch!.status.colorHex);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _batch!.status.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _batch!.status.label,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jour ${_batch!.daysSinceBrew}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Brassé le ${Formatters.formatDate(_batch!.brewDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (_batch!.fermenterName != null) ...[
              const SizedBox(height: AppConstants.paddingM),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.water_drop),
                title: const Text('Fermenteur'),
                trailing: Text(
                  _batch!.fermenterName!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mesures',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Row(
              children: [
                Expanded(child: _buildMeasureBox('DI (OG)', Formatters.formatGravity(_batch!.actualOg))),
                const SizedBox(width: AppConstants.paddingS),
                Expanded(child: _buildMeasureBox('DF (FG)', Formatters.formatGravity(_batch!.actualFg))),
                const SizedBox(width: AppConstants.paddingS),
                Expanded(child: _buildMeasureBox('ABV', Formatters.formatAbv(_batch!.calculatedAbv))),
              ],
            ),
            if (_batch!.actualVolume != null) ...[
              const SizedBox(height: AppConstants.paddingS),
              Row(
                children: [
                  Expanded(child: _buildMeasureBox('Volume', '${_batch!.actualVolume!.toStringAsFixed(1)} L')),
                  const Spacer(flex: 2),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasureBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsHistory() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppConstants.paddingM),
            child: Text(
              'Historique des mesures',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _measurements.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = _measurements[index];
              return ListTile(
                leading: Text(
                  '${m.measurementDate.day}/${m.measurementDate.month}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(m.displayText),
                subtitle: m.notes != null ? Text(m.notes!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deleteMeasurement(m),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // Mettre à jour l'OG
            if (_batch!.actualOg == null)
              ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Enregistrer la densité initiale'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _updateOG,
              ),
            
            // Supprimer
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer ce brassin', style: TextStyle(color: Colors.red)),
              onTap: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _advanceStatus() async {
    final nextStatus = _batch!.status.nextStatus;
    if (nextStatus == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le statut'),
        content: Text('Passer le brassin à "${nextStatus.label}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _service.updateStatus(widget.batchId, nextStatus);
      _loadData();
    }
  }

  Future<void> _addMeasurement() async {
    final tempController = TextEditingController();
    final gravityController = TextEditingController();
    final phController = TextEditingController();
    final notesController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle mesure'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppNumberField(
                label: 'Température (°C)',
                controller: tempController,
                decimals: 1,
              ),
              const SizedBox(height: AppConstants.paddingM),
              AppNumberField(
                label: 'Densité',
                controller: gravityController,
                decimals: 3,
                hint: '1.010',
              ),
              const SizedBox(height: AppConstants.paddingM),
              AppNumberField(
                label: 'pH',
                controller: phController,
                decimals: 1,
              ),
              const SizedBox(height: AppConstants.paddingM),
              AppTextField(
                label: 'Notes',
                controller: notesController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      final measurement = BatchMeasurement(
        batchId: widget.batchId,
        measurementDate: DateTime.now(),
        temperature: double.tryParse(tempController.text.replaceAll(',', '.')),
        gravity: double.tryParse(gravityController.text.replaceAll(',', '.')),
        ph: double.tryParse(phController.text.replaceAll(',', '.')),
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
      );
      
      await _service.addMeasurement(measurement);
      _loadData();
    }
  }

  Future<void> _updateOG() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Densité initiale'),
        content: AppNumberField(
          label: 'OG',
          controller: controller,
          decimals: 3,
          hint: '1.050',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      final og = double.tryParse(result.replaceAll(',', '.'));
      if (og != null) {
        await _service.updateGravities(widget.batchId, og: og);
        _loadData();
      }
    }
  }

  Future<void> _deleteMeasurement(BatchMeasurement m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer cette mesure ?'),
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
    
    if (confirm == true) {
      await _service.deleteMeasurement(m.id);
      _loadData();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce brassin et toutes ses mesures ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.delete(widget.batchId);
              if (mounted) {
                Navigator.of(context).pop(true);
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