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
    for (var i = 0; i < _rows.length; i += 6) {
      try {
        Course course = Course(
            title: _rows[i+0],
            code: _rows[i+1],
            level: double.parse(_rows[i+2]).toInt(),
            date: _rows[i+3],
            start: _rows[i+4],
            time: double.parse(_rows[i+5]).toInt(),
            department: _rows[i+1].substring(0,4)
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
    if(!_isLoading) Navigator.pop(context);
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