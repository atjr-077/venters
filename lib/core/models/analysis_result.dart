// lib/core/models/analysis_result.dart

/// Represents the results of a data analysis 
class AnalysisResult {
  final String rawInsights;
  final List<InsightItem> insights;
  final List<String> recommendedCharts;
  final List<String> keyMetrics;
  final Map<String, dynamic>? schema;

  AnalysisResult({
    required this.rawInsights,
    required this.insights,
    this.recommendedCharts = const [],
    this.keyMetrics = const [],
    this.schema,
  });

  /// Factory method to parse raw insights text into structured data
  factory AnalysisResult.fromRawInsights(String rawInsights) {
    final List<InsightItem> parsedInsights = [];
    List<String> recommendedCharts = [];
    List<String> keyMetrics = [];

    // Extract insights
    final insightRegex = RegExp(r'\*\*Insight\s*\d*\s*:\s*(.+?)\*\*\s*(.+?)(?=\*\*Insight|$)',
        dotAll: true);
    final insightMatches = insightRegex.allMatches(rawInsights);

    for (final match in insightMatches) {
      if (match.groupCount >= 2) {
        final title = match.group(1)?.trim() ?? '';
        final description = match.group(2)?.trim() ?? '';
        
        parsedInsights.add(InsightItem(
          title: title,
          description: description,
        ));
      }
    }

    // Extract recommended charts
    final chartRegex = RegExp(r'\*\*Recommended Charts\*\*\s*([\s\S]*?)(?=\*\*|$)');
    final chartMatch = chartRegex.firstMatch(rawInsights);
    if (chartMatch != null && chartMatch.groupCount >= 1) {
      final chartsText = chartMatch.group(1);
      if (chartsText != null) {
        recommendedCharts = _extractListItems(chartsText);
      }
    }

    // Extract key metrics
    final metricRegex = RegExp(r'\*\*Key Metrics\*\*\s*([\s\S]*?)(?=\*\*|$)');
    final metricMatch = metricRegex.firstMatch(rawInsights);
    if (metricMatch != null && metricMatch.groupCount >= 1) {
      final metricsText = metricMatch.group(1);
      if (metricsText != null) {
        keyMetrics = _extractListItems(metricsText);
      }
    }

    return AnalysisResult(
      rawInsights: rawInsights,
      insights: parsedInsights,
      recommendedCharts: recommendedCharts,
      keyMetrics: keyMetrics,
    );
  }

  /// Helper method to extract list items from markdown-formatted text
  static List<String> _extractListItems(String text) {
    final listItems = <String>[];
    final listItemRegex = RegExp(r'[-|*|\d+\.]+\s+(.+)', multiLine: true);
    final matches = listItemRegex.allMatches(text);

    for (final match in matches) {
      if (match.groupCount >= 1) {
        final item = match.group(1)?.trim();
        if (item != null && item.isNotEmpty) {
          listItems.add(item);
        }
      }
    }

    return listItems;
  }

  /// Create a copy of this result with some fields updated
  AnalysisResult copyWith({
    String? rawInsights,
    List<InsightItem>? insights,
    List<String>? recommendedCharts,
    List<String>? keyMetrics,
    Map<String, dynamic>? schema,
  }) {
    return AnalysisResult(
      rawInsights: rawInsights ?? this.rawInsights,
      insights: insights ?? this.insights,
      recommendedCharts: recommendedCharts ?? this.recommendedCharts,
      keyMetrics: keyMetrics ?? this.keyMetrics,
      schema: schema ?? this.schema,
    );
  }
}

/// Represents a single insight extracted from the analysis
class InsightItem {
  final String title;
  final String description;
  final InsightType type;

  InsightItem({
    required this.title,
    required this.description,
    this.type = InsightType.general,
  });
}

/// Types of insights
enum InsightType { general, trend, anomaly, recommendation }