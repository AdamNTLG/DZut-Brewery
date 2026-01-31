import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../database/tables/fermenter_table.dart';
import '../database/tables/batch_table.dart';
import '../models/fermenter.dart';

/// Service pour gérer les fermenteurs (CRUD)
class FermenterService {
  final DBHelper _dbHelper = DBHelper.instance;

  /// Récupère tous les fermenteurs
  Future<List<Fermenter>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      FermenterTable.tableName,
      orderBy: FermenterTable.colName,
    );
    return maps.map((map) => Fermenter.fromMap(map)).toList();
  }

  /// Récupère les fermenteurs disponibles
  Future<List<Fermenter>> getAvailable() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      FermenterTable.tableName,
      where: '${FermenterTable.colIsAvailable} = ?',
      whereArgs: [1],
      orderBy: FermenterTable.colName,
    );
    return maps.map((map) => Fermenter.fromMap(map)).toList();
  }

  /// Récupère un fermenteur par ID
  Future<Fermenter?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      FermenterTable.tableName,
      where: '${FermenterTable.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Fermenter.fromMap(maps.first);
  }

  /// Crée un nouveau fermenteur
  Future<Fermenter> create(Fermenter fermenter) async {
    final db = await _dbHelper.database;
    await db.insert(
      FermenterTable.tableName,
      fermenter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return fermenter;
  }

  /// Met à jour un fermenteur
  Future<int> update(Fermenter fermenter) async {
    final db = await _dbHelper.database;
    final updated = fermenter.copyWith();
    return await db.update(
      FermenterTable.tableName,
      updated.toMap(),
      where: '${FermenterTable.colId} = ?',
      whereArgs: [fermenter.id],
    );
  }

  /// Supprime un fermenteur
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      FermenterTable.tableName,
      where: '${FermenterTable.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Change la disponibilité d'un fermenteur
  Future<int> setAvailability(String id, bool isAvailable) async {
    final db = await _dbHelper.database;
    return await db.update(
      FermenterTable.tableName,
      {
        'is_available': isAvailable ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: '${FermenterTable.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Vérifie si un fermenteur est utilisé par un brassin actif
  Future<bool> isInUse(String fermenterId) async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM ${BatchTable.tableName}
      WHERE ${BatchTable.colFermenterId} = ?
      AND ${BatchTable.colStatus} IN ('brewing', 'fermenting', 'conditioning')
    ''', [fermenterId]));
    return (count ?? 0) > 0;
  }

  /// Récupère les statistiques des fermenteurs
  Future<Map<String, int>> getStats() async {
    final db = await _dbHelper.database;
    final total = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${FermenterTable.tableName}'
    )) ?? 0;
    final available = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${FermenterTable.tableName} WHERE is_available = 1'
    )) ?? 0;
    
    return {
      'total': total,
      'available': available,
      'inUse': total - available,
    };
  }
}
