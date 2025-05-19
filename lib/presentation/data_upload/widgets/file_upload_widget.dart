// lib/presentation/data_upload/widgets/file_upload_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FileUploadWidget extends StatelessWidget {
  final VoidCallback onUploadPressed;

  const FileUploadWidget({
    Key? key,
    required this.onUploadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.surfaceDark : AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppTheme.borderDark : AppTheme.border,
                  width: 2,
                  style: BorderStyle.dashed,
                ),
              ),
              child: InkWell(
                onTap: onUploadPressed,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'upload_file',
                      color: AppTheme.primary,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Upload Data File',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Supported formats: CSV, JSON, XLSX',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onUploadPressed,
                      icon: CustomIconWidget(
                        iconName: 'file_upload',
                        color: theme.colorScheme.onPrimary,
                        size: 18,
                      ),
                      label: Text('Select File'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Upload a data file for AI-powered analysis',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Our AI will automatically detect the file type, parse the data, and provide insightful visualizations and trends.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            _buildFeatureList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(ThemeData theme) {
    final features = [
      {'icon': 'auto_awesome', 'text': 'Automatic file format detection'},
      {'icon': 'insights', 'text': 'AI-powered data analysis'},
      {'icon': 'data_exploration', 'text': 'Visual insights and recommendations'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: feature['icon']!,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                feature['text']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}