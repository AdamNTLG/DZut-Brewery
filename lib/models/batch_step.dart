import 'package:uuid/uuid.dart';

/// Brewing process step types
enum StepType {
  mashing,
  sparging,
  boiling,
  cooling,
  pitching,
  fermentation,
  dryHopping,
  secondary,
  conditioning,
  carbonation,
  bottling,
  kegging,
  other;

  String get label {
    switch (this) {
      case StepType.mashing:
        return 'Mashing';
      case StepType.sparging:
        return 'Sparging';
      case StepType.boiling:
        return 'Boiling';
      case StepType.cooling:
        return 'Cooling';
      case StepType.pitching:
        return 'Pitching';
      case StepType.fermentation:
        return 'Fermentation';
      case StepType.dryHopping:
        return 'Dry Hopping';
      case StepType.secondary:
        return 'Secondary';
      case StepType.conditioning:
        return 'Conditioning';
      case StepType.carbonation:
        return 'Carbonation';
      case StepType.bottling:
        return 'Bottling';
      case StepType.kegging:
        return 'Kegging';
      case StepType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case StepType.mashing:
        return '🌾';
      case StepType.sparging:
        return '💧';
      case StepType.boiling:
        return '🔥';
      case StepType.cooling:
        return '❄️';
      case StepType.pitching:
        return '🧫';
      case StepType.fermentation:
        return '🫧';
      case StepType.dryHopping:
        return '🌿';
      case StepType.secondary:
        return '🫧';
      case StepType.conditioning:
        return '🧊';
      case StepType.carbonation:
        return '💨';
      case StepType.bottling:
        return '🍾';
      case StepType.kegging:
        return '🛢️';
      case StepType.other:
        return '📝';
    }
  }

  int get colorHex {
    switch (this) {
      case StepType.mashing:
        return 0xFFD97706;    // Ambre
      case StepType.sparging:
        return 0xFF2196F3;    // Bleu
      case StepType.boiling:
        return 0xFFFF5722;    // Orange vif
      case StepType.cooling:
        return 0xFF00BCD4;    // Cyan
      case StepType.pitching:
        return 0xFF9C27B0;    // Violet
      case StepType.fermentation:
        return 0xFF4CAF50;    // Vert
      case StepType.dryHopping:
        return 0xFF8BC34A;    // Vert clair
      case StepType.secondary:
        return 0xFF009688;    // Teal
      case StepType.conditioning:
        return 0xFF3F51B5;    // Indigo
      case StepType.carbonation:
        return 0xFF607D8B;    // Gris bleuté
      case StepType.bottling:
        return 0xFF795548;    // Marron
      case StepType.kegging:
        return 0xFF455A64;    // Gris foncé
      case StepType.other:
        return 0xFF9E9E9E;    // Gris
    }
  }

  /// Ordre typique des étapes dans le processus de brassage
  int get order {
    switch (this) {
      case StepType.mashing:
        return 1;
      case StepType.sparging:
        return 2;
      case StepType.boiling:
        return 3;
      case StepType.cooling:
        return 4;
      case StepType.pitching:
        return 5;
      case StepType.fermentation:
        return 6;
      case StepType.dryHopping:
        return 7;
      case StepType.secondary:
        return 8;
      case StepType.conditioning:
        return 9;
      case StepType.carbonation:
        return 10;
      case StepType.bottling:
        return 11;
      case StepType.kegging:
        return 11;
      case StepType.other:
        return 99;
    }
  }
}

/// Modèle représentant une étape d'un brassin avec horodatage
class BatchStep {
  final String id;
  final String batchId;
  final StepType type;
  final String? customName;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final double? temperature;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BatchStep({
    String? id,
    required this.batchId,
    required this.type,
    this.customName,
    this.plannedStart,
    this.plannedEnd,
    this.actualStart,
    this.actualEnd,
    this.temperature,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  BatchStep copyWith({
    String? customName,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    double? temperature,
    String? notes,
  }) {
    return BatchStep(
      id: id,
      batchId: batchId,
      type: type,
      customName: customName ?? this.customName,
      plannedStart: plannedStart ?? this.plannedStart,
      plannedEnd: plannedEnd ?? this.plannedEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      temperature: temperature ?? this.temperature,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit depuis une Map (database)
  factory BatchStep.fromMap(Map<String, dynamic> map) {
    return BatchStep(
      id: map['id'] as String,
      batchId: map['batch_id'] as String,
      type: StepType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => StepType.other,
      ),
      customName: map['custom_name'] as String?,
      plannedStart: map['planned_start'] != null
          ? DateTime.parse(map['planned_start'] as String)
          : null,
      plannedEnd: map['planned_end'] != null
          ? DateTime.parse(map['planned_end'] as String)
          : null,
      actualStart: map['actual_start'] != null
          ? DateTime.parse(map['actual_start'] as String)
          : null,
      actualEnd: map['actual_end'] != null
          ? DateTime.parse(map['actual_end'] as String)
          : null,
      temperature: (map['temperature'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convertit vers une Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'type': type.name,
      'custom_name': customName,
      'planned_start': plannedStart?.toIso8601String(),
      'planned_end': plannedEnd?.toIso8601String(),
      'actual_start': actualStart?.toIso8601String(),
      'actual_end': actualEnd?.toIso8601String(),
      'temperature': temperature,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Nom d'affichage de l'étape
  String get displayName => customName ?? type.label;

  /// Statut de l'étape
  StepStatus get status {
    if (actualStart == null) return StepStatus.pending;
    if (actualEnd == null) return StepStatus.inProgress;
    return StepStatus.completed;
  }

  /// Durée planifiée
  Duration? get plannedDuration {
    if (plannedStart == null || plannedEnd == null) return null;
    return plannedEnd!.difference(plannedStart!);
  }

  /// Durée réelle
  Duration? get actualDuration {
    if (actualStart == null) return null;
    final end = actualEnd ?? DateTime.now();
    return end.difference(actualStart!);
  }

  /// Écart entre durée planifiée et réelle
  Duration? get durationDifference {
    final planned = plannedDuration;
    final actual = actualDuration;
    if (planned == null || actual == null) return null;
    return actual - planned;
  }

  /// Vérifie si l'étape est en retard
  bool get isOverdue {
    if (actualEnd != null) return false;
    if (plannedEnd == null) return false;
    return DateTime.now().isAfter(plannedEnd!);
  }

  @override
  String toString() => 'BatchStep(id: $id, type: ${type.label}, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchStep && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Step status
enum StepStatus {
  pending,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case StepStatus.pending:
        return 'Pending';
      case StepStatus.inProgress:
        return 'In Progress';
      case StepStatus.completed:
        return 'Completed';
    }
  }

  String get icon {
    switch (this) {
      case StepStatus.pending:
        return '⏳';
      case StepStatus.inProgress:
        return '▶️';
      case StepStatus.completed:
        return '✅';
    }
  }
}
