import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

enum DatabaseType { sqlite, mysql, postgres }

class DatabaseConfig {
  static late DatabaseType databaseType;
  static late Database? _sqliteDb;
  static final DatabaseConfig _instance = DatabaseConfig._internal();

  factory DatabaseConfig() {
    return _instance;
  }

  DatabaseConfig._internal();

  static Future<void> initialize({
    DatabaseType type = DatabaseType.sqlite,
  }) async {
    databaseType = type;
    if (type == DatabaseType.sqlite) {
      await _initializeSQLite();
    }
  }

  static Future<void> _initializeSQLite() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/dynamic_attendance.db';
    _sqliteDb = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullname TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        kontak TEXT,
        nip TEXT UNIQUE,
        client TEXT,
        departement TEXT,
        posisi TEXT,
        no_bpjs TEXT,
        no_jmo TEXT,
        status TEXT DEFAULT 'active',
        device TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Database? get sqliteDb => _sqliteDb;

  static Future<void> closeDatabase() async {
    if (_sqliteDb != null) {
      await _sqliteDb!.close();
    }
  }
}