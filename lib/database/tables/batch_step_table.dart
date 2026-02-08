/// Définition de la table des étapes de brassins
///
/// Permet de suivre les différentes étapes du brassage
/// avec leurs heures de début et fin
class BatchStepTable {
  static const String tableName = 'batch_steps';

  // Colonnes
  static const String colId = 'id';
  static const String colBatchId = 'batch_id';
  static const String colType = 'type';
  static const String colCustomName = 'custom_name';
  static const String colPlannedStart = 'planned_start';
  static const String colPlannedEnd = 'planned_end';
  static const String colActualStart = 'actual_start';
  static const String colActualEnd = 'actual_end';
  static const String colTemperature = 'temperature';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Script de création de la table
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colBatchId TEXT NOT NULL,
      $colType TEXT NOT NULL,
      $colCustomName TEXT,
      $colPlannedStart TEXT,
      $colPlannedEnd TEXT,
      $colActualStart TEXT,
      $colActualEnd TEXT,
      $colTemperature REAL,
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
    colType,
    colCustomName,
    colPlannedStart,
    colPlannedEnd,
    colActualStart,
    colActualEnd,
    colTemperature,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];
}
