import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void createDatabase() async {
  // Get a location using getDatabasesPath
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'exam_db.db');

  // Create the database
  Database database = await openDatabase(
    path,
    version: 1,
    onCreate: (Database db, int version) async {
      // Create the departments table
      await db.execute('''
        CREATE TABLE departments (
          code TEXT PRIMARY KEY,
          name TEXT,
          levels INTEGER
        )
      ''');

      // Create the courses table
      await db.execute('''
        CREATE TABLE courses (
          code TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          department TEXT NOT NULL,
          level INTEGER NOT NULL,
          date TEXT NOT NULL,
          start TEXT NOT NULL,
          time INTEGER NOT NULL,
          FOREIGN KEY (department) REFERENCES departments(code)
        )
      ''');
    },
  );
}
