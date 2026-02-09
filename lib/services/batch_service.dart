import 'package:sqflite/sqflite.dart' hide Batch;
import '../database/db_helper.dart';
import '../database/tables/batch_table.dart';
import '../database/tables/batch_measurement_table.dart';
import '../database/tables/batch_step_table.dart';
import '../database/tables/batch_hop_addition_table.dart';
import '../models/batch.dart';
import '../models/batch_measurement.dart';
import '../models/batch_step.dart';
import '../models/batch_hop_addition.dart';
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

  /// Creates a new batch
  Future<Batch> create(Batch batch) async {
    final db = await _dbHelper.database;
    await db.insert(
      BatchTable.tableName,
      batch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Only mark fermenter as occupied if batch is actively brewing (not planned)
    if (batch.fermenterId != null && batch.status != BatchStatus.planned) {
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

  /// Updates batch status
  Future<int> updateStatus(String batchId, BatchStatus newStatus) async {
    final db = await _dbHelper.database;
    final batch = await getById(batchId);

    if (batch?.fermenterId != null) {
      // When starting to brew from planned, mark fermenter as occupied
      if (batch!.status == BatchStatus.planned && newStatus == BatchStatus.brewing) {
        await _fermenterService.setAvailability(batch.fermenterId!, false);
      }
      // When completed or archived, release the fermenter
      else if (newStatus == BatchStatus.completed || newStatus == BatchStatus.archived) {
        await _fermenterService.setAvailability(batch.fermenterId!, true);
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

  // --- Gestion des étapes de brassage ---

  /// Récupère les étapes d'un brassin
  Future<List<BatchStep>> getSteps(String batchId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      BatchStepTable.tableName,
      where: '${BatchStepTable.colBatchId} = ?',
      whereArgs: [batchId],
      orderBy: '${BatchStepTable.colCreatedAt} ASC',
    );
    return List<BatchStep>.from(maps.map((map) => BatchStep.fromMap(map)));
  }

  /// Sauvegarde les étapes d'un brassin (remplace toutes les étapes existantes)
  Future<void> saveSteps(String batchId, List<BatchStep> steps) async {
    final db = await _dbHelper.database;

    // Supprimer les anciennes étapes
    await db.delete(
      BatchStepTable.tableName,
      where: '${BatchStepTable.colBatchId} = ?',
      whereArgs: [batchId],
    );

    // Insérer les nouvelles étapes
    for (final step in steps) {
      await db.insert(
        BatchStepTable.tableName,
        step.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Ajoute une étape
  Future<BatchStep> addStep(BatchStep step) async {
    final db = await _dbHelper.database;
    await db.insert(
      BatchStepTable.tableName,
      step.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return step;
  }

  /// Met à jour une étape
  Future<int> updateStep(BatchStep step) async {
    final db = await _dbHelper.database;
    return await db.update(
      BatchStepTable.tableName,
      step.toMap(),
      where: '${BatchStepTable.colId} = ?',
      whereArgs: [step.id],
    );
  }

  /// Supprime une étape
  Future<int> deleteStep(String stepId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      BatchStepTable.tableName,
      where: '${BatchStepTable.colId} = ?',
      whereArgs: [stepId],
    );
  }

  // --- Hop Additions Management ---

  /// Gets all hop additions for a batch
  Future<List<BatchHopAddition>> getHopAdditions(String batchId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      BatchHopAdditionTable.tableName,
      where: '${BatchHopAdditionTable.colBatchId} = ?',
      whereArgs: [batchId],
      orderBy: '${BatchHopAdditionTable.colCreatedAt} ASC',
    );
    return List<BatchHopAddition>.from(
      maps.map((map) => BatchHopAddition.fromMap(map)),
    );
  }

  /// Adds a hop addition
  Future<BatchHopAddition> addHopAddition(BatchHopAddition addition) async {
    final db = await _dbHelper.database;
    await db.insert(
      BatchHopAdditionTable.tableName,
      addition.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return addition;
  }

  /// Updates a hop addition
  Future<int> updateHopAddition(BatchHopAddition addition) async {
    final db = await _dbHelper.database;
    return await db.update(
      BatchHopAdditionTable.tableName,
      addition.toMap(),
      where: '${BatchHopAdditionTable.colId} = ?',
      whereArgs: [addition.id],
    );
  }

  /// Marks a hop addition as added
  Future<int> markHopAdditionAdded(String additionId) async {
    final db = await _dbHelper.database;
    return await db.update(
      BatchHopAdditionTable.tableName,
      {
        BatchHopAdditionTable.colAddedAt: DateTime.now().toIso8601String(),
        BatchHopAdditionTable.colUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${BatchHopAdditionTable.colId} = ?',
      whereArgs: [additionId],
    );
  }

  /// Marks a dry hop addition as removed
  Future<int> markHopAdditionRemoved(String additionId) async {
    final db = await _dbHelper.database;
    return await db.update(
      BatchHopAdditionTable.tableName,
      {
        BatchHopAdditionTable.colRemovedAt: DateTime.now().toIso8601String(),
        BatchHopAdditionTable.colUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${BatchHopAdditionTable.colId} = ?',
      whereArgs: [additionId],
    );
  }

  /// Deletes a hop addition
  Future<int> deleteHopAddition(String additionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      BatchHopAdditionTable.tableName,
      where: '${BatchHopAdditionTable.colId} = ?',
      whereArgs: [additionId],
    );
  }

  /// Gets hop additions that need attention based on current batch day
  Future<List<BatchHopAddition>> getPendingHopAdditions(
    String batchId,
    int currentDay,
  ) async {
    final additions = await getHopAdditions(batchId);
    return additions.where((a) {
      if (a.type == HopAdditionType.dryHop) {
        return a.shouldAddDryHop(currentDay) || a.shouldRemoveDryHop(currentDay);
      }
      return a.status == HopAdditionStatus.pending;
    }).toList();
  }
}
