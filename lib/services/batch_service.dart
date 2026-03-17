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
import '../models/recipe_hop.dart';
import 'fermenter_service.dart';
import 'recipe_service.dart';

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

  /// Met à jour le fermenteur assigné à un brassin
  Future<void> updateFermenter(String batchId, String? fermenterId) async {
    final db = await _dbHelper.database;
    await db.update(
      BatchTable.tableName,
      {
        'fermenter_id': fermenterId,
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

  // --- Génération automatique depuis la recette ---

  /// Crée un brassin avec génération automatique des étapes et houblons
  Future<Batch> createWithSteps(Batch batch) async {
    final createdBatch = await create(batch);
    await generateStepsFromRecipe(createdBatch.id, createdBatch.recipeId);
    await generateHopAdditionsFromRecipe(createdBatch.id, createdBatch.recipeId);
    return createdBatch;
  }

  /// Génère les étapes de brassage à partir du contenu de la recette
  Future<List<BatchStep>> generateStepsFromRecipe(String batchId, String recipeId) async {
    final recipeService = RecipeService();
    final complete = await recipeService.getComplete(recipeId);
    if (complete == null) return [];

    final steps = <BatchStep>[];
    final r = complete.recipe;

    // 1. Empâtage (un step par palier)
    if (complete.mashSteps.isNotEmpty) {
      for (final mashStep in complete.mashSteps) {
        steps.add(BatchStep(
          batchId: batchId,
          type: StepType.mashing,
          customName: mashStep.description ?? 'Palier ${mashStep.stepOrder}',
          temperature: mashStep.temperature,
          notes: '${mashStep.temperature.toStringAsFixed(0)}°C pendant ${mashStep.durationMin} min',
        ));
      }
    } else {
      steps.add(BatchStep(
        batchId: batchId,
        type: StepType.mashing,
        customName: 'Empâtage',
        temperature: 66,
        notes: 'Pas de paliers définis dans la recette',
      ));
    }

    // 2. Rinçage
    steps.add(BatchStep(
      batchId: batchId,
      type: StepType.sparging,
      customName: 'Rinçage',
      temperature: 78,
    ));

    // 3. Ébullition avec rappels houblons
    final boilHops = complete.hops.where((h) => h.hopUse == HopUse.boil).toList();
    boilHops.sort((a, b) => b.timeValue.compareTo(a.timeValue));
    String boilNotes = 'Ébullition ${r.boilTime} min';
    if (boilHops.isNotEmpty) {
      boilNotes += '\n';
      for (final hop in boilHops) {
        boilNotes += '- ${hop.materialName ?? "Houblon"} ${hop.quantityG.toStringAsFixed(0)}g à ${hop.timeValue.toStringAsFixed(0)} min\n';
      }
    }
    steps.add(BatchStep(
      batchId: batchId,
      type: StepType.boiling,
      customName: 'Ébullition (${r.boilTime} min)',
      temperature: 100,
      notes: boilNotes.trim(),
    ));

    // 4. Hors flamme (si houblons whirlpool)
    final whirlpoolHops = complete.hops.where((h) => h.hopUse == HopUse.whirlpool).toList();
    if (whirlpoolHops.isNotEmpty) {
      String whirlpoolNotes = '';
      for (final hop in whirlpoolHops) {
        whirlpoolNotes += '${hop.materialName ?? "Houblon"} ${hop.quantityG.toStringAsFixed(0)}g @ ${hop.effectiveTemperature.toStringAsFixed(0)}°C ${hop.timeValue.toStringAsFixed(0)} min\n';
      }
      steps.add(BatchStep(
        batchId: batchId,
        type: StepType.boiling,
        customName: 'Hors flamme',
        temperature: whirlpoolHops.first.effectiveTemperature,
        notes: whirlpoolNotes.trim(),
      ));
    }

    // 5. Refroidissement
    steps.add(BatchStep(
      batchId: batchId,
      type: StepType.cooling,
      customName: 'Refroidissement',
      notes: 'Refroidir jusqu\'à température d\'ensemencement',
    ));

    // 6. Ensemencement
    String yeastNotes = '';
    for (final yeast in complete.yeasts) {
      yeastNotes += '${yeast.materialName ?? "Levure"} - ${yeast.quantity.toStringAsFixed(0)} ${yeast.unit}\n';
    }
    steps.add(BatchStep(
      batchId: batchId,
      type: StepType.pitching,
      customName: 'Ensemencement',
      notes: yeastNotes.trim().isNotEmpty ? yeastNotes.trim() : null,
    ));

    // 7. Fermentation
    steps.add(BatchStep(
      batchId: batchId,
      type: StepType.fermentation,
      customName: 'Fermentation',
    ));

    // 8. Dry Hopping (si houblons dry hop)
    final dryHops = complete.hops.where((h) => h.hopUse == HopUse.dryHop).toList();
    if (dryHops.isNotEmpty) {
      String dryHopNotes = '';
      for (final hop in dryHops) {
        dryHopNotes += '${hop.materialName ?? "Houblon"} ${hop.quantityG.toStringAsFixed(0)}g - ${hop.timeValue.toStringAsFixed(0)} jours avant fin\n';
      }
      steps.add(BatchStep(
        batchId: batchId,
        type: StepType.dryHopping,
        customName: 'Dry Hopping',
        notes: dryHopNotes.trim(),
      ));
    }

    // 9. Conditionnement
    steps.add(BatchStep(
      batchId: batchId,
      type: StepType.conditioning,
      customName: 'Conditionnement',
    ));

    await saveSteps(batchId, steps);
    return steps;
  }

  /// Génère les ajouts de houblon du brassin depuis la recette
  Future<void> generateHopAdditionsFromRecipe(String batchId, String recipeId) async {
    final recipeService = RecipeService();
    final complete = await recipeService.getComplete(recipeId);
    if (complete == null) return;

    for (final hop in complete.hops) {
      HopAdditionType type;
      int? boilMinutes;
      int? dryHopStartDay;

      switch (hop.hopUse) {
        case HopUse.boil:
          type = hop.timeValue >= 30 ? HopAdditionType.bittering : HopAdditionType.flavor;
          boilMinutes = hop.timeValue.toInt();
          break;
        case HopUse.whirlpool:
          type = HopAdditionType.aroma;
          break;
        case HopUse.dryHop:
          type = HopAdditionType.dryHop;
          dryHopStartDay = hop.timeValue.toInt();
          break;
      }

      await addHopAddition(BatchHopAddition(
        batchId: batchId,
        hopName: hop.materialName ?? 'Houblon',
        amountGrams: hop.quantityG,
        type: type,
        boilMinutes: boilMinutes,
        dryHopStartDay: dryHopStartDay,
      ));
    }
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
