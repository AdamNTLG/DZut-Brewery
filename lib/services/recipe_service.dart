import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../database/tables/recipe_table.dart';
import '../database/tables/mash_step_table.dart';
import '../database/tables/recipe_grain_table.dart';
import '../database/tables/recipe_hop_table.dart';
import '../database/tables/recipe_yeast_table.dart';
import '../database/tables/recipe_addition_table.dart';
import '../models/recipe.dart';
import '../models/mash_step.dart';
import '../models/recipe_grain.dart';
import '../models/recipe_hop.dart';
import '../models/recipe_yeast.dart';
import '../models/recipe_addition.dart';

/// Modèle complet d'une recette avec tous ses ingrédients
class RecipeComplete {
  final Recipe recipe;
  final List<MashStep> mashSteps;
  final List<RecipeGrain> grains;
  final List<RecipeHop> hops;
  final List<RecipeYeast> yeasts;
  final List<RecipeAddition> additions;

  RecipeComplete({
    required this.recipe,
    this.mashSteps = const [],
    this.grains = const [],
    this.hops = const [],
    this.yeasts = const [],
    this.additions = const [],
  });

  /// Total des grains en kg
  double get totalGrainsKg => grains.fold(0.0, (sum, g) => sum + g.quantityKg);

  /// Total des houblons en g
  double get totalHopsG => hops.fold(0.0, (sum, h) => sum + h.quantityG);
}

/// Service pour gérer les recettes (CRUD)
class RecipeService {
  final DBHelper _dbHelper = DBHelper.instance;

  /// Récupère toutes les recettes
  Future<List<Recipe>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RecipeTable.tableName,
      orderBy: '${RecipeTable.colUpdatedAt} DESC',
    );
    return maps.map((map) => Recipe.fromMap(map)).toList();
  }

  /// Récupère une recette par ID
  Future<Recipe?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RecipeTable.tableName,
      where: '${RecipeTable.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Recipe.fromMap(maps.first);
  }

  /// Récupère une recette complète avec tous ses ingrédients
  Future<RecipeComplete?> getComplete(String recipeId) async {
    final recipe = await getById(recipeId);
    if (recipe == null) return null;

    final db = await _dbHelper.database;

    // Paliers d'empâtage
    final mashMaps = await db.query(
      MashStepTable.tableName,
      where: '${MashStepTable.colRecipeId} = ?',
      whereArgs: [recipeId],
      orderBy: MashStepTable.colStepOrder,
    );
    final mashSteps = mashMaps.map((m) => MashStep.fromMap(m)).toList();

    // Grains avec infos matière première
    final grainMaps = await db.rawQuery('''
      SELECT rg.*, rm.name as material_name, rm.ebc as material_ebc, rm.potential as material_potential
      FROM ${RecipeGrainTable.tableName} rg
      LEFT JOIN raw_materials rm ON rg.material_id = rm.id
      WHERE rg.recipe_id = ?
    ''', [recipeId]);
    final grains = grainMaps.map((m) => RecipeGrain.fromMap(m)).toList();

    // Houblons avec infos matière première
    final hopMaps = await db.rawQuery('''
      SELECT rh.*, rm.name as material_name, rm.alpha_acid as material_alpha_acid
      FROM ${RecipeHopTable.tableName} rh
      LEFT JOIN raw_materials rm ON rh.material_id = rm.id
      WHERE rh.recipe_id = ?
      ORDER BY rh.hop_use, rh.time_value DESC
    ''', [recipeId]);
    final hops = hopMaps.map((m) => RecipeHop.fromMap(m)).toList();

    // Levures avec infos matière première
    final yeastMaps = await db.rawQuery('''
      SELECT ry.*, rm.name as material_name, rm.attenuation as material_attenuation
      FROM ${RecipeYeastTable.tableName} ry
      LEFT JOIN raw_materials rm ON ry.material_id = rm.id
      WHERE ry.recipe_id = ?
    ''', [recipeId]);
    final yeasts = yeastMaps.map((m) => RecipeYeast.fromMap(m)).toList();

    // Ajouts divers avec infos matière première
    final additionMaps = await db.rawQuery('''
      SELECT ra.*, rm.name as material_name
      FROM ${RecipeAdditionTable.tableName} ra
      LEFT JOIN raw_materials rm ON ra.material_id = rm.id
      WHERE ra.recipe_id = ?
      ORDER BY ra.addition_step
    ''', [recipeId]);
    final additions = additionMaps.map((m) => RecipeAddition.fromMap(m)).toList();

    return RecipeComplete(
      recipe: recipe,
      mashSteps: mashSteps,
      grains: grains,
      hops: hops,
      yeasts: yeasts,
      additions: additions,
    );
  }

  /// Recherche des recettes
  Future<List<Recipe>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RecipeTable.tableName,
      where: '${RecipeTable.colName} LIKE ? OR ${RecipeTable.colBeerStyle} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: RecipeTable.colName,
    );
    return maps.map((map) => Recipe.fromMap(map)).toList();
  }

  /// Crée une nouvelle recette
  Future<Recipe> create(Recipe recipe) async {
    final db = await _dbHelper.database;
    await db.insert(
      RecipeTable.tableName,
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return recipe;
  }

  /// Met à jour une recette
  Future<int> update(Recipe recipe) async {
    final db = await _dbHelper.database;
    final updatedRecipe = recipe.copyWith();
    return await db.update(
      RecipeTable.tableName,
      updatedRecipe.toMap(),
      where: '${RecipeTable.colId} = ?',
      whereArgs: [recipe.id],
    );
  }

  /// Supprime une recette (et tous ses ingrédients via CASCADE)
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      RecipeTable.tableName,
      where: '${RecipeTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // --- Gestion des paliers d'empâtage ---

  /// Ajoute un palier d'empâtage
  Future<MashStep> addMashStep(MashStep step) async {
    final db = await _dbHelper.database;
    await db.insert(MashStepTable.tableName, step.toMap());
    return step;
  }

  /// Met à jour un palier
  Future<int> updateMashStep(MashStep step) async {
    final db = await _dbHelper.database;
    return await db.update(
      MashStepTable.tableName,
      step.copyWith().toMap(),
      where: '${MashStepTable.colId} = ?',
      whereArgs: [step.id],
    );
  }

  /// Supprime un palier
  Future<int> deleteMashStep(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      MashStepTable.tableName,
      where: '${MashStepTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // --- Gestion des grains ---

  Future<RecipeGrain> addGrain(RecipeGrain grain) async {
    final db = await _dbHelper.database;
    await db.insert(RecipeGrainTable.tableName, grain.toMap());
    return grain;
  }

  Future<int> updateGrain(RecipeGrain grain) async {
    final db = await _dbHelper.database;
    return await db.update(
      RecipeGrainTable.tableName,
      grain.copyWith().toMap(),
      where: '${RecipeGrainTable.colId} = ?',
      whereArgs: [grain.id],
    );
  }

  Future<int> deleteGrain(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      RecipeGrainTable.tableName,
      where: '${RecipeGrainTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // --- Gestion des houblons ---

  Future<RecipeHop> addHop(RecipeHop hop) async {
    final db = await _dbHelper.database;
    await db.insert(RecipeHopTable.tableName, hop.toMap());
    return hop;
  }

  Future<int> updateHop(RecipeHop hop) async {
    final db = await _dbHelper.database;
    return await db.update(
      RecipeHopTable.tableName,
      hop.copyWith().toMap(),
      where: '${RecipeHopTable.colId} = ?',
      whereArgs: [hop.id],
    );
  }

  Future<int> deleteHop(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      RecipeHopTable.tableName,
      where: '${RecipeHopTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // --- Gestion des levures ---

  Future<RecipeYeast> addYeast(RecipeYeast yeast) async {
    final db = await _dbHelper.database;
    await db.insert(RecipeYeastTable.tableName, yeast.toMap());
    return yeast;
  }

  Future<int> updateYeast(RecipeYeast yeast) async {
    final db = await _dbHelper.database;
    return await db.update(
      RecipeYeastTable.tableName,
      yeast.copyWith().toMap(),
      where: '${RecipeYeastTable.colId} = ?',
      whereArgs: [yeast.id],
    );
  }

  Future<int> deleteYeast(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      RecipeYeastTable.tableName,
      where: '${RecipeYeastTable.colId} = ?',
      whereArgs: [id],
    );
  }

  // --- Gestion des ajouts divers ---

  Future<RecipeAddition> addAddition(RecipeAddition addition) async {
    final db = await _dbHelper.database;
    await db.insert(RecipeAdditionTable.tableName, addition.toMap());
    return addition;
  }

  Future<int> updateAddition(RecipeAddition addition) async {
    final db = await _dbHelper.database;
    return await db.update(
      RecipeAdditionTable.tableName,
      addition.copyWith().toMap(),
      where: '${RecipeAdditionTable.colId} = ?',
      whereArgs: [addition.id],
    );
  }

  Future<int> deleteAddition(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      RecipeAdditionTable.tableName,
      where: '${RecipeAdditionTable.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Duplique une recette complète
  Future<Recipe> duplicate(String recipeId, String newName) async {
    final complete = await getComplete(recipeId);
    if (complete == null) throw Exception('Recette non trouvée');

    // Créer la nouvelle recette
    final newRecipe = Recipe(
      name: newName,
      beerStyle: complete.recipe.beerStyle,
      volumeLiters: complete.recipe.volumeLiters,
      initialWater: complete.recipe.initialWater,
      finalWater: complete.recipe.finalWater,
      targetOg: complete.recipe.targetOg,
      targetFg: complete.recipe.targetFg,
      targetIbu: complete.recipe.targetIbu,
      targetEbc: complete.recipe.targetEbc,
      targetAbv: complete.recipe.targetAbv,
      boilTime: complete.recipe.boilTime,
      efficiency: complete.recipe.efficiency,
      notes: complete.recipe.notes,
    );
    await create(newRecipe);

    // Dupliquer les paliers
    for (final step in complete.mashSteps) {
      await addMashStep(MashStep(
        recipeId: newRecipe.id,
        stepOrder: step.stepOrder,
        temperature: step.temperature,
        durationMin: step.durationMin,
        description: step.description,
      ));
    }

    // Dupliquer les grains
    for (final grain in complete.grains) {
      await addGrain(RecipeGrain(
        recipeId: newRecipe.id,
        materialId: grain.materialId,
        quantityKg: grain.quantityKg,
        notes: grain.notes,
      ));
    }

    // Dupliquer les houblons
    for (final hop in complete.hops) {
      await addHop(RecipeHop(
        recipeId: newRecipe.id,
        materialId: hop.materialId,
        quantityG: hop.quantityG,
        hopUse: hop.hopUse,
        timeValue: hop.timeValue,
        temperature: hop.temperature,
        notes: hop.notes,
      ));
    }

    // Dupliquer les levures
    for (final yeast in complete.yeasts) {
      await addYeast(RecipeYeast(
        recipeId: newRecipe.id,
        materialId: yeast.materialId,
        quantity: yeast.quantity,
        unit: yeast.unit,
        form: yeast.form,
        notes: yeast.notes,
      ));
    }

    // Dupliquer les ajouts
    for (final addition in complete.additions) {
      await addAddition(RecipeAddition(
        recipeId: newRecipe.id,
        materialId: addition.materialId,
        quantity: addition.quantity,
        unit: addition.unit,
        additionStep: addition.additionStep,
        temperature: addition.temperature,
        timeValue: addition.timeValue,
        notes: addition.notes,
      ));
    }

    return newRecipe;
  }
}
