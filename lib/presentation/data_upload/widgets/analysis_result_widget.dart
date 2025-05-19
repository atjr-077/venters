// lib/presentation/data_upload/widgets/analysis_result_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/analysis_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AnalysisResultWidget extends StatefulWidget {
  final AnalysisResult analysisResult;
  final VoidCallback onBackPressed;

  const AnalysisResultWidget({
    Key? key,
    required this.analysisResult,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  _AnalysisResultWidgetState createState() => _AnalysisResultWidgetState();
}

class _AnalysisResultWidgetState extends State<AnalysisResultWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _buildTabBar(theme),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInsightsTab(theme),
              _buildVisualizationsTab(theme, isDarkMode),
              _buildSchemaTab(theme, isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.cardColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: widget.onBackPressed,
                  tooltip: 'Back to data preview',
                ),
                SizedBox(width: 8),
                Text(
                  'AI Analysis Results',
                  style: theme.textTheme.titleLarge,
                ),
                Spacer(),
                CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: AppTheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Insights'),
              Tab(text: 'Visualizations'),
              Tab(text: 'Schema'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionHeader(theme, 'Key Insights', 'insights'),
        SizedBox(height: 8),
        ...widget.analysisResult.insights.map((insight) {
          return _buildInsightCard(theme, insight);
        }).toList(),
        SizedBox(height: 24),
        _buildSectionHeader(theme, 'Key Metrics', 'analytics'),
        SizedBox(height: 8),
        _buildKeyMetricsList(theme),
      ],
    );
  }

  Widget _buildVisualizationsTab(ThemeData theme, bool isDarkMode) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionHeader(theme, 'Recommended Visualizations', 'bar_chart'),
        SizedBox(height: 8),
        ...widget.analysisResult.recommendedCharts.map((chart) {
          return _buildVisualizationCard(theme, isDarkMode, chart);
        }).toList(),
      ],
    );
  }

  Widget _buildSchemaTab(ThemeData theme, bool isDarkMode) {
    final schemaDescription = widget.analysisResult.schema?['description'] ?? 'Schema information not available';

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionHeader(theme, 'Dataset Schema', 'schema'),
        SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schema Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  schemaDescription.toString(),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.primary,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(ThemeData theme, InsightItem insight) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insight.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              insight.description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsList(ThemeData theme) {
    if (widget.analysisResult.keyMetrics.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No key metrics identified',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Focus on these metrics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...widget.analysisResult.keyMetrics.map((metric) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_up',
                      color: AppTheme.chart1,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        metric,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationCard(ThemeData theme, bool isDarkMode, String description) {
    String chartType = 'bar_chart';
    
    // Try to detect chart type from description
    if (description.toLowerCase().contains('line chart') || 
        description.toLowerCase().contains('trend')) {
      chartType = 'show_chart';
    } else if (description.toLowerCase().contains('pie chart') || 
               description.toLowerCase().contains('donut')) {
      chartType = 'pie_chart';
    } else if (description.toLowerCase().contains('scatter')) {
      chartType = 'scatter_plot';
    } else if (description.toLowerCase().contains('area')) {
      chartType = 'area_chart';
    }

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.primaryLight.withAlpha(51) : AppTheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: chartType,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Container(
                width: 80.w,
                height: 200,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.surfaceDark : AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? AppTheme.borderDark : AppTheme.border,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'image',
                        color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Visualization Preview',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Placeholder for generating this visualization
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('This would generate the $description'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: 'auto_graph',
                color: theme.colorScheme.primary,
                size: 18,
              ),
              label: Text('Generate This Visualization'),
            ),
          ],
        ),
      ),
    );
  }
}