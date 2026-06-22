import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._();
  factory LocalDatabase() => _instance;
  LocalDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'efectiva_offline.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE solicitudes_borrador (
        id TEXT PRIMARY KEY,
        cliente_id TEXT,
        cliente_nombre TEXT,
        paso_actual INTEGER NOT NULL DEFAULT 1,
        datos_json TEXT NOT NULL,
        monto_solicitado REAL DEFAULT 0,
        asesor_id TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE visitas_pendientes (
        id TEXT PRIMARY KEY,
        cartera_id TEXT NOT NULL,
        resultado TEXT NOT NULL,
        observacion TEXT,
        timestamp_visita TEXT NOT NULL,
        lat REAL,
        lng REAL,
        pendiente_sync INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE cartera_orden_local (
        id TEXT PRIMARY KEY,
        cartera_id TEXT NOT NULL,
        orden_manual INTEGER NOT NULL DEFAULT 0,
        asesor_id TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_clientes (
        id TEXT PRIMARY KEY,
        datos_json TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_cartera (
        id TEXT PRIMARY KEY,
        datos_json TEXT NOT NULL,
        fecha TEXT NOT NULL,
        asesor_id TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_solicitudes (
        id TEXT PRIMARY KEY,
        datos_json TEXT NOT NULL,
        asesor_id TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  // ── Borradores ────────────────────────────────────────
  Future<int> guardarBorrador(Map<String, dynamic> borrador) async {
    final db = await database;
    return db.insert('solicitudes_borrador', borrador,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> obtenerBorradores(String asesorId) async {
    final db = await database;
    return db.query('solicitudes_borrador',
        where: 'asesor_id = ?', whereArgs: [asesorId],
        orderBy: 'updated_at DESC');
  }

  Future<int> eliminarBorrador(String id) async {
    final db = await database;
    return db.delete('solicitudes_borrador', where: 'id = ?', whereArgs: [id]);
  }

  // ── Visitas pendientes de sync ────────────────────────
  Future<int> guardarVisitaPendiente(Map<String, dynamic> visita) async {
    final db = await database;
    return db.insert('visitas_pendientes', visita);
  }

  Future<List<Map<String, dynamic>>> obtenerVisitasPendientes() async {
    final db = await database;
    return db.query('visitas_pendientes',
        where: 'pendiente_sync = 1');
  }

  Future<int> marcarVisitaSincronizada(String id) async {
    final db = await database;
    return db.update('visitas_pendientes',
        {'pendiente_sync': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  // ── Cache ─────────────────────────────────────────────
  Future<void> guardarCacheClientes(List<Map<String, dynamic>> clientes) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final c in clientes) {
      batch.insert('cache_clientes', {
        'id': c['id'],
        'datos_json': jsonEncode(c),
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> obtenerCacheClientes() async {
    final db = await database;
    final rows = await db.query('cache_clientes', orderBy: 'updated_at DESC');
    return rows.map((r) => jsonDecode(r['datos_json'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> guardarCacheCartera(List<Map<String, dynamic>> cartera, String asesorId, String fecha) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.delete('cache_cartera', where: 'asesor_id = ? AND fecha = ?', whereArgs: [asesorId, fecha]);

    for (final c in cartera) {
      batch.insert('cache_cartera', {
        'id': c['id'],
        'datos_json': jsonEncode(c),
        'fecha': fecha,
        'asesor_id': asesorId,
        'updated_at': now,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> obtenerCacheCartera(String asesorId, String fecha) async {
    final db = await database;
    final rows = await db.query('cache_cartera',
        where: 'asesor_id = ? AND fecha = ?',
        whereArgs: [asesorId, fecha],
        orderBy: 'updated_at DESC');
    return rows.map((r) => jsonDecode(r['datos_json'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> limpiarCache() async {
    final db = await database;
    await db.delete('cache_clientes');
    await db.delete('cache_cartera');
    await db.delete('cache_solicitudes');
  }
}
