import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/curl_parser.dart';
import 'package:http/http.dart' as http;

/// Manager for custom API model configurations
class CustomModelsManager {
  static const String _storageKey = 'custom_models';
  static CustomModelsManager? _instance;
  
  CustomModelsManager._();
  
  static CustomModelsManager get instance {
    _instance ??= CustomModelsManager._();
    return _instance!;
  }
  
  List<CustomApiConfig> _customModels = [];
  
  /// Get all custom models
  List<CustomApiConfig> get customModels => List.unmodifiable(_customModels);
  
  /// Initialize and load saved models
  Future<void> initialize() async {
    await _loadModels();
  }
  
  /// Add a new custom model with name, description and curl command
  Future<bool> addModelFromCurl(String name, String description, String curlCommand) async {
    try {
      final config = CurlParser.parseCurlCommand(curlCommand);
      if (config == null) {
        return false;
      }
      
      // Create new config with custom name and description
      final updatedConfig = CustomApiConfig(
        name: name,
        url: config.url,
        method: config.method,
        headers: config.headers,
        bodyTemplate: config.bodyTemplate,
        description: description,
      );
      
      // Check if model with same name already exists
      final existingIndex = _customModels.indexWhere((m) => m.name == name);
      if (existingIndex >= 0) {
        // Update existing model
        _customModels[existingIndex] = updatedConfig;
      } else {
        // Add new model
        _customModels.add(updatedConfig);
      }
      
      await _saveModels();
      return true;
    } catch (e) {
      print('Error adding custom model: $e');
      return false;
    }
  }
  
  /// Add a custom model configuration directly
  Future<bool> addModel(CustomApiConfig config) async {
    try {
      // Check if model with same name already exists
      final existingIndex = _customModels.indexWhere((m) => m.name == config.name);
      if (existingIndex >= 0) {
        _customModels[existingIndex] = config;
      } else {
        _customModels.add(config);
      }
      
      await _saveModels();
      return true;
    } catch (e) {
      print('Error adding custom model: $e');
      return false;
    }
  }
  
  /// Remove a custom model
  Future<bool> removeModel(String modelName) async {
    try {
      _customModels.removeWhere((m) => m.name == modelName);
      await _saveModels();
      return true;
    } catch (e) {
      print('Error removing custom model: $e');
      return false;
    }
  }
  
  /// Get a specific custom model by name
  CustomApiConfig? getModel(String modelName) {
    try {
      return _customModels.firstWhere((m) => m.name == modelName);
    } catch (e) {
      return null;
    }
  }
  
  /// Test a custom model configuration
  Future<bool> testModel(CustomApiConfig config, {String testMessage = "Hello"}) async {
    try {
      final response = await makeApiCall(config, testMessage);
      return response != null;
    } catch (e) {
      print('Error testing model ${config.name}: $e');
      return false;
    }
  }
  
  /// Make an API call using a custom model configuration - المرن والقابل للتطوير
  Future<String?> makeApiCall(
    CustomApiConfig config, 
    String message, {
    List<Map<String, String>>? conversationHistory,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    try {
      final body = config.createRequestBody(
        message,
        conversationHistory: conversationHistory,
        temperature: temperature,
        maxTokens: maxTokens,
        systemPrompt: systemPrompt,
        attachedFiles: attachedFiles,
      );
      
      final response = await http.Request(config.method, Uri.parse(config.url))
        ..headers.addAll(config.headers)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
      
      final streamedResponse = await response.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      
      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        // Parse response and extract the actual message
        return _extractResponseMessage(responseBody, config);
      } else {
        print('API call failed: ${streamedResponse.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Error making API call to ${config.name}: $e');
      return null;
    }
  }
  
  /// Extract the response message from API response
  String _extractResponseMessage(String responseBody, CustomApiConfig config) {
    try {
      final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      
      // Common response patterns for different APIs
      final possibleKeys = [
        'choices.0.message.content',  // OpenAI format
        'candidates.0.content.parts.0.text',  // Google Gemini format
        'content.0.text',  // Anthropic Claude format
        'response',  // Generic response
        'message',   // Generic message
        'text',      // Generic text
        'output',    // Generic output
        'result',    // Generic result
      ];
      
      for (final keyPath in possibleKeys) {
        final value = _getNestedValue(jsonResponse, keyPath.split('.'));
        if (value != null && value is String && value.isNotEmpty) {
          return value;
        }
      }
      
      // If no standard format found, return the whole response as formatted JSON
      return const JsonEncoder.withIndent('  ').convert(jsonResponse);
    } catch (e) {
      // If JSON parsing fails, return the raw response
      return responseBody;
    }
  }
  
  /// Get nested value from JSON using dot notation
  dynamic _getNestedValue(Map<String, dynamic> json, List<String> keys) {
    dynamic current = json;
    
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else if (current is List && int.tryParse(key) != null) {
        final index = int.parse(key);
        if (index >= 0 && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    
    return current;
  }
  
  /// Load models from storage
  Future<void> _loadModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsJson = prefs.getString(_storageKey);
      
      if (modelsJson != null) {
        final List<dynamic> modelsList = jsonDecode(modelsJson);
        _customModels = modelsList
            .map((json) => CustomApiConfig.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading custom models: $e');
      _customModels = [];
    }
  }
  
  /// Save models to storage
  Future<void> _saveModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsJson = jsonEncode(_customModels.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, modelsJson);
    } catch (e) {
      print('Error saving custom models: $e');
    }
  }
  
  /// Clear all custom models
  Future<void> clearAllModels() async {
    try {
      _customModels.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing custom models: $e');
    }
  }
  
  /// Export models as JSON
  String exportModels() {
    return const JsonEncoder.withIndent('  ').convert(
      _customModels.map((m) => m.toJson()).toList()
    );
  }
  
  /// Import models from JSON
  Future<bool> importModels(String jsonString) async {
    try {
      final List<dynamic> modelsList = jsonDecode(jsonString);
      final importedModels = modelsList
          .map((json) => CustomApiConfig.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _customModels.addAll(importedModels);
      await _saveModels();
      return true;
    } catch (e) {
      print('Error importing custom models: $e');
      return false;
    }
  }
}
