class StorageTemplates {
  // ---------------------------------------------------------------------------
  // 1. Hive Storage Templates
  // ---------------------------------------------------------------------------
  static String hiveServiceTemplate() {
    return '''
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return await Hive.openBox<T>(boxName);
  }

  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  Future<T?> get<T>(String boxName, String key, {T? defaultValue}) async {
    final box = await openBox<T>(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> delete<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    await box.delete(key);
  }

  Future<void> clear<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    await box.clear();
  }
}
''';
  }

  // ---------------------------------------------------------------------------
  // 2. SQLite (sqflite) Templates
  // ---------------------------------------------------------------------------
  static String sqliteHelperTemplate() {
    return '''
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _dbName = 'app_database.db';
  static const int _dbVersion = 1;

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Example table creation
    await db.execute(\'''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    \''');
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> row, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, row, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }
}
''';
  }

  // ---------------------------------------------------------------------------
  // 3. Drift Templates
  // ---------------------------------------------------------------------------
  static String driftDatabaseTemplate(String packageName) {
    return '''
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Items])
class AppDatabase extends _\$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Example CRUD operations
  Future<List<Item>> getAllItems() => select(items).get();
  Future<int> addItem(ItemsCompanion item) => into(items).insert(item);
  Future<bool> updateItem(Item item) => update(items).replace(item);
  Future<int> deleteItem(Item item) => delete(items).delete(item);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_drift_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
''';
  }

  // ---------------------------------------------------------------------------
  // 4. ObjectBox Templates
  // ---------------------------------------------------------------------------
  static String objectBoxStoreTemplate(String packageName) {
    return '''
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// Note: ObjectBox generator produces objectbox.g.dart after running build_runner
// import 'objectbox.g.dart';

class ObjectBoxStore {
  /// Store instance for managing entities
  // late final Store store;

  static Future<ObjectBoxStore> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storePath = p.join(docsDir.path, "objectbox");

    // final store = await openStore(directory: storePath);
    // return ObjectBoxStore._create(store);
    return ObjectBoxStore._create();
  }

  ObjectBoxStore._create();
}
''';
  }
}
