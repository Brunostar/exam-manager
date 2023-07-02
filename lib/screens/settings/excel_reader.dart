import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

import '../../database/course.dart';

class ExcelReader extends StatefulWidget {
  final String filePath;

  const ExcelReader({super.key, required this.filePath});

  @override
  _ExcelReaderState createState() => _ExcelReaderState();
}

class _ExcelReaderState extends State<ExcelReader> {
  bool _isLoading = true;
  List<String> _rows = [];
  CourseDatabase courseDb = CourseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _loadExcelFile();
  }

  Future<void> _loadExcelFile() async {
    try {
      // Open the Excel file
      var bytes = File(widget.filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Iterate through the sheets and get the content of the
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row[0]!.value.toString() == "title") {
            continue;
          }
          for (var i = 0; i < excel.tables[table]!.maxCols; i++) {
            setState(() {
              _rows.add(row[i]!.value.toString());
            });
          }
        }
      }
      _addContentToDb();
    } catch (e) {
      throw Exception('Could not read Excel file: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addContentToDb() async {
    for (var row in _rows) {
      try {
        Course course = Course(
            title: row[0],
            code: row[1],
            level: int.parse(row[2]),
            date: row[3],
            start: row[4],
            time: int.parse(row[5]),
            department: "COME"
        );
        // Insert the course into the database
        await courseDb.insertCourse(course);
      } catch (err) {
        print(err);
        continue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Reader'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (context, index) {
                final row = _rows[index];
                return ListTile(
                  title: Text(row),
                );
              },
            ),
    );
  }
}