/// Définition de la table des mesures de brassins
/// 
/// Permet de suivre l'évolution de la fermentation
/// avec des mesures de température, densité et pH
class BatchMeasurementTable {
  static const String tableName = 'batch_measurements';

  // Colonnes
  static const String colId = 'id';
  static const String colBatchId = 'batch_id';
  static const String colMeasurementDate = 'measurement_date';
  static const String colTemperature = 'temperature';
  static const String colGravity = 'gravity';
  static const String colPh = 'ph';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colBatchId TEXT NOT NULL,
      $colMeasurementDate TEXT NOT NULL,
      $colTemperature REAL,
      $colGravity REAL,
      $colPh REAL,
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colBatchId) REFERENCES batches(id) ON DELETE CASCADE
    )
  ''';

  /// Liste des colonnes pour les requêtes
  static List<String> get columns => [
    colId,
    colBatchId,
    colMeasurementDate,
    colTemperature,
    colGravity,
    colPh,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];
}
