/// Database table definitions for BrewCreator devices

/// Table for registered devices
class DeviceTable {
  static const String tableName = 'devices';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colType = 'type';
  static const String colMacAddress = 'mac_address';
  static const String colFermenterId = 'fermenter_id';
  static const String colIsConnected = 'is_connected';
  static const String colLastSeen = 'last_seen';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colName TEXT NOT NULL,
      $colType TEXT NOT NULL,
      $colMacAddress TEXT,
      $colFermenterId TEXT,
      $colIsConnected INTEGER NOT NULL DEFAULT 0,
      $colLastSeen TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colFermenterId) REFERENCES fermenters(id) ON DELETE SET NULL
    )
  ''';

  static List<String> get columns => [
    colId,
    colName,
    colType,
    colMacAddress,
    colFermenterId,
    colIsConnected,
    colLastSeen,
    colCreatedAt,
    colUpdatedAt,
  ];
}

/// Table for device readings (temperature, gravity curves)
class DeviceReadingTable {
  static const String tableName = 'device_readings';

  static const String colId = 'id';
  static const String colDeviceId = 'device_id';
  static const String colDeviceType = 'device_type';
  static const String colBatchId = 'batch_id';
  static const String colTemperature = 'temperature';
  static const String colTargetTemperature = 'target_temperature';
  static const String colHeatingActive = 'heating_active';
  static const String colCoolingActive = 'cooling_active';
  static const String colGravity = 'gravity';
  static const String colTilt = 'tilt';
  static const String colBatteryVoltage = 'battery_voltage';
  static const String colSignalStrength = 'signal_strength';
  static const String colReadingTime = 'reading_time';
  static const String colCreatedAt = 'created_at';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colDeviceId TEXT NOT NULL,
      $colDeviceType TEXT NOT NULL,
      $colBatchId TEXT,
      $colTemperature REAL,
      $colTargetTemperature REAL,
      $colHeatingActive INTEGER,
      $colCoolingActive INTEGER,
      $colGravity REAL,
      $colTilt REAL,
      $colBatteryVoltage REAL,
      $colSignalStrength INTEGER,
      $colReadingTime TEXT NOT NULL,
      $colCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($colDeviceId) REFERENCES ${DeviceTable.tableName}(id) ON DELETE CASCADE,
      FOREIGN KEY ($colBatchId) REFERENCES batches(id) ON DELETE SET NULL
    )
  ''';

  static List<String> get columns => [
    colId,
    colDeviceId,
    colDeviceType,
    colBatchId,
    colTemperature,
    colTargetTemperature,
    colHeatingActive,
    colCoolingActive,
    colGravity,
    colTilt,
    colBatteryVoltage,
    colSignalStrength,
    colReadingTime,
    colCreatedAt,
  ];
}
