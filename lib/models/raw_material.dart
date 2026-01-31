import 'package:uuid/uuid.dart';

/// Types de matières premières
enum MaterialType {
  grain,
  hop,
  yeast,
  other;

  String get label {
    switch (this) {
      case MaterialType.grain:
        return 'Céréale/Malt';
      case MaterialType.hop:
        return 'Houblon';
      case MaterialType.yeast:
        return 'Levure';
      case MaterialType.other:
        return 'Autre';
    }
  }

  String get icon {
    switch (this) {
      case MaterialType.grain:
        return '🌾';
      case MaterialType.hop:
        return '🌿';
      case MaterialType.yeast:
        return '🧫';
      case MaterialType.other:
        return '📦';
    }
  }
}

/// Forme de levure
enum YeastForm {
  dry,
  liquid;

  String get label {
    switch (this) {
      case YeastForm.dry:
        return 'Sèche';
      case YeastForm.liquid:
        return 'Liquide';
    }
  }
}

/// Modèle représentant une matière première
class RawMaterial {
  final String id;
  final String name;
  final MaterialType type;
  final double price;
  final String unit;
  final double? ebc;           // Pour les grains
  final double? potential;     // PPG pour les grains
  final double? alphaAcid;     // % pour les houblons
  final double? attenuation;   // % pour les levures
  final YeastForm? form;       // Pour les levures
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RawMaterial({
    String? id,
    required this.name,
    required this.type,
    this.price = 0.0,
    this.unit = 'kg',
    this.ebc,
    this.potential,
    this.alphaAcid,
    this.attenuation,
    this.form,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crée une copie avec des modifications
  RawMaterial copyWith({
    String? name,
    MaterialType? type,
    double? price,
    String? unit,
    double? ebc,
    double? potential,
    double? alphaAcid,
    double? attenuation,
    YeastForm? form,
    String? notes,
  }) {
    return RawMaterial(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      ebc: ebc ?? this.ebc,
      potential: potential ?? this.potential,
      alphaAcid: alphaAcid ?? this.alphaAcid,
      attenuation: attenuation ?? this.attenuation,
      form: form ?? this.form,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convertit depuis une Map (database)
  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'] as String,
      name: map['name'] as String,
      type: MaterialType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MaterialType.other,
      ),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? 'kg',
      ebc: (map['ebc'] as num?)?.toDouble(),
      potential: (map['potential'] as num?)?.toDouble(),
      alphaAcid: (map['alpha_acid'] as num?)?.toDouble(),
      attenuation: (map['attenuation'] as num?)?.toDouble(),
      form: map['form'] != null
          ? YeastForm.values.firstWhere(
              (e) => e.name == map['form'],
              orElse: () => YeastForm.dry,
            )
          : null,
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
      'type': type.name,
      'price': price,
      'unit': unit,
      'ebc': ebc,
      'potential': potential,
      'alpha_acid': alphaAcid,
      'attenuation': attenuation,
      'form': form?.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Affichage formaté pour les listes
  String get displaySubtitle {
    switch (type) {
      case MaterialType.grain:
        final ebcStr = ebc != null ? '${ebc!.toStringAsFixed(1)} EBC' : '';
        final potStr = potential != null ? '${potential!.toStringAsFixed(0)} PPG' : '';
        return [ebcStr, potStr].where((s) => s.isNotEmpty).join(' | ');
      case MaterialType.hop:
        return alphaAcid != null ? '${alphaAcid!.toStringAsFixed(1)}% AA' : '';
      case MaterialType.yeast:
        final attStr = attenuation != null ? '${attenuation!.toStringAsFixed(0)}% att.' : '';
        final formStr = form?.label ?? '';
        return [formStr, attStr].where((s) => s.isNotEmpty).join(' | ');
      case MaterialType.other:
        return notes ?? '';
    }
  }

  @override
  String toString() => 'RawMaterial(id: $id, name: $name, type: ${type.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawMaterial && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
