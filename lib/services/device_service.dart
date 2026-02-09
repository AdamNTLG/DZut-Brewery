import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../database/tables/device_table.dart';
import '../models/device_reading.dart';

/// Service for managing BrewCreator devices (Ferminator, Graviator)
///
/// This service handles:
/// - Device registration and discovery
/// - Storing device readings (temperature, gravity curves)
/// - Retrieving historical data for charts
class DeviceService {
  final DBHelper _dbHelper = DBHelper.instance;

  // ========== Device Management ==========

  /// Get all registered devices
  Future<List<BrewDevice>> getAllDevices() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceTable.tableName,
      orderBy: '${DeviceTable.colName} ASC',
    );
    return List<BrewDevice>.from(maps.map((map) => BrewDevice.fromMap(map)));
  }

  /// Get devices by type
  Future<List<BrewDevice>> getDevicesByType(DeviceType type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceTable.tableName,
      where: '${DeviceTable.colType} = ?',
      whereArgs: [type.name],
      orderBy: '${DeviceTable.colName} ASC',
    );
    return List<BrewDevice>.from(maps.map((map) => BrewDevice.fromMap(map)));
  }

  /// Get device by ID
  Future<BrewDevice?> getDeviceById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceTable.tableName,
      where: '${DeviceTable.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BrewDevice.fromMap(maps.first);
  }

  /// Get devices assigned to a fermenter
  Future<List<BrewDevice>> getDevicesForFermenter(String fermenterId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceTable.tableName,
      where: '${DeviceTable.colFermenterId} = ?',
      whereArgs: [fermenterId],
    );
    return List<BrewDevice>.from(maps.map((map) => BrewDevice.fromMap(map)));
  }

  /// Register a new device
  Future<BrewDevice> registerDevice(BrewDevice device) async {
    final db = await _dbHelper.database;
    await db.insert(
      DeviceTable.tableName,
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return device;
  }

  /// Update a device
  Future<int> updateDevice(BrewDevice device) async {
    final db = await _dbHelper.database;
    return await db.update(
      DeviceTable.tableName,
      device.toMap(),
      where: '${DeviceTable.colId} = ?',
      whereArgs: [device.id],
    );
  }

  /// Assign device to a fermenter
  Future<int> assignToFermenter(String deviceId, String? fermenterId) async {
    final db = await _dbHelper.database;
    return await db.update(
      DeviceTable.tableName,
      {
        DeviceTable.colFermenterId: fermenterId,
        DeviceTable.colUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DeviceTable.colId} = ?',
      whereArgs: [deviceId],
    );
  }

  /// Update device connection status
  Future<int> updateConnectionStatus(String deviceId, bool isConnected) async {
    final db = await _dbHelper.database;
    return await db.update(
      DeviceTable.tableName,
      {
        DeviceTable.colIsConnected: isConnected ? 1 : 0,
        DeviceTable.colLastSeen: isConnected ? DateTime.now().toIso8601String() : null,
        DeviceTable.colUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DeviceTable.colId} = ?',
      whereArgs: [deviceId],
    );
  }

  /// Delete a device
  Future<int> deleteDevice(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DeviceTable.tableName,
      where: '${DeviceTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // ========== Device Readings ==========

  /// Store a device reading
  Future<DeviceReading> addReading(DeviceReading reading) async {
    final db = await _dbHelper.database;
    await db.insert(
      DeviceReadingTable.tableName,
      reading.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update device last seen
    await updateConnectionStatus(reading.deviceId, true);

    return reading;
  }

  /// Get latest reading for a device
  Future<DeviceReading?> getLatestReading(String deviceId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceReadingTable.tableName,
      where: '${DeviceReadingTable.colDeviceId} = ?',
      whereArgs: [deviceId],
      orderBy: '${DeviceReadingTable.colReadingTime} DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DeviceReading.fromMap(maps.first);
  }

  /// Get readings for a device within a time range
  Future<List<DeviceReading>> getReadings({
    required String deviceId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '${DeviceReadingTable.colDeviceId} = ?';
    List<dynamic> whereArgs = [deviceId];

    if (from != null) {
      whereClause += ' AND ${DeviceReadingTable.colReadingTime} >= ?';
      whereArgs.add(from.toIso8601String());
    }

    if (to != null) {
      whereClause += ' AND ${DeviceReadingTable.colReadingTime} <= ?';
      whereArgs.add(to.toIso8601String());
    }

    final maps = await db.query(
      DeviceReadingTable.tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${DeviceReadingTable.colReadingTime} ASC',
      limit: limit,
    );

    return List<DeviceReading>.from(maps.map((map) => DeviceReading.fromMap(map)));
  }

  /// Get readings for a batch (all devices)
  Future<List<DeviceReading>> getReadingsForBatch(String batchId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceReadingTable.tableName,
      where: '${DeviceReadingTable.colBatchId} = ?',
      whereArgs: [batchId],
      orderBy: '${DeviceReadingTable.colReadingTime} ASC',
    );
    return List<DeviceReading>.from(maps.map((map) => DeviceReading.fromMap(map)));
  }

  /// Get temperature curve for a batch
  Future<List<DeviceReading>> getTemperatureCurve(String batchId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceReadingTable.tableName,
      where: '${DeviceReadingTable.colBatchId} = ? AND ${DeviceReadingTable.colTemperature} IS NOT NULL',
      whereArgs: [batchId],
      orderBy: '${DeviceReadingTable.colReadingTime} ASC',
    );
    return List<DeviceReading>.from(maps.map((map) => DeviceReading.fromMap(map)));
  }

  /// Get gravity curve for a batch
  Future<List<DeviceReading>> getGravityCurve(String batchId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DeviceReadingTable.tableName,
      where: '${DeviceReadingTable.colBatchId} = ? AND ${DeviceReadingTable.colGravity} IS NOT NULL',
      whereArgs: [batchId],
      orderBy: '${DeviceReadingTable.colReadingTime} ASC',
    );
    return List<DeviceReading>.from(maps.map((map) => DeviceReading.fromMap(map)));
  }

  /// Delete old readings (cleanup)
  Future<int> deleteOldReadings(Duration olderThan) async {
    final db = await _dbHelper.database;
    final cutoff = DateTime.now().subtract(olderThan);
    return await db.delete(
      DeviceReadingTable.tableName,
      where: '${DeviceReadingTable.colReadingTime} < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  /// Delete all readings for a device
  Future<int> deleteReadingsForDevice(String deviceId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DeviceReadingTable.tableName,
      where: '${DeviceReadingTable.colDeviceId} = ?',
      whereArgs: [deviceId],
    );
  }

  // ========== Statistics ==========

  /// Get device statistics
  Future<Map<String, dynamic>> getStats() async {
    final db = await _dbHelper.database;

    final totalDevices = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DeviceTable.tableName}'
    )) ?? 0;

    final connectedDevices = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DeviceTable.tableName} WHERE ${DeviceTable.colIsConnected} = 1'
    )) ?? 0;

    final totalReadings = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${DeviceReadingTable.tableName}'
    )) ?? 0;

    return {
      'total_devices': totalDevices,
      'connected_devices': connectedDevices,
      'total_readings': totalReadings,
    };
  }
}
