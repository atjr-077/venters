// lib/presentation/data_upload/widgets/api_connection_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ApiConnectionWidget extends StatelessWidget {
  final TextEditingController apiEndpointController;
  final GlobalKey<FormState> formKey;
  final bool isTestingConnection;
  final bool isConnectionSuccessful;
  final VoidCallback onTestConnection;
  final VoidCallback onFetchData;

  const ApiConnectionWidget({
    Key? key,
    required this.apiEndpointController,
    required this.formKey,
    required this.isTestingConnection,
    required this.isConnectionSuccessful,
    required this.onTestConnection,
    required this.onFetchData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90.w,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? AppTheme.borderDark : AppTheme.border,
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'api',
                        color: AppTheme.primary,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Connect to API',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: apiEndpointController,
                        decoration: InputDecoration(
                          labelText: 'API Endpoint URL',
                          hintText: 'https://api.example.com/data',
                          prefixIcon: Icon(Icons.link),
                          suffixIcon: isConnectionSuccessful 
                            ? Icon(Icons.check_circle, color: AppTheme.success)
                            : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an API endpoint';
                          }
                          if (!value.startsWith('http://') && !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isTestingConnection ? null : onTestConnection,
                              icon: isTestingConnection 
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : CustomIconWidget(
                                    iconName: 'cable',
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                  ),
                              label: Text('Test Connection'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isTestingConnection || !isConnectionSuccessful ? null : onFetchData,
                              icon: CustomIconWidget(
                                iconName: 'download',
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                              label: Text('Fetch Data'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Connect to your data source API',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Paste your API endpoint URL, test the connection, and fetch data for AI-powered analysis.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              _buildTipsSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(ThemeData theme) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.info.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'tips_and_updates',
                color: AppTheme.info,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'API Tips',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildTipItem(theme, 'The API should return JSON data'),
          _buildTipItem(theme, 'Supports both array and object responses'),
          _buildTipItem(theme, 'URL must include http:// or https://'),
          _buildTipItem(theme, 'Test connection before fetching data'),
        ],
      ),
    );
  }

  Widget _buildTipItem(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}