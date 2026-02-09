import 'package:uuid/uuid.dart';

/// Type of hop addition timing
enum HopAdditionType {
  bittering,    // Added during boil for bitterness (IBU)
  flavor,       // Added late in boil for flavor
  aroma,        // Added at flame-out / whirlpool
  dryHop;       // Added during fermentation

  String get label {
    switch (this) {
      case HopAdditionType.bittering:
        return 'Bittering';
      case HopAdditionType.flavor:
        return 'Flavor';
      case HopAdditionType.aroma:
        return 'Aroma';
      case HopAdditionType.dryHop:
        return 'Dry Hop';
    }
  }

  String get icon {
    switch (this) {
      case HopAdditionType.bittering:
        return '🔥';
      case HopAdditionType.flavor:
        return '🌿';
      case HopAdditionType.aroma:
        return '👃';
      case HopAdditionType.dryHop:
        return '🍃';
    }
  }

  String get description {
    switch (this) {
      case HopAdditionType.bittering:
        return 'Added during boil (60-90 min)';
      case HopAdditionType.flavor:
        return 'Added late in boil (15-30 min)';
      case HopAdditionType.aroma:
        return 'Added at flame-out or whirlpool';
      case HopAdditionType.dryHop:
        return 'Added during fermentation';
    }
  }

  int get colorHex {
    switch (this) {
      case HopAdditionType.bittering:
        return 0xFFFF5722;  // Orange
      case HopAdditionType.flavor:
        return 0xFF8BC34A;  // Light green
      case HopAdditionType.aroma:
        return 0xFF4CAF50;  // Green
      case HopAdditionType.dryHop:
        return 0xFF009688;  // Teal
    }
  }
}

/// Status of a hop addition
enum HopAdditionStatus {
  pending,
  completed;

  String get label {
    switch (this) {
      case HopAdditionStatus.pending:
        return 'Pending';
      case HopAdditionStatus.completed:
        return 'Added';
    }
  }
}

/// Model representing a hop addition during brewing/fermentation
class BatchHopAddition {
  final String id;
  final String batchId;
  final String hopName;           // Name of the hop variety
  final double amountGrams;       // Amount in grams
  final HopAdditionType type;

  // For bittering/flavor: minutes before end of boil
  final int? boilMinutes;

  // For dry hop: day range after pitching (e.g., day 3 to day 7)
  final int? dryHopStartDay;
  final int? dryHopEndDay;

  // Tracking
  final DateTime? addedAt;        // When actually added
  final DateTime? removedAt;      // When removed (for dry hop)
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  BatchHopAddition({
    String? id,
    required this.batchId,
    required this.hopName,
    required this.amountGrams,
    required this.type,
    this.boilMinutes,
    this.dryHopStartDay,
    this.dryHopEndDay,
    this.addedAt,
    this.removedAt,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy with modifications
  BatchHopAddition copyWith({
    String? hopName,
    double? amountGrams,
    HopAdditionType? type,
    int? boilMinutes,
    int? dryHopStartDay,
    int? dryHopEndDay,
    DateTime? addedAt,
    DateTime? removedAt,
    String? notes,
  }) {
    return BatchHopAddition(
      id: id,
      batchId: batchId,
      hopName: hopName ?? this.hopName,
      amountGrams: amountGrams ?? this.amountGrams,
      type: type ?? this.type,
      boilMinutes: boilMinutes ?? this.boilMinutes,
      dryHopStartDay: dryHopStartDay ?? this.dryHopStartDay,
      dryHopEndDay: dryHopEndDay ?? this.dryHopEndDay,
      addedAt: addedAt ?? this.addedAt,
      removedAt: removedAt ?? this.removedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert from database map
  factory BatchHopAddition.fromMap(Map<String, dynamic> map) {
    return BatchHopAddition(
      id: map['id'] as String,
      batchId: map['batch_id'] as String,
      hopName: map['hop_name'] as String,
      amountGrams: (map['amount_grams'] as num).toDouble(),
      type: HopAdditionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => HopAdditionType.bittering,
      ),
      boilMinutes: map['boil_minutes'] as int?,
      dryHopStartDay: map['dry_hop_start_day'] as int?,
      dryHopEndDay: map['dry_hop_end_day'] as int?,
      addedAt: map['added_at'] != null
          ? DateTime.parse(map['added_at'] as String)
          : null,
      removedAt: map['removed_at'] != null
          ? DateTime.parse(map['removed_at'] as String)
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'hop_name': hopName,
      'amount_grams': amountGrams,
      'type': type.name,
      'boil_minutes': boilMinutes,
      'dry_hop_start_day': dryHopStartDay,
      'dry_hop_end_day': dryHopEndDay,
      'added_at': addedAt?.toIso8601String(),
      'removed_at': removedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get the status of this addition
  HopAdditionStatus get status {
    if (addedAt == null) return HopAdditionStatus.pending;
    return HopAdditionStatus.completed;
  }

  /// Display string for timing
  String get timingDisplay {
    switch (type) {
      case HopAdditionType.bittering:
      case HopAdditionType.flavor:
        if (boilMinutes != null) {
          return '@${boilMinutes}min';
        }
        return type.label;
      case HopAdditionType.aroma:
        return 'Flame-out';
      case HopAdditionType.dryHop:
        if (dryHopStartDay != null && dryHopEndDay != null) {
          return 'Day $dryHopStartDay-$dryHopEndDay';
        } else if (dryHopStartDay != null) {
          return 'From day $dryHopStartDay';
        }
        return 'Dry hop';
    }
  }

  /// Display string for amount
  String get amountDisplay => '${amountGrams.toStringAsFixed(0)}g';

  /// Full display string
  String get displayText => '$hopName $amountDisplay $timingDisplay';

  /// Check if dry hop should be added based on current day since pitching
  bool shouldAddDryHop(int daysSincePitching) {
    if (type != HopAdditionType.dryHop) return false;
    if (addedAt != null) return false;  // Already added
    if (dryHopStartDay == null) return false;
    return daysSincePitching >= dryHopStartDay!;
  }

  /// Check if dry hop should be removed based on current day since pitching
  bool shouldRemoveDryHop(int daysSincePitching) {
    if (type != HopAdditionType.dryHop) return false;
    if (addedAt == null) return false;  // Not yet added
    if (removedAt != null) return false;  // Already removed
    if (dryHopEndDay == null) return false;
    return daysSincePitching >= dryHopEndDay!;
  }

  @override
  String toString() => 'BatchHopAddition($hopName, $type, $amountGrams g)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchHopAddition && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
