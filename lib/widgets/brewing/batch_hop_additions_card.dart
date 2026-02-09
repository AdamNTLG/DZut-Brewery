import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/batch_hop_addition.dart';

/// Widget displaying hop additions for a batch
class BatchHopAdditionsCard extends StatelessWidget {
  final List<BatchHopAddition> additions;
  final int? currentDay;
  final VoidCallback? onAddHop;
  final void Function(BatchHopAddition addition)? onMarkAdded;
  final void Function(BatchHopAddition addition)? onMarkRemoved;
  final void Function(BatchHopAddition addition)? onEdit;
  final void Function(BatchHopAddition addition)? onDelete;

  const BatchHopAdditionsCard({
    super.key,
    required this.additions,
    this.currentDay,
    this.onAddHop,
    this.onMarkAdded,
    this.onMarkRemoved,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Group additions by type
    final boilAdditions = additions.where((a) =>
      a.type == HopAdditionType.bittering ||
      a.type == HopAdditionType.flavor ||
      a.type == HopAdditionType.aroma
    ).toList();
    final dryHopAdditions = additions.where((a) =>
      a.type == HopAdditionType.dryHop
    ).toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.grass, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Hop Additions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (onAddHop != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onAddHop,
                    color: AppConstants.primaryColor,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (additions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.grass_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No hop additions',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (onAddHop != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onAddHop,
                        icon: const Icon(Icons.add),
                        label: const Text('Add hops'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else ...[
            // Boil additions section
            if (boilAdditions.isNotEmpty) ...[
              _buildSectionHeader(context, 'Boil Additions', Icons.local_fire_department),
              ...boilAdditions.map((a) => _HopAdditionTile(
                addition: a,
                currentDay: currentDay,
                onMarkAdded: onMarkAdded,
                onMarkRemoved: onMarkRemoved,
                onEdit: onEdit,
                onDelete: onDelete,
              )),
            ],

            // Dry hop section
            if (dryHopAdditions.isNotEmpty) ...[
              _buildSectionHeader(context, 'Dry Hopping', Icons.water_drop),
              ...dryHopAdditions.map((a) => _HopAdditionTile(
                addition: a,
                currentDay: currentDay,
                onMarkAdded: onMarkAdded,
                onMarkRemoved: onMarkRemoved,
                onEdit: onEdit,
                onDelete: onDelete,
              )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _HopAdditionTile extends StatelessWidget {
  final BatchHopAddition addition;
  final int? currentDay;
  final void Function(BatchHopAddition)? onMarkAdded;
  final void Function(BatchHopAddition)? onMarkRemoved;
  final void Function(BatchHopAddition)? onEdit;
  final void Function(BatchHopAddition)? onDelete;

  const _HopAdditionTile({
    required this.addition,
    this.currentDay,
    this.onMarkAdded,
    this.onMarkRemoved,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(addition.type.colorHex);
    final isPending = addition.status == HopAdditionStatus.pending;
    final isDryHop = addition.type == HopAdditionType.dryHop;

    // Check if action is needed for dry hop
    bool needsToBeAdded = false;
    bool needsToBeRemoved = false;
    if (isDryHop && currentDay != null) {
      needsToBeAdded = addition.shouldAddDryHop(currentDay!);
      needsToBeRemoved = addition.shouldRemoveDryHop(currentDay!);
    }

    return Dismissible(
      key: Key(addition.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Hop Addition'),
            content: Text('Remove ${addition.hopName} from the list?'),
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
        ) ?? false;
      },
      onDismissed: (_) => onDelete?.call(addition),
      child: InkWell(
        onTap: () => onEdit?.call(addition),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
            vertical: AppConstants.paddingS,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isPending ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: (needsToBeAdded || needsToBeRemoved)
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: Center(
                  child: isPending
                      ? Text(addition.type.icon, style: const TextStyle(fontSize: 18))
                      : Icon(
                          isDryHop && addition.removedAt != null
                              ? Icons.check_circle
                              : Icons.check,
                          color: color,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            addition.hopName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isPending ? null : Colors.grey[600],
                              decoration: !isPending && !isDryHop
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          addition.amountDisplay,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            addition.type.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          addition.timingDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isDryHop && !isPending && addition.removedAt == null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'In fermenter',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (addition.notes != null && addition.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        addition.notes!,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (needsToBeAdded && onMarkAdded != null)
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: color,
                  onPressed: () => onMarkAdded!(addition),
                  tooltip: 'Mark as added',
                )
              else if (needsToBeRemoved && onMarkRemoved != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.blue,
                  onPressed: () => onMarkRemoved!(addition),
                  tooltip: 'Mark as removed',
                )
              else if (isPending && !isDryHop && onMarkAdded != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.grey[400],
                  onPressed: () => onMarkAdded!(addition),
                  tooltip: 'Mark as added',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog to add/edit a hop addition
class HopAdditionDialog extends StatefulWidget {
  final BatchHopAddition? addition;
  final String batchId;
  final List<String> hopSuggestions;

  const HopAdditionDialog({
    super.key,
    this.addition,
    required this.batchId,
    this.hopSuggestions = const [],
  });

  @override
  State<HopAdditionDialog> createState() => _HopAdditionDialogState();
}

class _HopAdditionDialogState extends State<HopAdditionDialog> {
  late HopAdditionType _selectedType;
  final _hopNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _boilMinutesController = TextEditingController();
  final _startDayController = TextEditingController();
  final _endDayController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.addition != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.addition?.type ?? HopAdditionType.bittering;
    _hopNameController.text = widget.addition?.hopName ?? '';
    _amountController.text = widget.addition?.amountGrams.toStringAsFixed(0) ?? '';
    _boilMinutesController.text = widget.addition?.boilMinutes?.toString() ?? '60';
    _startDayController.text = widget.addition?.dryHopStartDay?.toString() ?? '';
    _endDayController.text = widget.addition?.dryHopEndDay?.toString() ?? '';
    _notesController.text = widget.addition?.notes ?? '';
  }

  @override
  void dispose() {
    _hopNameController.dispose();
    _amountController.dispose();
    _boilMinutesController.dispose();
    _startDayController.dispose();
    _endDayController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDryHop = _selectedType == HopAdditionType.dryHop;
    final showBoilMinutes = _selectedType == HopAdditionType.bittering ||
        _selectedType == HopAdditionType.flavor;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Hop Addition' : 'Add Hops'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hop name
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _hopNameController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return widget.hopSuggestions;
                }
                return widget.hopSuggestions.where((hop) =>
                    hop.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                _hopNameController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Hop Variety *',
                    hintText: 'e.g. Cascade, Citra',
                  ),
                  onChanged: (value) => _hopNameController.text = value,
                );
              },
              onSelected: (selection) {
                _hopNameController.text = selection;
              },
            ),

            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (g) *',
                hintText: 'e.g. 50',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Type selector
            const Text('Addition Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HopAdditionType.values.map((type) {
                final isSelected = type == _selectedType;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.label}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  selectedColor: Color(type.colorHex).withValues(alpha: 0.2),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),
            Text(
              _selectedType.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Timing fields based on type
            if (showBoilMinutes)
              TextField(
                controller: _boilMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Boil Time (minutes)',
                  hintText: 'e.g. 60',
                  helperText: 'Minutes before end of boil',
                ),
                keyboardType: TextInputType.number,
              ),

            if (isDryHop) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDayController,
                      decoration: const InputDecoration(
                        labelText: 'From Day',
                        hintText: 'e.g. 3',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endDayController,
                      decoration: const InputDecoration(
                        labelText: 'To Day',
                        hintText: 'e.g. 7',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Days after yeast pitch',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],

            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional remarks',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _save() {
    final hopName = _hopNameController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    if (hopName.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter hop name and amount')),
      );
      return;
    }

    final boilMinutes = int.tryParse(_boilMinutesController.text);
    final startDay = int.tryParse(_startDayController.text);
    final endDay = int.tryParse(_endDayController.text);
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    final addition = BatchHopAddition(
      id: widget.addition?.id,
      batchId: widget.batchId,
      hopName: hopName,
      amountGrams: amount,
      type: _selectedType,
      boilMinutes: _selectedType == HopAdditionType.bittering ||
              _selectedType == HopAdditionType.flavor
          ? boilMinutes
          : null,
      dryHopStartDay: _selectedType == HopAdditionType.dryHop ? startDay : null,
      dryHopEndDay: _selectedType == HopAdditionType.dryHop ? endDay : null,
      addedAt: widget.addition?.addedAt,
      removedAt: widget.addition?.removedAt,
      notes: notes,
    );

    Navigator.pop(context, addition);
  }
}
