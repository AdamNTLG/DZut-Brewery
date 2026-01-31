/// Définition de la table des recettes de bière
class RecipeTable {
  static const String tableName = 'recipes';

  // Colonnes
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colBeerStyle = 'beer_style';
  static const String colVolumeLiters = 'volume_liters';
  static const String colInitialWater = 'initial_water';
  static const String colFinalWater = 'final_water';
  static const String colTargetOg = 'target_og';
  static const String colTargetFg = 'target_fg';
  static const String colTargetIbu = 'target_ibu';
  static const String colTargetEbc = 'target_ebc';
  static const String colTargetAbv = 'target_abv';
  static const String colBoilTime = 'boil_time';
  static const String colEfficiency = 'efficiency';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colName TEXT NOT NULL,
      $colBeerStyle TEXT,
      $colVolumeLiters REAL NOT NULL DEFAULT 20.0,
      $colInitialWater REAL,
      $colFinalWater REAL,
      $colTargetOg REAL,
      $colTargetFg REAL,
      $colTargetIbu REAL,
      $colTargetEbc REAL,
      $colTargetAbv REAL,
      $colBoilTime INTEGER DEFAULT 60,
      $colEfficiency REAL DEFAULT 75.0,
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colName,
    colBeerStyle,
    colVolumeLiters,
    colInitialWater,
    colFinalWater,
    colTargetOg,
    colTargetFg,
    colTargetIbu,
    colTargetEbc,
    colTargetAbv,
    colBoilTime,
    colEfficiency,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];
}
