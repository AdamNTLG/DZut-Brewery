import 'package:uuid/uuid.dart';

/// Modèle représentant un palier d'empâtage
class MashStep {
  final String id;
  final String recipeId;
  final int stepOrder;
  final double temperature;
  final int durationMin;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  MashStep({
    String? id,
    required this.recipeId,
    this.stepOrder = 1,
    required this.temperature,
    required this.durationMin,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  MashStep copyWith({
    int? stepOrder,
    double? temperature,
    int? durationMin,
    String? description,
  }) {
    return MashStep(
      id: id,
      recipeId: recipeId,
      stepOrder: stepOrder ?? this.stepOrder,
      temperature: temperature ?? this.temperature,
      durationMin: durationMin ?? this.durationMin,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit depuis une Map (database)
  factory MashStep.fromMap(Map<String, dynamic> map) {
    return MashStep(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      stepOrder: (map['step_order'] as int?) ?? 1,
      temperature: (map['temperature'] as num).toDouble(),
      durationMin: map['duration_min'] as int,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convertit vers une Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'step_order': stepOrder,
      'temperature': temperature,
      'duration_min': durationMin,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displayText {
    final tempStr = '${temperature.toStringAsFixed(0)}°C';
    final timeStr = '$durationMin min';
    final descStr = description ?? _getDefaultDescription();
    return '$descStr - $tempStr pendant $timeStr';
  }

  /// Description par défaut basée sur la température
  String _getDefaultDescription() {
    if (temperature <= 50) return 'Palier acide';
    if (temperature <= 55) return 'Palier protéinique';
    if (temperature <= 64) return 'Palier beta-amylase';
    if (temperature <= 70) return 'Palier saccharification';
    if (temperature <= 74) return 'Palier alpha-amylase';
    if (temperature <= 78) return 'Mash-out';
    return 'Palier';
  }

  /// Descriptions communes des paliers
  static final Map<double, String> commonDescriptions = {
    45.0: 'Palier acide',
    52.0: 'Palier protéinique',
    62.0: 'Palier beta-amylase (corps léger)',
    66.0: 'Palier saccharification',
    68.0: 'Palier alpha-amylase (corps plein)',
    72.0: 'Palier alpha-amylase',
    78.0: 'Mash-out',
  };

  @override
  String toString() => 'MashStep(id: $id, temp: $temperature°C, duration: ${durationMin}min)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MashStep && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
