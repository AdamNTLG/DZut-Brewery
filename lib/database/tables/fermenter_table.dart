/// Définition de la table des fermenteurs/bassins
/// 
/// Gère l'inventaire des équipements de fermentation
class FermenterTable {
  static const String tableName = 'fermenters';

  // Colonnes
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCapacityLiters = 'capacity_liters';
  static const String colMaterial = 'material';
  static const String colIsAvailable = 'is_available';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Types de matériaux
  static const String materialPlastic = 'plastic';
  static const String materialInox = 'inox';
  static const String materialGlass = 'glass';
  static const String materialOther = 'other';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colName TEXT NOT NULL,
      $colCapacityLiters REAL NOT NULL,
      $colMaterial TEXT CHECK($colMaterial IN ('$materialPlastic', '$materialInox', '$materialGlass', '$materialOther')),
      $colIsAvailable INTEGER DEFAULT 1,
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colName,
    colCapacityLiters,
    colMaterial,
    colIsAvailable,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];

  /// Labels des matériaux en français
  static const Map<String, String> materialLabels = {
    materialPlastic: 'Plastique',
    materialInox: 'Inox',
    materialGlass: 'Verre',
    materialOther: 'Autre',
  };

  /// Retourne le label d'un matériau
  static String getMaterialLabel(String material) {
    return materialLabels[material] ?? material;
  }
}
