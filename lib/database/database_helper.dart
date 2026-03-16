import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/weight_record.dart';
import '../models/diet_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dolphin_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE diet_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foodName TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        date TEXT NOT NULL,
        mealType TEXT
      )
    ''');
  }

  // Transaction methods
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  // Weight methods
  Future<int> insertWeightRecord(WeightRecord record) async {
    final db = await database;
    return await db.insert('weight_records', record.toMap());
  }

  Future<List<WeightRecord>> getWeightRecords() async {
    final db = await database;
    final maps = await db.query('weight_records', orderBy: 'date DESC');
    return maps.map((map) => WeightRecord.fromMap(map)).toList();
  }

  // Diet methods
  Future<int> insertDietRecord(DietRecord record) async {
    final db = await database;
    return await db.insert('diet_records', record.toMap());
  }

  Future<List<DietRecord>> getDietRecords() async {
    final db = await database;
    final maps = await db.query('diet_records', orderBy: 'date DESC');
    return maps.map((map) => DietRecord.fromMap(map)).toList();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
