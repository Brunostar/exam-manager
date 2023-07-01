import 'dart:io';
import 'package:excel/excel.dart';

class ExcelImporter {
  static Future<List<List<dynamic>>> readExcel(String filePath, [String sheetName = ""]) async {
    try {
      // Open the Excel file
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Get the sheet with the specified name, or the first sheet if no name is specified
      var sheet = sheetName.isNotEmpty ? excel.tables[sheetName] : excel.tables.values.toList()[0];

      // Iterate through each row of the sheet and add it to the result list
      List<List<dynamic>> result = [];
      var rows = sheet?.rows;
      for (var row in rows!) {
        result.add(row);
      }
      return result;
    } catch (e) {
      throw Exception('Could not read Excel file: $e');
    }
  }
}