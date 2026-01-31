import 'package:sqflite/sqflite.dart' hide Batch;
import '../database/db_helper.dart';
import '../database/tables/batch_table.dart';
import '../database/tables/batch_measurement_table.dart';
import '../models/batch.dart';
import '../models/batch_measurement.dart';
import 'fermenter_service.dart';

/// Service pour gérer les brassins (CRUD)
class BatchService {
  final DBHelper _dbHelper = DBHelper.instance;
  final FermenterService _fermenterService = FermenterService();

  /// Récupère tous les brassins
  Future<List<Batch>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT b.*, r.name as recipe_name, f.name as fermenter_name
      FROM ${BatchTable.tableName} b
      LEFT JOIN recipes r ON b.recipe_id = r.id
      LEFT JOIN fermenters f ON b.fermenter_id = f.id
      ORDER BY b.brew_date DESC
    ''');
    return List<Batch>.from(maps.map((map) => Batch.fromMap(map)));
  }

  /// Récupère les brassins par statut
  Future<List<Batch>> getByStatus(BatchStatus status) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT b.*, r.name as recipe_name, f.name as fermenter_name
      FROM ${BatchTable.tableName} b
      LEFT JOIN recipes r ON b.recipe_id = r.id
      LEFT JOIN fermenters f ON b.fermenter_id = f.id
      WHERE b.status = ?
      ORDER BY b.brew_date DESC
    ''', [status.name]);
    return List<Batch>.from(maps.map((map) => Batch.fromMap(map)));
  }

  /// Récupère les brassins actifs (en cours)
  Future<List<Batch>> getActive() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT b.*, r.name as recipe_name, f.name as fermenter_name
      FROM ${BatchTable.tableName} b
      LEFT JOIN recipes r ON b.recipe_id = r.id
      LEFT JOIN fermenters f ON b.fermenter_id = f.id
      WHERE b.status IN ('brewing', 'fermenting', 'conditioning')
      ORDER BY b.brew_date DESC
    ''');
    return List<Batch>.from(maps.map((map) => Batch.fromMap(map)));
  }

  /// Récupère un brassin par ID
  Future<Batch?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT b.*, r.name as recipe_name, f.name as fermenter_name
      FROM ${BatchTable.tableName} b
      LEFT JOIN recipes r ON b.recipe_id = r.id
      LEFT JOIN fermenters f ON b.fermenter_id = f.id
      WHERE b.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return Batch.fromMap(maps.first);
  }

  /// Récupère les brassins d'une recette
  Future<List<Batch>> getByRecipe(String recipeId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT b.*, r.name as recipe_name, f.name as fermenter_name
      FROM ${BatchTable.tableName} b
      LEFT JOIN recipes r ON b.recipe_id = r.id
      LEFT JOIN fermenters f ON b.fermenter_id = f.id
      WHERE b.recipe_id = ?
      ORDER BY b.brew_date DESC
    ''', [recipeId]);
    return List<Batch>.from(maps.map((map) => Batch.fromMap(map)));
  }

  /// Crée un nouveau brassin
  Future<Batch> create(Batch batch) async {
    final db = await _dbHelper.database;
    await db.insert(
      BatchTable.tableName,
      batch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Marquer le fermenteur comme occupé si assigné
    if (batch.fermenterId != null) {
      await _fermenterService.setAvailability(batch.fermenterId!, false);
    }
    
    return batch;
  }

  /// Met à jour un brassin
  Future<int> update(Batch batch) async {
    final db = await _dbHelper.database;
    final updated = batch.copyWith();
    return await db.update(
      BatchTable.tableName,
      updated.toMap(),
      where: '${BatchTable.colId} = ?',
      whereArgs: [batch.id],
    );
  }

  /// Change le statut d'un brassin
  Future<int> updateStatus(String batchId, BatchStatus newStatus) async {
    final db = await _dbHelper.database;
    
    // Si le brassin est terminé ou archivé, libérer le fermenteur
    if (newStatus == BatchStatus.completed || newStatus == BatchStatus.archived) {
      final batch = await getById(batchId);
      if (batch?.fermenterId != null) {
        await _fermenterService.setAvailability(batch!.fermenterId!, true);
      }
    }
    
    return await db.update(
      BatchTable.tableName,
      {
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: '${BatchTable.colId} = ?',
      whereArgs: [batchId],
    );
  }

  /// Met à jour les densités d'un brassin
  Future<int> updateGravities(String batchId, {double? og, double? fg}) async {
    final db = await _dbHelper.database;
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (og != null) updates['actual_og'] = og;
    if (fg != null) updates['actual_fg'] = fg;
    
    // Calculer l'ABV si on a les deux densités
    if (og != null && fg != null) {
      updates['actual_abv'] = (og - fg) * 131.25;
    }
    
    return await db.update(
      BatchTable.tableName,
      updates,
      where: '${BatchTable.colId} = ?',
      whereArgs: [batchId],
    );
  }

  /// Supprime un brassin
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    
    // Libérer le fermenteur si nécessaire
    final batch = await getById(id);
    if (batch?.fermenterId != null) {
      await _fermenterService.setAvailability(batch!.fermenterId!, true);
    }
    
    return await db.delete(
      BatchTable.tableName,
      where: '${BatchTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // --- Gestion des mesures ---

  /// Récupère les mesures d'un brassin
  Future<List<BatchMeasurement>> getMeasurements(String batchId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      BatchMeasurementTable.tableName,
      where: '${BatchMeasurementTable.colBatchId} = ?',
      whereArgs: [batchId],
      orderBy: '${BatchMeasurementTable.colMeasurementDate} DESC',
    );
    return List<BatchMeasurement>.from(maps.map((map) => BatchMeasurement.fromMap(map)));
  }

  /// Ajoute une mesure
  Future<BatchMeasurement> addMeasurement(BatchMeasurement measurement) async {
    final db = await _dbHelper.database;
    await db.insert(BatchMeasurementTable.tableName, measurement.toMap());
    
    // Mettre à jour la FG du brassin avec la dernière gravité mesurée
    if (measurement.gravity != null) {
      await db.update(
        BatchTable.tableName,
        {
          'actual_fg': measurement.gravity,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: '${BatchTable.colId} = ?',
        whereArgs: [measurement.batchId],
      );
    }
    
    return measurement;
  }

  /// Supprime une mesure
  Future<int> deleteMeasurement(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      BatchMeasurementTable.tableName,
      where: '${BatchMeasurementTable.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Récupère les statistiques des brassins
  Future<Map<String, dynamic>> getStats() async {
    final db = await _dbHelper.database;
    
    final total = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${BatchTable.tableName}'
    )) ?? 0;
    
    final active = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM ${BatchTable.tableName}
      WHERE status IN ('brewing', 'fermenting', 'conditioning')
    ''')) ?? 0;
    
    final completed = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM ${BatchTable.tableName}
      WHERE status = 'completed'
    ''')) ?? 0;
    
    return {
      'total': total,
      'active': active,
      'completed': completed,
    };
  }
}
