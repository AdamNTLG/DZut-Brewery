import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables/raw_material_table.dart';
import 'tables/recipe_table.dart';
import 'tables/mash_step_table.dart';
import 'tables/recipe_grain_table.dart';
import 'tables/recipe_hop_table.dart';
import 'tables/recipe_yeast_table.dart';
import 'tables/recipe_addition_table.dart';
import 'tables/fermenter_table.dart';
import 'tables/batch_table.dart';
import 'tables/batch_measurement_table.dart';
import 'tables/batch_step_table.dart';

/// Singleton pour gérer la base de données SQLite
/// 
/// Utilisation:
/// ```dart
/// final db = await DBHelper.instance.database;
/// ```
class DBHelper {
  static const String _databaseName = 'brewmaster.db';
  static const int _databaseVersion = 2;

  // Singleton pattern
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  /// Retourne l'instance de la base de données
  /// Crée la base si elle n'existe pas
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Active les clés étrangères
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Crée toutes les tables lors de la première installation
  Future<void> _onCreate(Database db, int version) async {
    // Tables principales (ordre important pour les foreign keys)
    await db.execute(RawMaterialTable.createTable);
    await db.execute(RecipeTable.createTable);
    await db.execute(FermenterTable.createTable);
    
    // Tables liées aux recettes
    await db.execute(MashStepTable.createTable);
    await db.execute(RecipeGrainTable.createTable);
    await db.execute(RecipeHopTable.createTable);
    await db.execute(RecipeYeastTable.createTable);
    await db.execute(RecipeAdditionTable.createTable);
    
    // Tables de suivi
    await db.execute(BatchTable.createTable);
    await db.execute(BatchMeasurementTable.createTable);
    await db.execute(BatchStepTable.createTable);

    // Création des index pour optimiser les requêtes
    await _createIndexes(db);

    // Insertion de données de démonstration (optionnel)
    await _insertSampleData(db);
  }

  /// Gère les migrations de version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration v1 -> v2: Ajout de la table des étapes de brassins
    if (oldVersion < 2) {
      await db.execute(BatchStepTable.createTable);
      await db.execute(
        'CREATE INDEX idx_batch_steps_batch ON ${BatchStepTable.tableName}(batch_id)'
      );
    }
  }

  /// Crée les index pour optimiser les performances
  Future<void> _createIndexes(Database db) async {
    // Index sur les matières premières
    await db.execute(
      'CREATE INDEX idx_raw_materials_type ON ${RawMaterialTable.tableName}(type)'
    );
    
    // Index sur les recettes
    await db.execute(
      'CREATE INDEX idx_recipes_style ON ${RecipeTable.tableName}(beer_style)'
    );
    
    // Index sur les brassins
    await db.execute(
      'CREATE INDEX idx_batches_status ON ${BatchTable.tableName}(status)'
    );
    await db.execute(
      'CREATE INDEX idx_batches_recipe ON ${BatchTable.tableName}(recipe_id)'
    );
    
    // Index sur les mesures
    await db.execute(
      'CREATE INDEX idx_measurements_batch ON ${BatchMeasurementTable.tableName}(batch_id)'
    );

    // Index sur les étapes de brassins
    await db.execute(
      'CREATE INDEX idx_batch_steps_batch ON ${BatchStepTable.tableName}(batch_id)'
    );
  }

  /// Insère des données de démonstration
  Future<void> _insertSampleData(Database db) async {
    // Quelques malts de base
    await db.insert(RawMaterialTable.tableName, {
      'id': 'malt_pilsner',
      'name': 'Malt Pilsner',
      'type': 'grain',
      'price': 2.50,
      'unit': 'kg',
      'ebc': 3.5,
      'potential': 37.0,
      'notes': 'Malt de base pour bières blondes',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert(RawMaterialTable.tableName, {
      'id': 'malt_munich',
      'name': 'Malt Munich',
      'type': 'grain',
      'price': 3.00,
      'unit': 'kg',
      'ebc': 15.0,
      'potential': 35.0,
      'notes': 'Apporte des notes maltées et une couleur ambrée',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert(RawMaterialTable.tableName, {
      'id': 'malt_cara',
      'name': 'Malt Caramunich',
      'type': 'grain',
      'price': 3.50,
      'unit': 'kg',
      'ebc': 110.0,
      'potential': 33.0,
      'notes': 'Notes caramel et toffee',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Quelques houblons
    await db.insert(RawMaterialTable.tableName, {
      'id': 'hop_cascade',
      'name': 'Cascade',
      'type': 'hop',
      'price': 4.50,
      'unit': 'g',
      'alpha_acid': 5.5,
      'notes': 'Agrumes, floral - Houblon américain classique',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert(RawMaterialTable.tableName, {
      'id': 'hop_citra',
      'name': 'Citra',
      'type': 'hop',
      'price': 6.00,
      'unit': 'g',
      'alpha_acid': 12.0,
      'notes': 'Tropical, citrus, passion - Très aromatique',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert(RawMaterialTable.tableName, {
      'id': 'hop_saaz',
      'name': 'Saaz',
      'type': 'hop',
      'price': 4.00,
      'unit': 'g',
      'alpha_acid': 3.5,
      'notes': 'Épicé, terreux - Houblon noble tchèque',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Quelques levures
    await db.insert(RawMaterialTable.tableName, {
      'id': 'yeast_us05',
      'name': 'Safale US-05',
      'type': 'yeast',
      'price': 4.50,
      'unit': 'sachet',
      'attenuation': 81.0,
      'form': 'dry',
      'notes': 'Levure américaine neutre, très polyvalente',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert(RawMaterialTable.tableName, {
      'id': 'yeast_s04',
      'name': 'Safale S-04',
      'type': 'yeast',
      'price': 4.50,
      'unit': 'sachet',
      'attenuation': 75.0,
      'form': 'dry',
      'notes': 'Levure anglaise, notes fruitées',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert(RawMaterialTable.tableName, {
      'id': 'yeast_w34',
      'name': 'Safbrew WB-06',
      'type': 'yeast',
      'price': 5.00,
      'unit': 'sachet',
      'attenuation': 86.0,
      'form': 'dry',
      'notes': 'Levure de blé, banane et clou de girofle',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Un fermenteur par défaut
    await db.insert(FermenterTable.tableName, {
      'id': 'fermenter_1',
      'name': 'Fermenteur Principal',
      'capacity_liters': 30.0,
      'material': 'inox',
      'is_available': 1,
      'notes': 'Fermenteur inox 30L avec robinet',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  /// Supprime et recrée la base de données (pour tests/reset)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    await close();
    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}
