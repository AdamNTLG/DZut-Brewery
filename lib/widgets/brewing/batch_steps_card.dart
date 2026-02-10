import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/batch_step.dart';
import '../../utils/formatters.dart';

/// Widget displaying the brewing steps timeline
class BatchStepsCard extends StatelessWidget {
  final List<BatchStep> steps;
  final VoidCallback? onAddStep;
  final void Function(BatchStep step)? onStartStep;
  final void Function(BatchStep step)? onEndStep;
  final void Function(BatchStep step)? onEditStep;

  const BatchStepsCard({
    super.key,
    required this.steps,
    this.onAddStep,
    this.onStartStep,
    this.onEndStep,
    this.onEditStep,
  });

  @override
  Widget build(BuildContext context) {
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
                    Icon(Icons.timeline, color: AppConstants.secondaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Brewing Steps',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (onAddStep != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onAddStep,
                    color: AppConstants.primaryColor,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (steps.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No steps recorded',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (onAddStep != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onAddStep,
                        icon: const Icon(Icons.add),
                        label: const Text('Add step'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;

                // Déterminer si c'est le prochain step à démarrer
                bool isNextStep = false;
                if (step.status == StepStatus.pending) {
                  if (index == 0) {
                    isNextStep = true;
                  } else {
                    final previousStep = steps[index - 1];
                    isNextStep = previousStep.status == StepStatus.inProgress ||
                        previousStep.status == StepStatus.completed;
                  }
                }

                return _BatchStepTile(
                  step: step,
                  isLast: isLast,
                  isNextStep: isNextStep,
                  onStart: isNextStep && onStartStep != null ? () => onStartStep!(step) : null,
                  onEnd: onEndStep != null ? () => onEndStep!(step) : null,
                  onEdit: onEditStep != null ? () => onEditStep!(step) : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BatchStepTile extends StatelessWidget {
  final BatchStep step;
  final bool isLast;
  final bool isNextStep;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;
  final VoidCallback? onEdit;

  const _BatchStepTile({
    required this.step,
    required this.isLast,
    this.isNextStep = false,
    this.onStart,
    this.onEnd,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(step.type.colorHex);
    final status = step.status;

    return InkWell(
      onTap: onEdit,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline verticale
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  // Ligne du haut
                  Container(
                    width: 2,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  // Cercle de l'étape
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: status == StepStatus.completed
                          ? color
                          : status == StepStatus.inProgress
                              ? color.withValues(alpha: 0.3)
                              : Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: status == StepStatus.inProgress ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: status == StepStatus.completed
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              step.type.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                    ),
                  ),
                  // Ligne du bas
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),

            // Contenu de l'étape
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.paddingM,
                  top: AppConstants.paddingS,
                  bottom: AppConstants.paddingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et statut
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == StepStatus.pending
                                  ? Colors.grey[600]
                                  : AppConstants.textColor,
                            ),
                          ),
                        ),
                        _buildStatusBadge(status, color),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Durée
                    if (step.actualStart != null) ...[
                      Row(
                        children: [
                          Icon(Icons.play_arrow, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatDateTime(step.actualStart!),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (step.actualEnd != null) ...[
                            const Text(' → ', style: TextStyle(fontSize: 12)),
                            Icon(Icons.stop, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              Formatters.formatDateTime(step.actualEnd!),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                      if (step.actualDuration != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Duration: ${_formatDuration(step.actualDuration!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: step.isOverdue ? AppConstants.errorColor : Colors.grey[600],
                              fontWeight: step.isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                    ],

                    // Temperature
                    if (step.temperature != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.thermostat, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${step.temperature!.toStringAsFixed(1)}°C',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                    // Notes
                    if (step.notes != null && step.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          step.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Action buttons
                    if (status != StepStatus.completed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            if (status == StepStatus.pending && isNextStep && onStart != null)
                              _buildActionButton(
                                'Commencer',
                                Icons.play_arrow,
                                color,
                                onStart!,
                              ),
                            if (status == StepStatus.inProgress && onEnd != null)
                              _buildActionButton(
                                'Terminer',
                                Icons.stop,
                                AppConstants.successColor,
                                onEnd!,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StepStatus status, Color color) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case StepStatus.pending:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        text = 'Pending';
        break;
      case StepStatus.inProgress:
        bgColor = color.withValues(alpha: 0.1);
        textColor = color;
        text = 'In Progress';
        break;
      case StepStatus.completed:
        bgColor = AppConstants.successColor.withValues(alpha: 0.1);
        textColor = AppConstants.successColor;
        text = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }
}

/// Dialog to add/edit a step
class BatchStepDialog extends StatefulWidget {
  final BatchStep? step;
  final String batchId;

  const BatchStepDialog({
    super.key,
    this.step,
    required this.batchId,
  });

  @override
  State<BatchStepDialog> createState() => _BatchStepDialogState();
}

class _BatchStepDialogState extends State<BatchStepDialog> {
  late StepType _selectedType;
  final _notesController = TextEditingController();
  final _tempController = TextEditingController();

  bool get _isEditing => widget.step != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.step?.type ?? StepType.mashing;
    _notesController.text = widget.step?.notes ?? '';
    _tempController.text = widget.step?.temperature?.toString() ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Step' : 'New Step'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            const Text('Step Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StepType.values.where((t) => t != StepType.other).map((type) {
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

            const SizedBox(height: 16),

            // Temperature
            TextField(
              controller: _tempController,
              decoration: const InputDecoration(
                labelText: 'Temperature (°C)',
                hintText: 'e.g. 67',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Instructions, remarks...',
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
    final temp = double.tryParse(_tempController.text.replaceAll(',', '.'));
    final notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

    final step = BatchStep(
      id: widget.step?.id,
      batchId: widget.batchId,
      type: _selectedType,
      temperature: temp,
      notes: notes,
      actualStart: widget.step?.actualStart,
      actualEnd: widget.step?.actualEnd,
    );

    Navigator.pop(context, step);
  }
}
