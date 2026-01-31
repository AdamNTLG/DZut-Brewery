import 'package:uuid/uuid.dart';

/// Modèle représentant un grain/malt dans une recette
class RecipeGrain {
  final String id;
  final String recipeId;
  final String materialId;
  final double quantityKg;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Données jointes (non stockées en DB)
  final String? materialName;
  final double? materialEbc;
  final double? materialPotential;

  RecipeGrain({
    String? id,
    required this.recipeId,
    required this.materialId,
    required this.quantityKg,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.materialName,
    this.materialEbc,
    this.materialPotential,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  RecipeGrain copyWith({
    double? quantityKg,
    String? notes,
    String? materialName,
    double? materialEbc,
    double? materialPotential,
  }) {
    return RecipeGrain(
      id: id,
      recipeId: recipeId,
      materialId: materialId,
      quantityKg: quantityKg ?? this.quantityKg,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      materialName: materialName ?? this.materialName,
      materialEbc: materialEbc ?? this.materialEbc,
      materialPotential: materialPotential ?? this.materialPotential,
    );
  }

  /// Convertit depuis une Map (database)
  factory RecipeGrain.fromMap(Map<String, dynamic> map) {
    return RecipeGrain(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      materialId: map['material_id'] as String,
      quantityKg: (map['quantity_kg'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      // Données jointes optionnelles
      materialName: map['material_name'] as String?,
      materialEbc: (map['material_ebc'] as num?)?.toDouble(),
      materialPotential: (map['material_potential'] as num?)?.toDouble(),
    );
  }

  /// Convertit vers une Map (database) - sans données jointes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'material_id': materialId,
      'quantity_kg': quantityKg,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displayText {
    final name = materialName ?? 'Malt inconnu';
    return '$name - ${quantityKg.toStringAsFixed(2)} kg';
  }

  /// Pourcentage du grain bill (à calculer avec le total)
  double percentageOf(double totalKg) {
    if (totalKg <= 0) return 0;
    return (quantityKg / totalKg) * 100;
  }

  @override
  String toString() => 'RecipeGrain(id: $id, qty: ${quantityKg}kg)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeGrain && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
