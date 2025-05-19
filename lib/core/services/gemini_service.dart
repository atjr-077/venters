// lib/core/services/gemini_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service class for interacting with the Gemini API
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  late final String _apiKey;
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in .env file.');
    }

    _apiKey = apiKey;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        queryParameters: {
          'key': _apiKey,
        },
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => debugPrint(object.toString()),
    ));
  }

  Dio get dio => _dio;

  /// Analyzes data and generates insights
  Future<GeminiResponse> analyzeData({
    required String prompt,
    required dynamic data,
    String model = 'gemini-2.0-flash-001',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async {
    try {
      final formattedPrompt = """Analyze this data and provide business insights:
$prompt

Data:
$data

Provide insights about trends, anomalies, and actionable recommendations in a structured format.
""";

      final response = await _dio.post(
        '/models/$model:generateContent',
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': formattedPrompt}],
            }
          ],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
      );

      if (response.statusCode == 200) {
        final text = response.data['candidates'][0]['content']['parts'][0]['text'];
        return GeminiResponse(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to generate insights',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message ?? 'Unknown error',
      );
    }
  }

  /// Detects the schema from provided data
  Future<GeminiResponse> detectSchema({
    required dynamic data,
    String model = 'gemini-2.0-flash-001',
    int maxTokens = 1024,
  }) async {
    try {
      final formattedPrompt = """Detect and describe the schema of this data:

$data

Provide a structured description including: data types, field names, and general structure.
""";

      final response = await _dio.post(
        '/models/$model:generateContent',
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': formattedPrompt}],
            }
          ],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': 0.2,
          },
        },
      );

      if (response.statusCode == 200) {
        final text = response.data['candidates'][0]['content']['parts'][0]['text'];
        return GeminiResponse(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to detect schema',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message ?? 'Unknown error',
      );
    }
  }

  /// Suggests visualizations based on the data
  Future<GeminiResponse> suggestVisualizations({
    required dynamic data,
    required Map<String, dynamic> schema,
    String model = 'gemini-2.0-flash-001',
    int maxTokens = 1024,
  }) async {
    try {
      final formattedPrompt = """Suggest appropriate data visualizations for this dataset:

Data:
$data

Schema:
$schema

Recommend the best chart types, explain why they fit the data, and suggest key metrics to highlight.
""";

      final response = await _dio.post(
        '/models/$model:generateContent',
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': formattedPrompt}],
            }
          ],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': 0.7,
          },
        },
      );

      if (response.statusCode == 200) {
        final text = response.data['candidates'][0]['content']['parts'][0]['text'];
        return GeminiResponse(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to suggest visualizations',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ?? e.message ?? 'Unknown error',
      );
    }
  }
}

class GeminiResponse {
  final String text;

  GeminiResponse({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}