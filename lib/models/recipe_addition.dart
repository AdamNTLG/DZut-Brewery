import 'package:uuid/uuid.dart';

/// Étapes d'ajout des ingrédients
enum AdditionStep {
  mash,
  boil,
  whirlpool,
  primary,
  secondary,
  bottling;

  String get label {
    switch (this) {
      case AdditionStep.mash:
        return 'Empâtage';
      case AdditionStep.boil:
        return 'Ébullition';
      case AdditionStep.whirlpool:
        return 'Hors flamme';
      case AdditionStep.primary:
        return 'Fermentation primaire';
      case AdditionStep.secondary:
        return 'Fermentation secondaire';
      case AdditionStep.bottling:
        return 'Embouteillage';
    }
  }

  String get dbValue {
    switch (this) {
      case AdditionStep.mash:
        return 'mash';
      case AdditionStep.boil:
        return 'boil';
      case AdditionStep.whirlpool:
        return 'whirlpool';
      case AdditionStep.primary:
        return 'primary';
      case AdditionStep.secondary:
        return 'secondary';
      case AdditionStep.bottling:
        return 'bottling';
    }
  }

  static AdditionStep fromDb(String value) {
    switch (value) {
      case 'mash':
        return AdditionStep.mash;
      case 'boil':
        return AdditionStep.boil;
      case 'whirlpool':
        return AdditionStep.whirlpool;
      case 'primary':
        return AdditionStep.primary;
      case 'secondary':
        return AdditionStep.secondary;
      case 'bottling':
        return AdditionStep.bottling;
      default:
        return AdditionStep.boil;
    }
  }
}

/// Modèle représentant un ajout divers dans une recette
class RecipeAddition {
  final String id;
  final String recipeId;
  final String materialId;
  final double quantity;
  final String unit;
  final AdditionStep additionStep;
  final double? temperature;
  final double? timeValue;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Données jointes (non stockées en DB)
  final String? materialName;

  RecipeAddition({
    String? id,
    required this.recipeId,
    required this.materialId,
    required this.quantity,
    this.unit = 'g',
    required this.additionStep,
    this.temperature,
    this.timeValue,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.materialName,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  RecipeAddition copyWith({
    double? quantity,
    String? unit,
    AdditionStep? additionStep,
    double? temperature,
    double? timeValue,
    String? notes,
    String? materialName,
  }) {
    return RecipeAddition(
      id: id,
      recipeId: recipeId,
      materialId: materialId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      additionStep: additionStep ?? this.additionStep,
      temperature: temperature ?? this.temperature,
      timeValue: timeValue ?? this.timeValue,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      materialName: materialName ?? this.materialName,
    );
  }

  /// Convertit depuis une Map (database)
  factory RecipeAddition.fromMap(Map<String, dynamic> map) {
    return RecipeAddition(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      materialId: map['material_id'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'g',
      additionStep: AdditionStep.fromDb(map['addition_step'] as String),
      temperature: (map['temperature'] as num?)?.toDouble(),
      timeValue: (map['time_value'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      materialName: map['material_name'] as String?,
    );
  }

  /// Convertit vers une Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'material_id': materialId,
      'quantity': quantity,
      'unit': unit,
      'addition_step': additionStep.dbValue,
      'temperature': temperature,
      'time_value': timeValue,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displayText {
    final name = materialName ?? 'Ingrédient inconnu';
    final qtyStr = '${quantity.toStringAsFixed(1)} $unit';
    return '$name - $qtyStr @ ${additionStep.label}';
  }

  @override
  String toString() => 'RecipeAddition(id: $id, qty: $quantity $unit, step: ${additionStep.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAddition && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
