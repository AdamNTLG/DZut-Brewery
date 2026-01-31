import 'package:uuid/uuid.dart';
import 'raw_material.dart';

/// Modèle représentant une levure dans une recette
class RecipeYeast {
  final String id;
  final String recipeId;
  final String materialId;
  final double quantity;
  final String unit;
  final YeastForm form;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Données jointes (non stockées en DB)
  final String? materialName;
  final double? materialAttenuation;

  RecipeYeast({
    String? id,
    required this.recipeId,
    required this.materialId,
    required this.quantity,
    this.unit = 'g',
    required this.form,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.materialName,
    this.materialAttenuation,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  RecipeYeast copyWith({
    double? quantity,
    String? unit,
    YeastForm? form,
    String? notes,
    String? materialName,
    double? materialAttenuation,
  }) {
    return RecipeYeast(
      id: id,
      recipeId: recipeId,
      materialId: materialId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      form: form ?? this.form,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      materialName: materialName ?? this.materialName,
      materialAttenuation: materialAttenuation ?? this.materialAttenuation,
    );
  }

  /// Convertit depuis une Map (database)
  factory RecipeYeast.fromMap(Map<String, dynamic> map) {
    return RecipeYeast(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      materialId: map['material_id'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'g',
      form: YeastForm.values.firstWhere(
        (e) => e.name == map['form'],
        orElse: () => YeastForm.dry,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      // Données jointes optionnelles
      materialName: map['material_name'] as String?,
      materialAttenuation: (map['material_attenuation'] as num?)?.toDouble(),
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
      'form': form.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displayText {
    final name = materialName ?? 'Levure inconnue';
    final qtyStr = '${quantity.toStringAsFixed(0)} $unit';
    return '$name - $qtyStr (${form.label})';
  }

  /// Unité recommandée selon la forme
  static String getRecommendedUnit(YeastForm form) {
    switch (form) {
      case YeastForm.dry:
        return 'g';
      case YeastForm.liquid:
        return 'ml';
    }
  }

  @override
  String toString() => 'RecipeYeast(id: $id, qty: $quantity $unit, form: ${form.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeYeast && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
