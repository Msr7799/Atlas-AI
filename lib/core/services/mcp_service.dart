import 'dart:async';

import 'dart:io';
import 'package:dio/dio.dart';


class McpService {
  static final McpService _instance = McpService._internal();
  factory McpService() => _instance;
  McpService._internal();

  late final Dio _dio;
  final Map<String, McpServer> _servers = {};
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('[MCP API] $object'),
    ));

    // Initialize default MCP servers
    _initializeDefaultServers();
    _isInitialized = true;
  }

  void _initializeDefaultServers() {
    // Memory Server
    _servers['memory'] = McpServer(
      id: 'memory',
      name: 'خادم الذاكرة',
      description: 'خادم لحفظ واسترجاع المعلومات',
      isEnabled: true,
      capabilities: ['memory_store', 'memory_retrieve', 'memory_search'],
    );

    // Sequential Thinking Server
    _servers['sequential-thinking'] = McpServer(
      id: 'sequential-thinking',
      name: 'التفكير التسلسلي',
      description: 'خادم للتفكير المتسلسل والتحليل العميق',
      isEnabled: true,
      capabilities: ['think_step_by_step', 'analyze_problem', 'generate_solution'],
    );

    // File System Server
    _servers['filesystem'] = McpServer(
      id: 'filesystem',
      name: 'نظام الملفات',
      description: 'خادم للتعامل مع الملفات والمجلدات',
      isEnabled: false,
      capabilities: ['read_file', 'write_file', 'list_directory'],
    );

    print('[MCP] Initialized ${_servers.length} MCP servers');
  }

  List<McpServer> get availableServers => _servers.values.toList();
  
  List<McpServer> get enabledServers => 
      _servers.values.where((server) => server.isEnabled).toList();

  bool isServerEnabled(String serverId) {
    return _servers[serverId]?.isEnabled ?? false;
  }

  void toggleServer(String serverId, bool enabled) {
    if (_servers.containsKey(serverId)) {
      _servers[serverId] = _servers[serverId]!.copyWith(isEnabled: enabled);
      print('[MCP] Server $serverId ${enabled ? "enabled" : "disabled"}');
    }
  }

  // MCP Tool execution methods
  Future<String> executeMemoryStore(String key, String content) async {
    if (!isServerEnabled('memory')) {
      throw McpException('Memory server is not enabled');
    }

    try {
      // Simulate memory storage
      await Future.delayed(const Duration(milliseconds: 100));
      return 'تم حفظ المعلومات في الذاكرة بنجاح: $key';
    } catch (e) {
      throw McpException('فشل في حفظ المعلومات: $e');
    }
  }

  Future<String> executeMemoryRetrieve(String key) async {
    if (!isServerEnabled('memory')) {
      throw McpException('Memory server is not enabled');
    }

    try {
      // Simulate memory retrieval
      await Future.delayed(const Duration(milliseconds: 100));
      return 'المعلومات المحفوظة: تم العثور على البيانات المطلوبة';
    } catch (e) {
      throw McpException('فشل في استرجاع المعلومات: $e');
    }
  }

  Future<List<String>> executeSequentialThinking(String problem) async {
    if (!isServerEnabled('sequential-thinking')) {
      throw McpException('Sequential thinking server is not enabled');
    }

    try {
      // Simulate step-by-step thinking
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        '🤔 الخطوة 1: فهم المشكلة',
        '📊 الخطوة 2: تحليل المعطيات',
        '💡 الخطوة 3: توليد الحلول المحتملة',
        '⚖️ الخطوة 4: تقييم الخيارات',
        '✅ الخطوة 5: اختيار الحل الأمثل',
      ];
    } catch (e) {
      throw McpException('فشل في التفكير التسلسلي: $e');
    }
  }

  Future<String> executeFileRead(String filePath) async {
    if (!isServerEnabled('filesystem')) {
      throw McpException('Filesystem server is not enabled');
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw McpException('الملف غير موجود: $filePath');
      }
      
      final content = await file.readAsString();
      return content;
    } catch (e) {
      throw McpException('فشل في قراءة الملف: $e');
    }
  }

  Future<List<String>> executeDirectoryList(String dirPath) async {
    if (!isServerEnabled('filesystem')) {
      throw McpException('Filesystem server is not enabled');
    }

    try {
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        throw McpException('المجلد غير موجود: $dirPath');
      }
      
      final entities = await directory.list().toList();
      return entities.map((entity) => entity.path).toList();
    } catch (e) {
      throw McpException('فشل في قراءة المجلد: $e');
    }
  }

  // Enhanced system prompt with MCP capabilities
  String getEnhancedSystemPrompt() {
    final enabledServersList = enabledServers;
    if (enabledServersList.isEmpty) {
      return _getBaseSystemPrompt();
    }

    final mcpCapabilities = enabledServersList
        .map((server) => '- ${server.name}: ${server.description}')
        .join('\n');

    return '''${_getBaseSystemPrompt()}

## 🔧 Available MCP Servers:
$mcpCapabilities

You can use these servers to enhance your responses:
- Use the memory server to store and retrieve important information
- Use sequential thinking for complex problems
- Use file system tools when you need to read files

Remember to format your responses clearly using Markdown and proper code formatting.''';
  }

  String _getBaseSystemPrompt() {
    return '''You are an intelligent AI assistant with expertise in various domains.

## 🌐 Language Guidelines:
- **Default to Arabic** when responding, but you can communicate in any language if the user requests it
- **Adapt naturally** to the user's language preference
- **Be multilingual and flexible** - do not restrict yourself to only Arabic
- **Format responses clearly** using Markdown for better readability

## 📋 Core Tasks:
1. **Provide helpful and accurate responses**
2. **Use proper Markdown formatting** - organize your answers beautifully
3. **Format code properly** - use appropriate syntax highlighting

## 💻 Code Formatting:
When writing code, use proper formatting:

```javascript
// JavaScript example
console.log("Hello World!");
```

```python
# Python example
print("Hello World!")
```

```bash
# Bash/Shell example
echo "Hello World!"
```

```powershell
# PowerShell example
Write-Output "Hello World!"
```

```json
{
  "message": "Hello World!"
}
```

```sql
-- SQL example
SELECT 'Hello World!' AS greeting;
```

## 🎯 Response Style:
- **Be clear and helpful**
- **Use appropriate emojis** 😊
- **Organize information in lists and points**
- **Provide practical examples when needed**
- **Explain complex concepts simply**

## 🔍 When handling queries:
1. **Understand the question thoroughly**
2. **Provide comprehensive and detailed answers**
3. **Give practical examples**
4. **Suggest actionable steps when appropriate**

Remember: Your goal is to provide the best possible assistance while adapting to the user's communication style and language preference!''';
  }

  void dispose() {
    _dio.close();
  }
}

class McpServer {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final List<String> capabilities;

  McpServer({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.capabilities,
  });

  McpServer copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
    List<String>? capabilities,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isEnabled': isEnabled,
      'capabilities': capabilities,
    };
  }

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isEnabled: json['isEnabled'] as bool,
      capabilities: List<String>.from(json['capabilities'] as List),
    );
  }
}

class McpException implements Exception {
  final String message;
  McpException(this.message);

  @override
  String toString() => 'McpException: $message';
}
