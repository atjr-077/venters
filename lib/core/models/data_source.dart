// lib/core/models/data_source.dart
import 'dart:io';

/// Represents the source of data (file upload or API)
class DataSource {
  final DataSourceType type;
  final String? filePath;
  final File? file;
  final String? fileName;
  final String? fileFormat;
  final String? apiEndpoint;
  final Map<String, dynamic>? apiHeaders;
  final Map<String, dynamic>? apiQueryParams;
  final int? rowCount;
  final dynamic parsedData;

  DataSource({
    required this.type,
    this.filePath,
    this.file,
    this.fileName,
    this.fileFormat,
    this.apiEndpoint,
    this.apiHeaders,
    this.apiQueryParams,
    this.rowCount,
    this.parsedData,
  });

  /// Creates a file-based data source
  static DataSource fromFile(File file, {
    String? fileFormat,
    dynamic parsedData,
    int? rowCount,
  }) {
    final String fileName = file.path.split('/').last;
    final String detectedFormat = fileFormat ?? fileName.split('.').last.toLowerCase();

    return DataSource(
      type: DataSourceType.file,
      file: file,
      filePath: file.path,
      fileName: fileName,
      fileFormat: detectedFormat,
      parsedData: parsedData,
      rowCount: rowCount,
    );
  }

  /// Creates an API-based data source
  static DataSource fromApi(String apiEndpoint, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
    dynamic parsedData,
    int? rowCount,
  }) {
    return DataSource(
      type: DataSourceType.api,
      apiEndpoint: apiEndpoint,
      apiHeaders: headers,
      apiQueryParams: queryParams,
      parsedData: parsedData,
      rowCount: rowCount,
    );
  }

  /// Create a copy of this data source with some fields updated
  DataSource copyWith({
    DataSourceType? type,
    String? filePath,
    File? file,
    String? fileName,
    String? fileFormat,
    String? apiEndpoint,
    Map<String, dynamic>? apiHeaders,
    Map<String, dynamic>? apiQueryParams,
    int? rowCount,
    dynamic parsedData,
  }) {
    return DataSource(
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      file: file ?? this.file,
      fileName: fileName ?? this.fileName,
      fileFormat: fileFormat ?? this.fileFormat,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      apiHeaders: apiHeaders ?? this.apiHeaders,
      apiQueryParams: apiQueryParams ?? this.apiQueryParams,
      rowCount: rowCount ?? this.rowCount,
      parsedData: parsedData ?? this.parsedData,
    );
  }
}

/// Types of data sources
enum DataSourceType { file, api }