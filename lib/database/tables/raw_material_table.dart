/// Définition de la table des matières premières
/// 
/// Types supportés:
/// - grain: Céréales et malts
/// - hop: Houblons
/// - yeast: Levures
/// - other: Autres ingrédients (épices, sucres, etc.)
class RawMaterialTable {
  static const String tableName = 'raw_materials';

  // Colonnes
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colType = 'type';
  static const String colPrice = 'price';
  static const String colUnit = 'unit';
  static const String colEbc = 'ebc';
  static const String colPotential = 'potential';
  static const String colAlphaAcid = 'alpha_acid';
  static const String colAttenuation = 'attenuation';
  static const String colForm = 'form';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Types de matières premières
  static const String typeGrain = 'grain';
  static const String typeHop = 'hop';
  static const String typeYeast = 'yeast';
  static const String typeOther = 'other';

  // Formes de levures
  static const String formDry = 'dry';
  static const String formLiquid = 'liquid';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colName TEXT NOT NULL,
      $colType TEXT NOT NULL CHECK($colType IN ('$typeGrain', '$typeHop', '$typeYeast', '$typeOther')),
      $colPrice REAL DEFAULT 0.0,
      $colUnit TEXT DEFAULT 'kg',
      $colEbc REAL,
      $colPotential REAL,
      $colAlphaAcid REAL,
      $colAttenuation REAL,
      $colForm TEXT CHECK($colForm IN ('$formDry', '$formLiquid') OR $colForm IS NULL),
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colName,
    colType,
    colPrice,
    colUnit,
    colEbc,
    colPotential,
    colAlphaAcid,
    colAttenuation,
    colForm,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];
}
