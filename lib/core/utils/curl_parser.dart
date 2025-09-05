import 'dart:convert';

/// Utility class to parse curl commands and extract API configuration
class CurlParser {
  /// Parses a curl command and extracts the API configuration
  static CustomApiConfig? parseCurlCommand(String curlCommand) {
    try {
      // Clean the curl command
      String cleanedCurl = curlCommand.trim();
      
      // Remove 'curl' from the beginning if present
      if (cleanedCurl.startsWith('curl ')) {
        cleanedCurl = cleanedCurl.substring(5);
      }
      
      // Extract URL
      String? url = _extractUrl(cleanedCurl);
      if (url == null) return null;
      
      // Extract headers
      Map<String, String> headers = _extractHeaders(cleanedCurl);
      
      // Extract HTTP method
      String method = _extractMethod(cleanedCurl);
      
      // Extract request body
      Map<String, dynamic>? body = _extractBody(cleanedCurl);
      
      // Extract model name from URL or body
      String modelName = _extractModelName(url, body);
      
      return CustomApiConfig(
        name: modelName,
        url: url,
        method: method,
        headers: headers,
        bodyTemplate: body,
        description: 'Custom API model imported from cURL',
      );
    } catch (e) {
      print('Error parsing curl command: $e');
      return null;
    }
  }
  
  /// Extracts URL from curl command
  static String? _extractUrl(String curlCommand) {
    // Remove curl from beginning and clean
    String cleanCommand = curlCommand.replaceFirst(RegExp(r'^curl\s+'), '');
    
    // Pattern for URL - handles quoted, single-quoted, and unquoted URLs
    final urlPatterns = [
      RegExp(r'"(https?://[^"]+)"'),           // Double quoted URL
      RegExp(r"'(https?://[^']+)'"),          // Single quoted URL
      RegExp(r'(https?://[^\s]+)'),           // Unquoted URL
      RegExp(r'"([^"]+)"'),                   // Any quoted string starting with http
      RegExp(r"'([^']+)'"),                   // Any single quoted string starting with http
    ];
    
    for (final pattern in urlPatterns) {
      final match = pattern.firstMatch(cleanCommand);
      if (match != null) {
        String url = match.group(1) ?? '';
        if (url.startsWith('http')) {
          // Clean up any trailing flags that might be included
          url = url.split(' ').first;
          return url;
        }
      }
    }
    
    // Fallback: look for any http URL in the command
    const fallbackRegex = r'(https?://[^\s"]+)';
    final fallbackPattern = RegExp(fallbackRegex);
    final fallbackMatch = fallbackPattern.firstMatch(cleanCommand);
    if (fallbackMatch != null) {
      return fallbackMatch.group(1);
    }
    
    return null;
  }
  
  /// Extracts headers from curl command
  static Map<String, String> _extractHeaders(String curlCommand) {
    Map<String, String> headers = {};
    
    // Pattern for -H or --header with better escaping
    final headerPatterns = [
      RegExp(r'-H\s+"([^"]+)"'),           // -H "header"
      RegExp(r"-H\s+'([^']+)'"),           // -H 'header' 
      RegExp(r'--header\s+"([^"]+)"'),     // --header "header"
      RegExp(r"--header\s+'([^']+)'"),     // --header 'header'
    ];
    
    for (final pattern in headerPatterns) {
      final matches = pattern.allMatches(curlCommand);
      for (final match in matches) {
        String headerStr = match.group(1) ?? '';
        final colonIndex = headerStr.indexOf(':');
        if (colonIndex > 0) {
          String key = headerStr.substring(0, colonIndex).trim();
          String value = headerStr.substring(colonIndex + 1).trim();
          headers[key] = value;
        }
      }
    }
    
    return headers;
  }
  
  /// Extracts HTTP method from curl command
  static String _extractMethod(String curlCommand) {
    final methodPattern = RegExp(r'-X\s+(\w+)|--request\s+(\w+)');
    final match = methodPattern.firstMatch(curlCommand);
    if (match != null) {
      return match.group(1)?.toUpperCase() ?? match.group(2)?.toUpperCase() ?? 'POST';
    }
    
    // Default to POST if data is present, GET otherwise
    if (curlCommand.contains('-d ') || curlCommand.contains('--data')) {
      return 'POST';
    }
    return 'GET';
  }
  
  /// Extracts request body from curl command
  static Map<String, dynamic>? _extractBody(String curlCommand) {
    // Patterns for -d or --data with different quote styles
    final dataPatterns = [
      RegExp(r"-d\s+'([^']+)'"),           // -d 'data'
      RegExp(r'-d\s+"([^"]+)"'),           // -d "data"
      RegExp(r"--data\s+'([^']+)'"),       // --data 'data'
      RegExp(r'--data\s+"([^"]+)"'),       // --data "data"
      RegExp(r'-d\s+([^\s]+)'),            // -d data (unquoted)
      RegExp(r'--data\s+([^\s]+)'),        // --data data (unquoted)
    ];
    
    for (final pattern in dataPatterns) {
      final match = pattern.firstMatch(curlCommand);
      if (match != null) {
        String dataStr = match.group(1) ?? '';
        if (dataStr.isNotEmpty) {
          try {
            return jsonDecode(dataStr) as Map<String, dynamic>;
          } catch (e) {
            // If not JSON, return as form data
            return {'data': dataStr};
          }
        }
      }
    }
    return null;
  }
  
  /// Extracts model name from URL or request body
  static String _extractModelName(String url, Map<String, dynamic>? body) {
    // Try to extract from body first
    if (body != null) {
      if (body.containsKey('model')) {
        return body['model'].toString();
      }
    }
    
    // Extract from URL path
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final pathSegments = uri.pathSegments;
      for (int i = 0; i < pathSegments.length; i++) {
        final segment = pathSegments[i];
        if (segment.contains('model') && i + 1 < pathSegments.length) {
          return pathSegments[i + 1];
        }
        if (segment.startsWith('gpt') || segment.startsWith('llama') || 
            segment.startsWith('gemini') || segment.startsWith('claude')) {
          return segment;
        }
      }
      
      // Fallback: use last path segment
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        if (lastSegment.isNotEmpty && lastSegment != 'generateContent' && lastSegment != 'chat') {
          return lastSegment;
        }
      }
    }
    
    // Final fallback
    return 'Custom Model ${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Configuration class for custom API models
class CustomApiConfig {
  final String name;
  final String url;
  final String method;
  final Map<String, String> headers;
  final Map<String, dynamic>? bodyTemplate;
  final String description;
  final DateTime createdAt;
  
  CustomApiConfig({
    required this.name,
    required this.url,
    required this.method,
    required this.headers,
    this.bodyTemplate,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'method': method,
      'headers': headers,
      'bodyTemplate': bodyTemplate,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Creates from JSON
  factory CustomApiConfig.fromJson(Map<String, dynamic> json) {
    return CustomApiConfig(
      name: json['name'] as String,
      url: json['url'] as String,
      method: json['method'] as String,
      headers: Map<String, String>.from(json['headers'] as Map),
      bodyTemplate: json['bodyTemplate'] as Map<String, dynamic>?,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  /// Creates a request body by replacing placeholders - مرن وقابل للتطوير
  Map<String, dynamic> createRequestBody(
    String userMessage, {
    List<Map<String, String>>? conversationHistory,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) {
    if (bodyTemplate == null) {
      // إنشاء body افتراضي إذا لم يكن موجود في template
      return {
        'messages': _buildMessages(userMessage, conversationHistory, systemPrompt),
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };
    }
    
    final body = Map<String, dynamic>.from(bodyTemplate!);
    
    // Replace message placeholders with advanced logic
    _replaceInMap(body, userMessage, conversationHistory, temperature, maxTokens, systemPrompt, attachedFiles);
    
    return body;
  }

  /// بناء قائمة الرسائل لأي نموذج مخصص
  List<Map<String, String>> _buildMessages(
    String userMessage,
    List<Map<String, String>>? conversationHistory,
    String? systemPrompt,
  ) {
    final messages = <Map<String, String>>[];
    
    // إضافة system prompt إن وجد
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    
    // إضافة المحفوظات إن وجدت
    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }
    
    // إضافة الرسالة الحالية
    messages.add({'role': 'user', 'content': userMessage});
    
    return messages;
  }
  
  void _replaceInMap(
    dynamic obj,
    String message,
    List<Map<String, String>>? conversationHistory,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  ) {
    if (obj is Map) {
      obj.forEach((key, value) {
        if (value is String) {
          // استبدال placeholders في النصوص
          obj[key] = _replacePlaceholders(value, message, conversationHistory, temperature, maxTokens, systemPrompt, attachedFiles);
        } else if (value is Map || value is List) {
          _replaceInMap(value, message, conversationHistory, temperature, maxTokens, systemPrompt, attachedFiles);
        }
      });
      
      // معالجة خاصة لقائمة الرسائل
      if (obj.containsKey('messages') && conversationHistory != null) {
        obj['messages'] = _buildMessages(message, conversationHistory, systemPrompt);
      }
      
      // إضافة المعاملات إذا لم تكن موجودة
      if (temperature != null && !obj.containsKey('temperature')) {
        obj['temperature'] = temperature;
      }
      if (maxTokens != null && !obj.containsKey('max_tokens') && !obj.containsKey('maxTokens')) {
        obj['max_tokens'] = maxTokens;
      }
    } else if (obj is List) {
      for (int i = 0; i < obj.length; i++) {
        if (obj[i] is String) {
          obj[i] = _replacePlaceholders(obj[i], message, conversationHistory, temperature, maxTokens, systemPrompt, attachedFiles);
        } else if (obj[i] is Map || obj[i] is List) {
          _replaceInMap(obj[i], message, conversationHistory, temperature, maxTokens, systemPrompt, attachedFiles);
        }
      }
    }
  }
  
  String _replacePlaceholders(
    String text,
    String message,
    List<Map<String, String>>? conversationHistory,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  ) {
    String result = text;
    
    // Replace message placeholders
    result = result.replaceAll('{message}', message);
    result = result.replaceAll('{user_message}', message);
    result = result.replaceAll('{prompt}', message);
    result = result.replaceAll('{input}', message);
    result = result.replaceAll('{text}', message);
    
    // Replace system prompt if available
    if (systemPrompt != null) {
      result = result.replaceAll('{system_prompt}', systemPrompt);
      result = result.replaceAll('{system}', systemPrompt);
    }
    
    // Replace temperature and max tokens
    if (temperature != null) {
      result = result.replaceAll('{temperature}', temperature.toString());
    }
    if (maxTokens != null) {
      result = result.replaceAll('{max_tokens}', maxTokens.toString());
      result = result.replaceAll('{maxTokens}', maxTokens.toString());
    }
    
    // Handle image attachments for vision models
    if (attachedFiles != null && attachedFiles.isNotEmpty) {
      // For now, just use the first attached file
      result = result.replaceAll('{image}', attachedFiles.first);
      result = result.replaceAll('{image_path}', attachedFiles.first);
    }
    
    return result;
  }
  
  @override
  String toString() {
    return 'CustomApiConfig(name: $name, url: $url, method: $method)';
  }
}
