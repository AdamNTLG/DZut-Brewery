import 'package:uuid/uuid.dart';

/// Batch status
enum BatchStatus {
  planned,
  brewing,
  fermenting,
  conditioning,
  completed,
  archived;

  String get label {
    switch (this) {
      case BatchStatus.planned:
        return 'Planned';
      case BatchStatus.brewing:
        return 'Brewing';
      case BatchStatus.fermenting:
        return 'Fermenting';
      case BatchStatus.conditioning:
        return 'Conditioning';
      case BatchStatus.completed:
        return 'Completed';
      case BatchStatus.archived:
        return 'Archived';
    }
  }

  String get icon {
    switch (this) {
      case BatchStatus.planned:
        return '📅';
      case BatchStatus.brewing:
        return '🔥';
      case BatchStatus.fermenting:
        return '🫧';
      case BatchStatus.conditioning:
        return '🧊';
      case BatchStatus.completed:
        return '✅';
      case BatchStatus.archived:
        return '📁';
    }
  }

  int get colorHex {
    switch (this) {
      case BatchStatus.planned:
        return 0xFF9E9E9E;    // Gris
      case BatchStatus.brewing:
        return 0xFFFF9800;    // Orange
      case BatchStatus.fermenting:
        return 0xFF4CAF50;    // Vert
      case BatchStatus.conditioning:
        return 0xFF2196F3;    // Bleu
      case BatchStatus.completed:
        return 0xFF8BC34A;    // Vert clair
      case BatchStatus.archived:
        return 0xFF607D8B;    // Gris bleuté
    }
  }

  /// Prochain statut dans le workflow
  BatchStatus? get nextStatus {
    switch (this) {
      case BatchStatus.planned:
        return BatchStatus.brewing;
      case BatchStatus.brewing:
        return BatchStatus.fermenting;
      case BatchStatus.fermenting:
        return BatchStatus.conditioning;
      case BatchStatus.conditioning:
        return BatchStatus.completed;
      case BatchStatus.completed:
        return BatchStatus.archived;
      case BatchStatus.archived:
        return null;
    }
  }
}

/// Modèle représentant un brassin (production)
class Batch {
  final String id;
  final String recipeId;
  final String? fermenterId;
  final DateTime brewDate;
  final BatchStatus status;
  final double? actualOg;
  final double? actualFg;
  final double? actualAbv;
  final double? actualVolume;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Données jointes (non stockées en DB)
  final String? recipeName;
  final String? fermenterName;

  Batch({
    String? id,
    required this.recipeId,
    this.fermenterId,
    required this.brewDate,
    this.status = BatchStatus.planned,
    this.actualOg,
    this.actualFg,
    this.actualAbv,
    this.actualVolume,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.recipeName,
    this.fermenterName,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  Batch copyWith({
    String? fermenterId,
    DateTime? brewDate,
    BatchStatus? status,
    double? actualOg,
    double? actualFg,
    double? actualAbv,
    double? actualVolume,
    String? notes,
    String? recipeName,
    String? fermenterName,
  }) {
    return Batch(
      id: id,
      recipeId: recipeId,
      fermenterId: fermenterId ?? this.fermenterId,
      brewDate: brewDate ?? this.brewDate,
      status: status ?? this.status,
      actualOg: actualOg ?? this.actualOg,
      actualFg: actualFg ?? this.actualFg,
      actualAbv: actualAbv ?? this.actualAbv,
      actualVolume: actualVolume ?? this.actualVolume,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      recipeName: recipeName ?? this.recipeName,
      fermenterName: fermenterName ?? this.fermenterName,
    );
  }

  /// Convertit depuis une Map (database)
  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      fermenterId: map['fermenter_id'] as String?,
      brewDate: DateTime.parse(map['brew_date'] as String),
      status: BatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BatchStatus.planned,
      ),
      actualOg: (map['actual_og'] as num?)?.toDouble(),
      actualFg: (map['actual_fg'] as num?)?.toDouble(),
      actualAbv: (map['actual_abv'] as num?)?.toDouble(),
      actualVolume: (map['actual_volume'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      recipeName: map['recipe_name'] as String?,
      fermenterName: map['fermenter_name'] as String?,
    );
  }

  /// Convertit vers une Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'fermenter_id': fermenterId,
      'brew_date': brewDate.toIso8601String(),
      'status': status.name,
      'actual_og': actualOg,
      'actual_fg': actualFg,
      'actual_abv': actualAbv,
      'actual_volume': actualVolume,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Calcule l'ABV à partir de OG et FG
  double? get calculatedAbv {
    if (actualOg != null && actualFg != null) {
      return (actualOg! - actualFg!) * 131.25;
    }
    return actualAbv;
  }

  /// Nombre de jours depuis le brassage
  int get daysSinceBrew {
    return DateTime.now().difference(brewDate).inDays;
  }

  /// Affichage formaté
  String get displaySubtitle {
    final parts = <String>[];
    parts.add(status.label);
    if (actualOg != null) parts.add('DI: ${actualOg!.toStringAsFixed(3)}');
    if (actualFg != null) parts.add('DF: ${actualFg!.toStringAsFixed(3)}');
    final abv = calculatedAbv;
    if (abv != null) parts.add('${abv.toStringAsFixed(1)}%');
    return parts.join(' | ');
  }

  @override
  String toString() => 'Batch(id: $id, recipe: $recipeId, status: ${status.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Batch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
