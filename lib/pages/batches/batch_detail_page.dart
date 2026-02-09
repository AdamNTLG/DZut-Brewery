import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/batch_measurement.dart';
import '../../models/batch_step.dart';
import '../../models/batch_hop_addition.dart';
import '../../services/batch_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/brewing/batch_steps_card.dart';
import '../../widgets/brewing/batch_hop_additions_card.dart';
import '../../widgets/common/app_text_field.dart';

/// Batch detail and tracking page
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
  List<BatchStep> _steps = [];
  List<BatchHopAddition> _hopAdditions = [];
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
      final steps = await _service.getSteps(widget.batchId);
      final hopAdditions = await _service.getHopAdditions(widget.batchId);

      setState(() {
        _batch = batch;
        _measurements = measurements;
        _steps = steps;
        _hopAdditions = hopAdditions;
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
        title: Text(_batch?.recipeName ?? 'Batch'),
        actions: [
          if (_batch != null && _batch!.status != BatchStatus.planned && _batch!.status.nextStatus != null)
            TextButton.icon(
              onPressed: _advanceStatus,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: Text(
                'Move to ${_batch!.status.nextStatus!.label}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batch == null
              ? const Center(child: Text('Batch not found'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildContent(),
                ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    if (_batch == null) return null;

    // For planned batches: Start Brewing button
    if (_batch!.status == BatchStatus.planned) {
      return FloatingActionButton.extended(
        onPressed: _startBrewing,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Brewing'),
        backgroundColor: AppConstants.primaryColor,
      );
    }

    // For fermenting/conditioning: Add Measurement button
    if (_batch!.status == BatchStatus.fermenting ||
        _batch!.status == BatchStatus.conditioning) {
      return FloatingActionButton.extended(
        onPressed: _addMeasurement,
        icon: const Icon(Icons.add),
        label: const Text('Measurement'),
      );
    }

    return null;
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

        // Brewing steps
        BatchStepsCard(
          steps: _steps,
          onAddStep: _addStep,
          onStartStep: _startStep,
          onEndStep: _endStep,
          onEditStep: _editStep,
        ),

        const SizedBox(height: AppConstants.paddingM),

        // Hop additions
        BatchHopAdditionsCard(
          additions: _hopAdditions,
          currentDay: _batch!.daysSinceBrew,
          onAddHop: _addHopAddition,
          onMarkAdded: _markHopAdded,
          onMarkRemoved: _markHopRemoved,
          onEdit: _editHopAddition,
          onDelete: _deleteHopAddition,
        ),

        const SizedBox(height: AppConstants.paddingM),

        // Measurement history
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
                    color: statusColor.withValues(alpha: 0.1),
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
                          color: statusColor.withValues(alpha: 0.1),
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
                        _batch!.status == BatchStatus.planned
                            ? 'Scheduled'
                            : 'Day ${_batch!.daysSinceBrew}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _batch!.status == BatchStatus.planned
                            ? 'Scheduled for ${Formatters.formatDate(_batch!.brewDate)}'
                            : 'Brewed on ${Formatters.formatDate(_batch!.brewDate)}',
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
                title: const Text('Fermenter'),
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
              'Measurements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Row(
              children: [
                Expanded(child: _buildMeasureBox('OG', Formatters.formatGravity(_batch!.actualOg))),
                const SizedBox(width: AppConstants.paddingS),
                Expanded(child: _buildMeasureBox('FG', Formatters.formatGravity(_batch!.actualFg))),
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
        color: AppConstants.primaryColor.withValues(alpha: 0.05),
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
              'Measurement History',
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
            
            // Update OG
            if (_batch!.actualOg == null)
              ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Record initial gravity'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _updateOG,
              ),

            // Delete
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete this batch', style: TextStyle(color: Colors.red)),
              onTap: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startBrewing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Brewing'),
        content: const Text('Start brewing this batch now? This will mark the fermenter as in use.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.updateStatus(widget.batchId, BatchStatus.brewing);
      // Add default mashing step to start
      final mashingStep = BatchStep(
        batchId: widget.batchId,
        type: StepType.mashing,
        actualStart: DateTime.now(),
      );
      setState(() {
        _steps = [mashingStep, ..._steps];
      });
      await _service.saveSteps(widget.batchId, _steps);
      _loadData();
    }
  }

  Future<void> _advanceStatus() async {
    final nextStatus = _batch!.status.nextStatus;
    if (nextStatus == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Text('Move batch to "${nextStatus.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
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
        title: const Text('New Measurement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppNumberField(
                label: 'Temperature (°C)',
                controller: tempController,
                decimals: 1,
              ),
              const SizedBox(height: AppConstants.paddingM),
              AppNumberField(
                label: 'Gravity',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
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
        title: const Text('Initial Gravity'),
        content: AppNumberField(
          label: 'OG',
          controller: controller,
          decimals: 3,
          hint: '1.050',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
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
        title: const Text('Delete'),
        content: const Text('Delete this measurement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
        title: const Text('Delete'),
        content: const Text('Delete this batch and all its measurements?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ========== Step Management ==========

  Future<void> _addStep() async {
    final result = await showDialog<BatchStep>(
      context: context,
      builder: (context) => BatchStepDialog(batchId: widget.batchId),
    );

    if (result != null) {
      setState(() {
        _steps = [..._steps, result];
      });
      await _service.saveSteps(widget.batchId, _steps);
    }
  }

  Future<void> _startStep(BatchStep step) async {
    final updatedStep = step.copyWith(actualStart: DateTime.now());
    setState(() {
      _steps = _steps.map((s) => s.id == step.id ? updatedStep : s).toList();
    });
    await _service.saveSteps(widget.batchId, _steps);
  }

  Future<void> _endStep(BatchStep step) async {
    final updatedStep = step.copyWith(actualEnd: DateTime.now());
    setState(() {
      _steps = _steps.map((s) => s.id == step.id ? updatedStep : s).toList();
    });
    await _service.saveSteps(widget.batchId, _steps);
  }

  Future<void> _editStep(BatchStep step) async {
    final result = await showDialog<BatchStep>(
      context: context,
      builder: (context) => BatchStepDialog(
        batchId: widget.batchId,
        step: step,
      ),
    );

    if (result != null) {
      setState(() {
        _steps = _steps.map((s) => s.id == step.id ? result : s).toList();
      });
      await _service.saveSteps(widget.batchId, _steps);
    }
  }

  // ========== Hop Addition Management ==========

  Future<void> _addHopAddition() async {
    final result = await showDialog<BatchHopAddition>(
      context: context,
      builder: (context) => HopAdditionDialog(
        batchId: widget.batchId,
        hopSuggestions: const ['Cascade', 'Citra', 'Mosaic', 'Simcoe', 'Centennial', 'Amarillo', 'Galaxy', 'Nelson Sauvin', 'Saaz', 'Hallertau'],
      ),
    );

    if (result != null) {
      await _service.addHopAddition(result);
      _loadData();
    }
  }

  Future<void> _editHopAddition(BatchHopAddition addition) async {
    final result = await showDialog<BatchHopAddition>(
      context: context,
      builder: (context) => HopAdditionDialog(
        batchId: widget.batchId,
        addition: addition,
        hopSuggestions: const ['Cascade', 'Citra', 'Mosaic', 'Simcoe', 'Centennial', 'Amarillo', 'Galaxy', 'Nelson Sauvin', 'Saaz', 'Hallertau'],
      ),
    );

    if (result != null) {
      await _service.updateHopAddition(result);
      _loadData();
    }
  }

  Future<void> _markHopAdded(BatchHopAddition addition) async {
    await _service.markHopAdditionAdded(addition.id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${addition.hopName} added')),
      );
    }
  }

  Future<void> _markHopRemoved(BatchHopAddition addition) async {
    await _service.markHopAdditionRemoved(addition.id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${addition.hopName} removed from fermenter')),
      );
    }
  }

  Future<void> _deleteHopAddition(BatchHopAddition addition) async {
    await _service.deleteHopAddition(addition.id);
    _loadData();
  }
}
