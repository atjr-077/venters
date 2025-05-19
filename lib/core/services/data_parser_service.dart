// lib/core/services/data_parser_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

/// Service for parsing different file formats into structured data
class DataParserService {
  static final DataParserService _instance = DataParserService._internal();

  factory DataParserService() {
    return _instance;
  }

  DataParserService._internal();

  /// Parse data from a file based on its format
  Future<Map<String, dynamic>> parseFile(File file) async {
    final String fileName = file.path.split('/').last.toLowerCase();
    final String extension = fileName.split('.').last.toLowerCase();

    try {
      switch (extension) {
        case 'csv':
          return await _parseCsvFile(file);
        case 'json':
          return await _parseJsonFile(file);
        case 'xlsx':
        case 'xls':
          return await _parseExcelFile(file);
        default:
          throw FormatException('Unsupported file format: $extension');
      }
    } catch (e) {
      debugPrint('Error parsing file: $e');
      rethrow;
    }
  }

  /// Parse a CSV file into a structured format
  Future<Map<String, dynamic>> _parseCsvFile(File file) async {
    try {
      final input = await file.readAsString();
      final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(input);

      // Extract headers from the first row
      if (rowsAsListOfValues.isEmpty) {
        throw FormatException('CSV file is empty');
      }

      final headers = rowsAsListOfValues[0].map((header) => header.toString()).toList();
      final rows = rowsAsListOfValues.sublist(1);

      // Convert to a list of maps (each row as a map with header keys)
      final List<Map<String, dynamic>> parsedData = rows.map((row) {
        final Map<String, dynamic> rowMap = {};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          rowMap[headers[i]] = row[i];
        }
        return rowMap;
      }).toList();

      return {
        'headers': headers,
        'rows': parsedData,
  "format": "csv",
        'rowCount': parsedData.length,
      };
    } catch (e) {
      debugPrint('Error parsing CSV: $e');
      rethrow;
    }
  }

  /// Parse a JSON file into a structured format
  Future<Map<String, dynamic>> _parseJsonFile(File file) async {
    try {
      final String content = await file.readAsString();
      final dynamic jsonData = json.decode(content);

      if (jsonData is List) {
        // Handle JSON array of objects
        if (jsonData.isEmpty) {
          throw FormatException('JSON file contains an empty array');
        }

        // Extract headers from the first object
        final Map<String, dynamic> firstItem = jsonData[0] as Map<String, dynamic>;
        final List<String> headers = firstItem.keys.toList();

        return {
          'headers': headers,
          'rows': jsonData,
  "format": "json",
          'rowCount': jsonData.length,
        };
      } else if (jsonData is Map) {
        // Handle single JSON object
        return {
          'headers': jsonData.keys.toList(),
          'rows': [jsonData],
  "format": "json",
          'rowCount': 1,
        };
      } else {
        throw FormatException('Unsupported JSON structure');
      }
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
      rethrow;
    }
  }

  /// Parse an Excel file into a structured format
  Future<Map<String, dynamic>> _parseExcelFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Use the first sheet
      if (excel.tables.isEmpty) {
        throw FormatException('Excel file has no sheets');
      }

      final sheet = excel.tables.entries.first.value;
      final rows = sheet.rows;

      if (rows.isEmpty) {
        throw FormatException('Excel sheet is empty');
      }

      // Extract headers from the first row
      final headers = rows[0].map((cell) => cell?.value.toString() ?? '').toList();

      // Convert remaining rows to list of maps
      final List<Map<String, dynamic>> parsedData = [];
      for (int i = 1; i < rows.length; i++) {
        final Map<String, dynamic> rowMap = {};
        for (int j = 0; j < headers.length && j < rows[i].length; j++) {
          rowMap[headers[j]] = rows[i][j]?.value ?? '';
        }
        parsedData.add(rowMap);
      }

      return {
        'headers': headers,
        'rows': parsedData,
  "format": "excel",
        'rowCount': parsedData.length,
      };
    } catch (e) {
      debugPrint('Error parsing Excel: $e');
      rethrow;
    }
  }

  /// Parse data from an API response
  Map<String, dynamic> parseApiResponse(dynamic responseData) {
    try {
      if (responseData is List) {
        // Handle array of objects
        if (responseData.isEmpty) {
          throw FormatException('API response contains an empty array');
        }

        // Extract headers from the first object
        final Map<String, dynamic> firstItem = responseData[0] as Map<String, dynamic>;
        final List<String> headers = firstItem.keys.toList();

        return {
          'headers': headers,
          'rows': responseData,
  "format": "api",
          'rowCount': responseData.length,
        };
      } else if (responseData is Map) {
        // Check if this is a paginated response with a data array
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'] as List;
          if (data.isEmpty) {
            throw FormatException('API response data array is empty');
          }

          final Map<String, dynamic> firstItem = data[0] as Map<String, dynamic>;
          final List<String> headers = firstItem.keys.toList();

          return {
            'headers': headers,
            'rows': data,
  "format": "api",
            'rowCount': data.length,
            'metadata': {
              'pagination': responseData['pagination'],
              'total': responseData['total'],
            },
          };
        } else {
          // Simple object
          return {
            'headers': responseData.keys.toList(),
            'rows': [responseData],
  "format": "api",
            'rowCount': 1,
          };
        }
      } else {
        throw FormatException('Unsupported API response structure');
      }
    } catch (e) {
      debugPrint('Error parsing API response: $e');
      rethrow;
    }
  }
}