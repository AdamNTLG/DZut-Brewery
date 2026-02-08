import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../services/batch_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_scaffold.dart';
import 'batch_form_page.dart';
import 'batch_detail_page.dart';

/// Page listing all batches
class BatchesListPage extends StatefulWidget {
  const BatchesListPage({super.key});

  @override
  State<BatchesListPage> createState() => _BatchesListPageState();
}

class _BatchesListPageState extends State<BatchesListPage>
    with SingleTickerProviderStateMixin {
  final _service = BatchService();
  late TabController _tabController;
  
  List<Batch> _allBatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final batches = await _service.getAll();
      setState(() {
        _allBatches = batches;
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

  List<Batch> _getActiveBatches() {
    return _allBatches.where((b) =>
      b.status == BatchStatus.brewing ||
      b.status == BatchStatus.fermenting ||
      b.status == BatchStatus.conditioning
    ).toList();
  }

  List<Batch> _getCompletedBatches() {
    return _allBatches.where((b) =>
      b.status == BatchStatus.completed ||
      b.status == BatchStatus.archived
    ).toList();
  }

  List<Batch> _getPlannedBatches() {
    return _allBatches.where((b) => b.status == BatchStatus.planned).toList();
  }

  @override
  Widget build(BuildContext context) {
    final active = _getActiveBatches();
    final completed = _getCompletedBatches();
    final planned = _getPlannedBatches();

    return AppScaffold(
      currentIndex: NavIndex.batches,
      appBar: AppBar(
        title: const Text('My Batches'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Planned (${planned.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBatchList(active, 'No active batches'),
                _buildBatchList(planned, 'No planned batches'),
                _buildBatchList(completed, 'No completed batches'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createBatch,
        icon: const Icon(Icons.add),
        label: const Text('New Batch'),
      ),
    );
  }

  Widget _buildBatchList(List<Batch> batches, String emptyMessage) {
    if (batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppConstants.paddingM),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: batches.length,
        itemBuilder: (context, index) => _buildBatchCard(batches[index]),
      ),
    );
  }

  Widget _buildBatchCard(Batch batch) {
    final statusColor = Color(batch.status.colorHex);
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingXS,
      ),
      child: InkWell(
        onTap: () => _openDetail(batch),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(batch.status.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.recipeName ?? 'Brassin #${batch.id.substring(0, 6)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                batch.status.label,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              batch.status == BatchStatus.planned
                                  ? 'Scheduled'
                                  : 'Day ${batch.daysSinceBrew}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              
              // Infos supplémentaires
              if (batch.actualOg != null || batch.actualFg != null) ...[
                const SizedBox(height: AppConstants.paddingM),
                const Divider(height: 1),
                const SizedBox(height: AppConstants.paddingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBatchStat('DI', Formatters.formatGravity(batch.actualOg)),
                    _buildBatchStat('DF', Formatters.formatGravity(batch.actualFg)),
                    _buildBatchStat('ABV', Formatters.formatAbv(batch.calculatedAbv)),
                    if (batch.fermenterName != null)
                      _buildBatchStat('Fermenteur', batch.fermenterName!),
                  ],
                ),
              ],
              
              // Date
              const SizedBox(height: AppConstants.paddingS),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    batch.status == BatchStatus.planned
                        ? 'Scheduled for ${Formatters.formatDate(batch.brewDate)}'
                        : 'Brewed on ${Formatters.formatDate(batch.brewDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _createBatch() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BatchFormPage()),
    );
    if (result == true) _loadData();
  }

  void _openDetail(Batch batch) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BatchDetailPage(batchId: batch.id)),
    );
    if (result == true) _loadData();
  }
}
