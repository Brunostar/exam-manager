import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Department {
  String code;
  String name;
  int levels;

  Department({
    required this.code,
    required this.name,
    required this.levels,
  });

  Department.fromMap(Map<String, dynamic> map)
      : code = map['code'],
        name = map['name'],
        levels = map['levels'];

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'levels': levels,
    };
  }
}

class DepartmentDatabase {
  static final DepartmentDatabase instance = DepartmentDatabase._init();

  static const _databaseName = 'exam_db.db';
  static const _databaseVersion = 1;

  static Database? _database;

  DepartmentDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE departments (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        levels INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertDepartments(List<Department> departments) async {
    final db = await instance.database;

    for (Department department in departments) {
      await db.insert(
        'departments',
        department.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertDepartment(Department department) async {
    final db = await instance.database;

    await db.insert(
      'departments',
      department.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Department>> getDepartments() async {
    final db = await instance.database;

    final maps = await db.query('departments');

    return List.generate(maps.length, (i) {
      return Department.fromMap(maps[i]);
    });
  }

  Future<void> updateDepartment(Department department) async {
    final db = await instance.database;

    await db.update(
      'departments',
      department.toMap(),
      where: 'code = ?',
      whereArgs: [department.code],
    );
  }

  Future<void> deleteDepartment(Department department) async {
    final db = await instance.database;

    await db.delete(
      'departments',
      where: 'code = ?',
      whereArgs: [department.code],
    );
  }
}