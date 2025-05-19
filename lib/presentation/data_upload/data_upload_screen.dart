import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/models/analysis_result.dart';
import '../../core/models/data_source.dart';
import '../../core/services/api_service.dart';
import '../../core/services/data_parser_service.dart';
import '../../core/services/gemini_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/analysis_result_widget.dart';
import './widgets/api_connection_widget.dart';
import './widgets/data_preview_widget.dart';
import './widgets/file_upload_widget.dart';
import 'widgets/analysis_result_widget.dart';
import 'widgets/api_connection_widget.dart';
import 'widgets/data_preview_widget.dart';
import 'widgets/file_upload_widget.dart';

// lib/presentation/data_upload/data_upload_screen.dart




















class DataUploadScreen extends StatefulWidget {
  const DataUploadScreen({Key? key}) : super(key: key);

  @override
  _DataUploadScreenState createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> with SingleTickerProviderStateMixin {
  final DataParserService _parserService = DataParserService();
  final ApiService _apiService = ApiService();
  final GeminiService _geminiService = GeminiService();
  
  late TabController _tabController;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Data source and analysis
  DataSource? _dataSource;
  AnalysisResult? _analysisResult;
  bool _isAnalyzing = false;
  bool _showDataPreview = false;
  
  // API endpoint fields
  final TextEditingController _apiEndpointController = TextEditingController();
  final GlobalKey<FormState> _apiFormKey = GlobalKey<FormState>();
  bool _isTestingConnection = false;
  bool _isConnectionSuccessful = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    // Reset data when switching tabs
    if (_tabController.indexIsChanging) {
      setState(() {
        _dataSource = null;
        _analysisResult = null;
        _showDataPreview = false;
        _errorMessage = '';
        _isConnectionSuccessful = false;
      });
    }
  }

  Future<void> _pickAndParseFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final parsedData = await _parserService.parseFile(file);
        
        setState(() {
          _dataSource = DataSource.fromFile(
            file,
            parsedData: parsedData,
            rowCount: parsedData['rowCount'],
          );
          _showDataPreview = true;
          _isLoading = false;
        });
      } else {
        // User canceled the picker
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error parsing file: ${e.toString()}';
      });
    }
  }

  Future<void> _testApiConnection() async {
    if (!_apiFormKey.currentState!.validate()) {
      return;
    }

    final endpoint = _apiEndpointController.text.trim();
    
    setState(() {
      _isTestingConnection = true;
      _errorMessage = '';
    });

    try {
      final isConnected = await _apiService.testConnection(endpoint);
      
      setState(() {
        _isTestingConnection = false;
        _isConnectionSuccessful = isConnected;
        if (!isConnected) {
          _errorMessage = 'Failed to connect to the API endpoint';
        }
      });
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _isConnectionSuccessful = false;
        _errorMessage = 'Error connecting to API: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchApiData() async {
    if (!_apiFormKey.currentState!.validate() || !_isConnectionSuccessful) {
      setState(() {
        _errorMessage = !_isConnectionSuccessful 
          ? 'Please test the connection first' 
          : 'Please provide a valid API endpoint';
      });
      return;
    }

    final endpoint = _apiEndpointController.text.trim();
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final responseData = await _apiService.fetchData(endpoint);
      final parsedData = _parserService.parseApiResponse(responseData);
      
      setState(() {
        _dataSource = DataSource.fromApi(
          endpoint,
          parsedData: parsedData,
          rowCount: parsedData['rowCount'],
        );
        _showDataPreview = true;
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'API Error: ${e.response?.statusCode ?? 'Unknown'} - ${e.message}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching data: ${e.toString()}';
      });
    }
  }

  Future<void> _analyzeData() async {
    if (_dataSource == null || _dataSource!.parsedData == null) {
      setState(() {
        _errorMessage = 'No data available for analysis';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      // First, detect the schema
      final schemaResponse = await _geminiService.detectSchema(
        data: _dataSource!.parsedData.toString(),
      );
      
      // Then analyze the data
      final analysisPrompt = """Analyze this ${_dataSource!.type == DataSourceType.file ? _dataSource!.fileFormat : 'API'} data and provide business insights. 
      Focus on patterns, trends, and actionable recommendations.
      ${_dataSource!.rowCount != null ? 'The dataset contains ${_dataSource!.rowCount} records.' : ''}
      """;
      
      final analysisResponse = await _geminiService.analyzeData(
        prompt: analysisPrompt,
        data: _dataSource!.parsedData.toString(),
      );
      
      // Create the analysis result
      final analysisResult = AnalysisResult.fromRawInsights(analysisResponse.text);
      
      // Ask for visualization recommendations
      final visualizationResponse = await _geminiService.suggestVisualizations(
        data: _dataSource!.parsedData.toString(),
        schema: {'schema': schemaResponse.text},
      );
      
      setState(() {
        _analysisResult = analysisResult.copyWith(
          schema: {'description': schemaResponse.text},
          recommendedCharts: AnalysisResult._extractListItems(visualizationResponse.text),
        );
        _isAnalyzing = false;
        _showDataPreview = false; // Hide preview, show results
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error analyzing data: ${e.toString()}';
      });
    }
  }

  void _backToDataPreview() {
    setState(() {
      _analysisResult = null;
      _showDataPreview = true;
    });
  }

  void _resetUpload() {
    setState(() {
      _dataSource = null;
      _analysisResult = null;
      _showDataPreview = false;
      _errorMessage = '';
      _isConnectionSuccessful = false;
      _apiEndpointController.clear();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiEndpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Upload & Analysis'),
        bottom: _dataSource == null ? TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'File Upload'),
            Tab(text: 'API Connection'),
          ],
        ) : null,
        actions: [
          if (_dataSource != null)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _resetUpload,
              tooltip: 'Reset Upload',
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(theme, isDarkMode),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDarkMode) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }
    
    if (_errorMessage.isNotEmpty) {
      return _buildErrorState(theme);
    }
    
    if (_analysisResult != null) {
      return AnalysisResultWidget(
        analysisResult: _analysisResult!,
        onBackPressed: _backToDataPreview,
      );
    }
    
    if (_showDataPreview && _dataSource != null) {
      return DataPreviewWidget(
        dataSource: _dataSource!,
        onAnalyzePressed: _analyzeData,
        isAnalyzing: _isAnalyzing,
      );
    }
    
    return TabBarView(
      controller: _tabController,
      children: [
        // File Upload Tab
        FileUploadWidget(onUploadPressed: _pickAndParseFile),
        
        // API Connection Tab
        ApiConnectionWidget(
          apiEndpointController: _apiEndpointController,
          formKey: _apiFormKey,
          isTestingConnection: _isTestingConnection,
          isConnectionSuccessful: _isConnectionSuccessful,
          onTestConnection: _testApiConnection,
          onFetchData: _fetchApiData,
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            _tabController.index == 0 
              ? 'Processing file...'
              : 'Fetching data from API...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.error,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Error Occurred',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetUpload,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}