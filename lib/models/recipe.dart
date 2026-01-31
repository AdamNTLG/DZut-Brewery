import 'package:uuid/uuid.dart';

/// Modèle représentant une recette de bière
class Recipe {
  final String id;
  final String name;
  final String? beerStyle;
  final double volumeLiters;
  final double? initialWater;
  final double? finalWater;
  final double? targetOg;
  final double? targetFg;
  final double? targetIbu;
  final double? targetEbc;
  final double? targetAbv;
  final int boilTime;
  final double efficiency;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    String? id,
    required this.name,
    this.beerStyle,
    this.volumeLiters = 20.0,
    this.initialWater,
    this.finalWater,
    this.targetOg,
    this.targetFg,
    this.targetIbu,
    this.targetEbc,
    this.targetAbv,
    this.boilTime = 60,
    this.efficiency = 75.0,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  Recipe copyWith({
    String? name,
    String? beerStyle,
    double? volumeLiters,
    double? initialWater,
    double? finalWater,
    double? targetOg,
    double? targetFg,
    double? targetIbu,
    double? targetEbc,
    double? targetAbv,
    int? boilTime,
    double? efficiency,
    String? notes,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      beerStyle: beerStyle ?? this.beerStyle,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      initialWater: initialWater ?? this.initialWater,
      finalWater: finalWater ?? this.finalWater,
      targetOg: targetOg ?? this.targetOg,
      targetFg: targetFg ?? this.targetFg,
      targetIbu: targetIbu ?? this.targetIbu,
      targetEbc: targetEbc ?? this.targetEbc,
      targetAbv: targetAbv ?? this.targetAbv,
      boilTime: boilTime ?? this.boilTime,
      efficiency: efficiency ?? this.efficiency,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit depuis une Map (database)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      beerStyle: map['beer_style'] as String?,
      volumeLiters: (map['volume_liters'] as num?)?.toDouble() ?? 20.0,
      initialWater: (map['initial_water'] as num?)?.toDouble(),
      finalWater: (map['final_water'] as num?)?.toDouble(),
      targetOg: (map['target_og'] as num?)?.toDouble(),
      targetFg: (map['target_fg'] as num?)?.toDouble(),
      targetIbu: (map['target_ibu'] as num?)?.toDouble(),
      targetEbc: (map['target_ebc'] as num?)?.toDouble(),
      targetAbv: (map['target_abv'] as num?)?.toDouble(),
      boilTime: (map['boil_time'] as int?) ?? 60,
      efficiency: (map['efficiency'] as num?)?.toDouble() ?? 75.0,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convertit vers une Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'beer_style': beerStyle,
      'volume_liters': volumeLiters,
      'initial_water': initialWater,
      'final_water': finalWater,
      'target_og': targetOg,
      'target_fg': targetFg,
      'target_ibu': targetIbu,
      'target_ebc': targetEbc,
      'target_abv': targetAbv,
      'boil_time': boilTime,
      'efficiency': efficiency,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté des caractéristiques
  String get displaySpecs {
    final specs = <String>[];
    if (targetOg != null) specs.add('DI: ${targetOg!.toStringAsFixed(3)}');
    if (targetFg != null) specs.add('DF: ${targetFg!.toStringAsFixed(3)}');
    if (targetAbv != null) specs.add('${targetAbv!.toStringAsFixed(1)}%');
    if (targetIbu != null) specs.add('${targetIbu!.toStringAsFixed(0)} IBU');
    if (targetEbc != null) specs.add('${targetEbc!.toStringAsFixed(0)} EBC');
    return specs.join(' | ');
  }

  @override
  String toString() => 'Recipe(id: $id, name: $name, style: $beerStyle)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
