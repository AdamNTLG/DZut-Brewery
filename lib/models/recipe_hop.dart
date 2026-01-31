import 'package:uuid/uuid.dart';

/// Types d'utilisation du houblon
enum HopUse {
  boil,      // Ébullition 100°C - temps en minutes
  whirlpool, // Hors flamme ~80°C - temps en minutes
  dryHop;    // Houblonnage à cru - temps en jours

  String get label {
    switch (this) {
      case HopUse.boil:
        return 'Ébullition';
      case HopUse.whirlpool:
        return 'Hors flamme';
      case HopUse.dryHop:
        return 'Dry Hop';
    }
  }

  String get timeUnit {
    switch (this) {
      case HopUse.dryHop:
        return 'jours';
      default:
        return 'min';
    }
  }

  double get defaultTemperature {
    switch (this) {
      case HopUse.boil:
        return 100.0;
      case HopUse.whirlpool:
        return 80.0;
      case HopUse.dryHop:
        return 18.0;
    }
  }

  String get dbValue {
    switch (this) {
      case HopUse.boil:
        return 'boil';
      case HopUse.whirlpool:
        return 'whirlpool';
      case HopUse.dryHop:
        return 'dry_hop';
    }
  }

  static HopUse fromDb(String value) {
    switch (value) {
      case 'boil':
        return HopUse.boil;
      case 'whirlpool':
        return HopUse.whirlpool;
      case 'dry_hop':
        return HopUse.dryHop;
      default:
        return HopUse.boil;
    }
  }
}

/// Modèle représentant un houblon dans une recette
class RecipeHop {
  final String id;
  final String recipeId;
  final String materialId;
  final double quantityG;
  final HopUse hopUse;
  final double timeValue;
  final double? temperature;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Données jointes (non stockées en DB)
  final String? materialName;
  final double? materialAlphaAcid;

  RecipeHop({
    String? id,
    required this.recipeId,
    required this.materialId,
    required this.quantityG,
    required this.hopUse,
    required this.timeValue,
    this.temperature,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.materialName,
    this.materialAlphaAcid,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  RecipeHop copyWith({
    double? quantityG,
    HopUse? hopUse,
    double? timeValue,
    double? temperature,
    String? notes,
    String? materialName,
    double? materialAlphaAcid,
  }) {
    return RecipeHop(
      id: id,
      recipeId: recipeId,
      materialId: materialId,
      quantityG: quantityG ?? this.quantityG,
      hopUse: hopUse ?? this.hopUse,
      timeValue: timeValue ?? this.timeValue,
      temperature: temperature ?? this.temperature,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      materialName: materialName ?? this.materialName,
      materialAlphaAcid: materialAlphaAcid ?? this.materialAlphaAcid,
    );
  }

  /// Convertit depuis une Map (database)
  factory RecipeHop.fromMap(Map<String, dynamic> map) {
    return RecipeHop(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      materialId: map['material_id'] as String,
      quantityG: (map['quantity_g'] as num).toDouble(),
      hopUse: HopUse.fromDb(map['hop_use'] as String),
      timeValue: (map['time_value'] as num).toDouble(),
      temperature: (map['temperature'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      // Données jointes optionnelles
      materialName: map['material_name'] as String?,
      materialAlphaAcid: (map['material_alpha_acid'] as num?)?.toDouble(),
    );
  }

  /// Convertit vers une Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'material_id': materialId,
      'quantity_g': quantityG,
      'hop_use': hopUse.dbValue,
      'time_value': timeValue,
      'temperature': temperature ?? hopUse.defaultTemperature,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displayText {
    final name = materialName ?? 'Houblon inconnu';
    final timeStr = '${timeValue.toStringAsFixed(0)} ${hopUse.timeUnit}';
    return '$name - ${quantityG.toStringAsFixed(0)}g @ $timeStr (${hopUse.label})';
  }

  /// Température effective
  double get effectiveTemperature => temperature ?? hopUse.defaultTemperature;

  @override
  String toString() => 'RecipeHop(id: $id, qty: ${quantityG}g, use: ${hopUse.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeHop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
