import 'package:uuid/uuid.dart';

/// Type of device
enum DeviceType {
  ferminator,   // Temperature controller
  graviator;    // Gravity/tilt meter

  String get label {
    switch (this) {
      case DeviceType.ferminator:
        return 'Ferminator';
      case DeviceType.graviator:
        return 'Graviator';
    }
  }

  String get icon {
    switch (this) {
      case DeviceType.ferminator:
        return '🌡️';
      case DeviceType.graviator:
        return '📐';
    }
  }

  String get description {
    switch (this) {
      case DeviceType.ferminator:
        return 'Temperature controller for fermentation';
      case DeviceType.graviator:
        return 'Wireless tilt hydrometer';
    }
  }
}

/// A reading from a BrewCreator device
class DeviceReading {
  final String id;
  final String deviceId;
  final DeviceType deviceType;
  final String? batchId;

  // Temperature data (Ferminator)
  final double? temperature;        // Current temperature in °C
  final double? targetTemperature;  // Target temperature in °C
  final bool? heatingActive;
  final bool? coolingActive;

  // Gravity data (Graviator)
  final double? gravity;            // Specific gravity
  final double? tilt;               // Tilt angle in degrees
  final double? batteryVoltage;

  // Common
  final int? signalStrength;        // RSSI in dBm
  final DateTime readingTime;
  final DateTime createdAt;

  DeviceReading({
    String? id,
    required this.deviceId,
    required this.deviceType,
    this.batchId,
    this.temperature,
    this.targetTemperature,
    this.heatingActive,
    this.coolingActive,
    this.gravity,
    this.tilt,
    this.batteryVoltage,
    this.signalStrength,
    DateTime? readingTime,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        readingTime = readingTime ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert from database/API map
  factory DeviceReading.fromMap(Map<String, dynamic> map) {
    return DeviceReading(
      id: map['id'] as String,
      deviceId: map['device_id'] as String,
      deviceType: DeviceType.values.firstWhere(
        (e) => e.name == map['device_type'],
        orElse: () => DeviceType.ferminator,
      ),
      batchId: map['batch_id'] as String?,
      temperature: (map['temperature'] as num?)?.toDouble(),
      targetTemperature: (map['target_temperature'] as num?)?.toDouble(),
      heatingActive: map['heating_active'] == 1 || map['heating_active'] == true,
      coolingActive: map['cooling_active'] == 1 || map['cooling_active'] == true,
      gravity: (map['gravity'] as num?)?.toDouble(),
      tilt: (map['tilt'] as num?)?.toDouble(),
      batteryVoltage: (map['battery_voltage'] as num?)?.toDouble(),
      signalStrength: map['signal_strength'] as int?,
      readingTime: DateTime.parse(map['reading_time'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_type': deviceType.name,
      'batch_id': batchId,
      'temperature': temperature,
      'target_temperature': targetTemperature,
      'heating_active': heatingActive == true ? 1 : 0,
      'cooling_active': coolingActive == true ? 1 : 0,
      'gravity': gravity,
      'tilt': tilt,
      'battery_voltage': batteryVoltage,
      'signal_strength': signalStrength,
      'reading_time': readingTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'DeviceReading($deviceType, temp=$temperature, gravity=$gravity)';
}

/// A registered BrewCreator device
class BrewDevice {
  final String id;
  final String name;
  final DeviceType type;
  final String? macAddress;
  final String? fermenterId;        // Which fermenter this device is assigned to
  final bool isConnected;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  BrewDevice({
    String? id,
    required this.name,
    required this.type,
    this.macAddress,
    this.fermenterId,
    this.isConnected = false,
    this.lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  BrewDevice copyWith({
    String? name,
    DeviceType? type,
    String? macAddress,
    String? fermenterId,
    bool? isConnected,
    DateTime? lastSeen,
  }) {
    return BrewDevice(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      macAddress: macAddress ?? this.macAddress,
      fermenterId: fermenterId ?? this.fermenterId,
      isConnected: isConnected ?? this.isConnected,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory BrewDevice.fromMap(Map<String, dynamic> map) {
    return BrewDevice(
      id: map['id'] as String,
      name: map['name'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DeviceType.ferminator,
      ),
      macAddress: map['mac_address'] as String?,
      fermenterId: map['fermenter_id'] as String?,
      isConnected: map['is_connected'] == 1 || map['is_connected'] == true,
      lastSeen: map['last_seen'] != null
          ? DateTime.parse(map['last_seen'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'mac_address': macAddress,
      'fermenter_id': fermenterId,
      'is_connected': isConnected ? 1 : 0,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'BrewDevice($name, $type)';
}
