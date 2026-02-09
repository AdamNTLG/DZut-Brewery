/// Database table definition for batch hop additions
///
/// Tracks hop additions during brewing (bittering, flavor, aroma)
/// and fermentation (dry hopping) with timing information
class BatchHopAdditionTable {
  static const String tableName = 'batch_hop_additions';

  // Columns
  static const String colId = 'id';
  static const String colBatchId = 'batch_id';
  static const String colHopName = 'hop_name';
  static const String colAmountGrams = 'amount_grams';
  static const String colType = 'type';
  static const String colBoilMinutes = 'boil_minutes';
  static const String colDryHopStartDay = 'dry_hop_start_day';
  static const String colDryHopEndDay = 'dry_hop_end_day';
  static const String colAddedAt = 'added_at';
  static const String colRemovedAt = 'removed_at';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Table creation script
  static const String createTable = '''
    CREATE TABLE $tableName (
      $colId TEXT PRIMARY KEY,
      $colBatchId TEXT NOT NULL,
      $colHopName TEXT NOT NULL,
      $colAmountGrams REAL NOT NULL,
      $colType TEXT NOT NULL,
      $colBoilMinutes INTEGER,
      $colDryHopStartDay INTEGER,
      $colDryHopEndDay INTEGER,
      $colAddedAt TEXT,
      $colRemovedAt TEXT,
      $colNotes TEXT,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($colBatchId) REFERENCES batches(id) ON DELETE CASCADE
    )
  ''';

  /// List of columns for queries
  static List<String> get columns => [
    colId,
    colBatchId,
    colHopName,
    colAmountGrams,
    colType,
    colBoilMinutes,
    colDryHopStartDay,
    colDryHopEndDay,
    colAddedAt,
    colRemovedAt,
    colNotes,
    colCreatedAt,
    colUpdatedAt,
  ];
}
