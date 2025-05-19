// lib/presentation/data_upload/widgets/data_preview_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/data_source.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class DataPreviewWidget extends StatelessWidget {
  final DataSource dataSource;
  final VoidCallback onAnalyzePressed;
  final bool isAnalyzing;

  const DataPreviewWidget({
    Key? key,
    required this.dataSource,
    required this.onAnalyzePressed,
    this.isAnalyzing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataSourceInfo(context, theme),
          SizedBox(height: 16),
          _buildDataPreviewHeader(theme),
          SizedBox(height: 8),
          _buildDataTable(context, theme, isDarkMode),
          SizedBox(height: 24),
          _buildAnalyzeButton(theme),
        ],
      ),
    );
  }

  Widget _buildDataSourceInfo(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: dataSource.type == DataSourceType.file ? 'description' : 'api',
                  color: AppTheme.primary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dataSource.type == DataSourceType.file
                        ? dataSource.fileName ?? 'File'
                        : 'API Data',
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildInfoRow(
              theme,
              'Source Type:',
              dataSource.type == DataSourceType.file ? 'File Upload' : 'API Connection',
              'dataset',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              theme,
              'Format:',
              dataSource.type == DataSourceType.file
                  ? (dataSource.fileFormat?.toUpperCase() ?? 'Unknown')
                  : 'JSON (API)',
              'data_object',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              theme,
              'Records:',
              '${dataSource.rowCount ?? 'Unknown'} records',
              'view_list',
            ),
            if (dataSource.type == DataSourceType.api) ...[  
              SizedBox(height: 8),
              _buildInfoRow(
                theme,
                'Endpoint:',
                dataSource.apiEndpoint ?? 'Unknown',
                'link',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.primary.withAlpha(179),
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDataPreviewHeader(ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'preview',
          color: theme.colorScheme.secondary,
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          'Data Preview',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        Spacer(),
        Text(
          'Showing first 5 rows',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, ThemeData theme, bool isDarkMode) {
    try {
      final data = dataSource.parsedData;
      if (data == null || data['rows'] == null || data['headers'] == null) {
        return _buildErrorMessage(theme, 'No data available for preview');
      }

      final rows = data['rows'] as List;
      final headers = data['headers'] as List;

      // Limit to 5 rows for preview
      final previewRows = rows.take(5).toList();
      
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? AppTheme.borderDark : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            headingRowColor: MaterialStateProperty.all(
              isDarkMode ? AppTheme.surfaceDark : AppTheme.background,
            ),
            columns: headers.map<DataColumn>((header) {
              return DataColumn(
                label: Expanded(
                  child: Text(
                    header.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            rows: previewRows.map<DataRow>((row) {
              return DataRow(
                cells: headers.map<DataCell>((header) {
                  final value = row[header] ?? '';
                  return DataCell(
                    Text(
                      value.toString(),
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      return _buildErrorMessage(theme, 'Error displaying data preview: $e');
    }
  }

  Widget _buildErrorMessage(ThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.error,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(ThemeData theme) {
    return Center(
      child: SizedBox(
        width: 80.w,
        child: ElevatedButton.icon(
          onPressed: isAnalyzing ? null : onAnalyzePressed,
          icon: isAnalyzing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                  ),
                )
              : CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
          label: Text(isAnalyzing ? 'Analyzing Data...' : 'Analyze with AI'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}