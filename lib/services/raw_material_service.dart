import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../database/tables/raw_material_table.dart';
import '../models/raw_material.dart';

/// Service pour gérer les matières premières (CRUD)
class RawMaterialService {
  final DBHelper _dbHelper = DBHelper.instance;

  /// Récupère toutes les matières premières
  Future<List<RawMaterial>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RawMaterialTable.tableName,
      orderBy: '${RawMaterialTable.colType}, ${RawMaterialTable.colName}',
    );
    return maps.map((map) => RawMaterial.fromMap(map)).toList();
  }

  /// Récupère les matières premières par type
  Future<List<RawMaterial>> getByType(MaterialType type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RawMaterialTable.tableName,
      where: '${RawMaterialTable.colType} = ?',
      whereArgs: [type.name],
      orderBy: RawMaterialTable.colName,
    );
    return maps.map((map) => RawMaterial.fromMap(map)).toList();
  }

  /// Récupère une matière première par ID
  Future<RawMaterial?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RawMaterialTable.tableName,
      where: '${RawMaterialTable.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return RawMaterial.fromMap(maps.first);
  }

  /// Recherche des matières premières par nom
  Future<List<RawMaterial>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      RawMaterialTable.tableName,
      where: '${RawMaterialTable.colName} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: RawMaterialTable.colName,
    );
    return maps.map((map) => RawMaterial.fromMap(map)).toList();
  }

  /// Crée une nouvelle matière première
  Future<RawMaterial> create(RawMaterial material) async {
    final db = await _dbHelper.database;
    await db.insert(
      RawMaterialTable.tableName,
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return material;
  }

  /// Met à jour une matière première
  Future<int> update(RawMaterial material) async {
    final db = await _dbHelper.database;
    final updatedMaterial = material.copyWith();
    return await db.update(
      RawMaterialTable.tableName,
      updatedMaterial.toMap(),
      where: '${RawMaterialTable.colId} = ?',
      whereArgs: [material.id],
    );
  }

  /// Supprime une matière première
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      RawMaterialTable.tableName,
      where: '${RawMaterialTable.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Compte les matières premières par type
  Future<Map<MaterialType, int>> countByType() async {
    final db = await _dbHelper.database;
    final result = <MaterialType, int>{};
    
    for (final type in MaterialType.values) {
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${RawMaterialTable.tableName} WHERE ${RawMaterialTable.colType} = ?',
        [type.name],
      ));
      result[type] = count ?? 0;
    }
    
    return result;
  }

  /// Récupère tous les grains (céréales)
  Future<List<RawMaterial>> getGrains() => getByType(MaterialType.grain);

  /// Récupère tous les houblons
  Future<List<RawMaterial>> getHops() => getByType(MaterialType.hop);

  /// Récupère toutes les levures
  Future<List<RawMaterial>> getYeasts() => getByType(MaterialType.yeast);

  /// Récupère tous les autres ingrédients
  Future<List<RawMaterial>> getOthers() => getByType(MaterialType.other);
}
