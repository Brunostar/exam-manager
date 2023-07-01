import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/department.dart';

class Course {
  String code;
  String title;
  String department;
  int level;
  String date;
  String start;
  int time;

  Course({
    required this.code,
    required this.title,
    required this.department,
    required this.level,
    required this.date,
    required this.start,
    required this.time,
  });

  Course.fromMap(Map<String, dynamic> map)
      : code = map['code'],
        title = map['title'],
        department = map['department'],
        level = map['level'],
        date = map['date'],
        start = map['start'],
        time = map['time'];

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'department': department,
      'level': level,
      'date': date,
      'start': start,
      'time': time,
    };
  }
}

class CourseDatabase {
  static final CourseDatabase instance = CourseDatabase._init();

  static const _databaseName = 'exam_db.db';
  static const _databaseVersion = 1;

  static Database? _database;

  CourseDatabase._init();

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
      CREATE TABLE courses (
        code TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        department TEXT NOT NULL,
        level INTEGER NOT NULL,
        date TEXT NOT NULL,
        start TEXT NOT NULL,
        time INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertCourses(List<Course> courses) async {
    final db = await instance.database;

    for (Course course in courses) {
      await db.insert(
        'courses',
        course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertCourse(Course course) async {
    final db = await instance.database;

    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Course>> getCourses() async {
    final db = await instance.database;

    final maps = await db.query('courses');

    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<List<Course>> getCoursesByDepartment(String depCode) async {
    final db = await instance.database;

    final maps = await db.query(
      'courses',
      where: 'department = ?',
      whereArgs: [depCode],
    );

    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<void> updateCourse(Course course) async {
    final db = await instance.database;

    await db.update(
      'courses',
      course.toMap(),
      where: 'code = ?',
      whereArgs: [course.code],
    );
  }

  Future<void> deleteCourse(Course course) async {
    final db = await instance.database;

    await db.delete(
      'courses',
      where: 'code = ?',
      whereArgs: [course.code],
    );
  }

  deleteCoursesByDepartment(Department department) async {
    final db = await instance.database;

    await db.delete(
      'courses',
      where: 'department = ?',
      whereArgs: [department.code]
    );
  }
}