import 'package:uuid/uuid.dart';

/// Types de matériaux pour les fermenteurs
enum FermenterMaterial {
  plastic,
  inox,
  glass,
  other;

  String get label {
    switch (this) {
      case FermenterMaterial.plastic:
        return 'Plastique';
      case FermenterMaterial.inox:
        return 'Inox';
      case FermenterMaterial.glass:
        return 'Verre';
      case FermenterMaterial.other:
        return 'Autre';
    }
  }

  String get icon {
    switch (this) {
      case FermenterMaterial.plastic:
        return '🪣';
      case FermenterMaterial.inox:
        return '🥫';
      case FermenterMaterial.glass:
        return '🫙';
      case FermenterMaterial.other:
        return '📦';
    }
  }
}

/// Modèle représentant un fermenteur/bassin
class Fermenter {
  final String id;
  final String name;
  final double capacityLiters;
  final FermenterMaterial? material;
  final bool isAvailable;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fermenter({
    String? id,
    required this.name,
    required this.capacityLiters,
    this.material,
    this.isAvailable = true,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  Fermenter copyWith({
    String? name,
    double? capacityLiters,
    FermenterMaterial? material,
    bool? isAvailable,
    String? notes,
  }) {
    return Fermenter(
      id: id,
      name: name ?? this.name,
      capacityLiters: capacityLiters ?? this.capacityLiters,
      material: material ?? this.material,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit depuis une Map (database)
  factory Fermenter.fromMap(Map<String, dynamic> map) {
    return Fermenter(
      id: map['id'] as String,
      name: map['name'] as String,
      capacityLiters: (map['capacity_liters'] as num).toDouble(),
      material: map['material'] != null
          ? FermenterMaterial.values.firstWhere(
              (e) => e.name == map['material'],
              orElse: () => FermenterMaterial.other,
            )
          : null,
      isAvailable: (map['is_available'] as int?) == 1,
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
      'capacity_liters': capacityLiters,
      'material': material?.name,
      'is_available': isAvailable ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté
  String get displaySubtitle {
    final parts = <String>[];
    parts.add('${capacityLiters.toStringAsFixed(0)}L');
    if (material != null) parts.add(material!.label);
    if (!isAvailable) parts.add('Occupé');
    return parts.join(' | ');
  }

  /// Statut formaté
  String get statusText => isAvailable ? 'Disponible' : 'Occupé';

  @override
  String toString() => 'Fermenter(id: $id, name: $name, capacity: ${capacityLiters}L)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fermenter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
