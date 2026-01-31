import 'package:uuid/uuid.dart';

/// Modèle représentant une mesure de brassin
class BatchMeasurement {
  final String id;
  final String batchId;
  final DateTime measurementDate;
  final double? temperature;
  final double? gravity;
  final double? ph;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BatchMeasurement({
    String? id,
    required this.batchId,
    required this.measurementDate,
    this.temperature,
    this.gravity,
    this.ph,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  BatchMeasurement copyWith({
    DateTime? measurementDate,
    double? temperature,
    double? gravity,
    double? ph,
    String? notes,
  }) {
    return BatchMeasurement(
      id: id,
      batchId: batchId,
      measurementDate: measurementDate ?? this.measurementDate,
      temperature: temperature ?? this.temperature,
      gravity: gravity ?? this.gravity,
      ph: ph ?? this.ph,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit depuis une Map (database)
  factory BatchMeasurement.fromMap(Map<String, dynamic> map) {
    return BatchMeasurement(
      id: map['id'] as String,
      batchId: map['batch_id'] as String,
      measurementDate: DateTime.parse(map['measurement_date'] as String),
      temperature: (map['temperature'] as num?)?.toDouble(),
      gravity: (map['gravity'] as num?)?.toDouble(),
      ph: (map['ph'] as num?)?.toDouble(),
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
      'measurement_date': measurementDate.toIso8601String(),
      'temperature': temperature,
      'gravity': gravity,
      'ph': ph,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displayText {
    final parts = <String>[];
    if (temperature != null) parts.add('${temperature!.toStringAsFixed(1)}°C');
    if (gravity != null) parts.add('${gravity!.toStringAsFixed(3)}');
    if (ph != null) parts.add('pH ${ph!.toStringAsFixed(1)}');
    return parts.join(' | ');
  }

  /// Date formatée
  String get formattedDate {
    return '${measurementDate.day.toString().padLeft(2, '0')}/'
           '${measurementDate.month.toString().padLeft(2, '0')}/'
           '${measurementDate.year}';
  }

  @override
  String toString() => 'BatchMeasurement(id: $id, date: $formattedDate, gravity: $gravity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchMeasurement && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
