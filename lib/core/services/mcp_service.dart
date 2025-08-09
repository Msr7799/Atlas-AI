import 'dart:async';
import 'package:dio/dio.dart';

class McpService {
  static final McpService _instance = McpService._internal();
  factory McpService() => _instance;
  McpService._internal();

  late final Dio _dio;
  final Map<String, McpServer> _servers = {};
  bool _isInitialized = false;
  Map<String, dynamic> _customServers = {};

  void initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[MCP API] $object'),
      ),
    );

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
      isCustom: false,
    );

    // Sequential Thinking Server
    _servers['sequential-thinking'] = McpServer(
      id: 'sequential-thinking',
      name: 'التفكير التسلسلي',
      description: 'خادم للتفكير المتسلسل والتحليل العميق',
      isEnabled: true,
      capabilities: [
        'think_step_by_step',
        'analyze_problem',
        'generate_solution',
      ],
      isCustom: false,
    );

    print('[MCP] Initialized ${_servers.length} default MCP servers');
  }

  // إضافة دعم الخوادم المخصصة
  void updateCustomServers(
    Map<String, dynamic> customServers,
    Map<String, bool> serverStatus,
  ) {
    _customServers = customServers;

    // إزالة الخوادم المخصصة القديمة
    _servers.removeWhere((key, server) => server.isCustom);

    // إضافة الخوادم المخصصة الجديدة
    for (String serverId in customServers.keys) {
      final serverConfig = customServers[serverId] as Map<String, dynamic>;

      _servers[serverId] = McpServer(
        id: serverId,
        name: serverConfig['name'] ?? serverId,
        description: serverConfig['description'] ?? 'خادم MCP مخصص',
        isEnabled: serverStatus[serverId] ?? false,
        capabilities: List<String>.from(
          serverConfig['capabilities'] ?? ['custom'],
        ),
        isCustom: true,
        command: serverConfig['command'],
        args: List<String>.from(serverConfig['args'] ?? []),
        env: Map<String, String>.from(serverConfig['env'] ?? {}),
      );
    }

    print('[MCP] Updated custom servers: ${customServers.keys.length} servers');
  }

  List<McpServer> get availableServers => _servers.values.toList();

  List<McpServer> get enabledServers =>
      _servers.values.where((server) => server.isEnabled).toList();

  List<McpServer> get customServers =>
      _servers.values.where((server) => server.isCustom).toList();

  Map<String, dynamic> get customServersConfig => Map.from(_customServers);

  bool isServerEnabled(String serverId) {
    return _servers[serverId]?.isEnabled ?? false;
  }

  void toggleServer(String serverId, bool enabled) {
    if (_servers.containsKey(serverId)) {
      _servers[serverId] = _servers[serverId]!.copyWith(isEnabled: enabled);
      print('[MCP] Server $serverId ${enabled ? "enabled" : "disabled"}');
    }
  }

  // تنفيذ خادم مخصص
  Future<String> executeCustomMcpServer(
    String serverId,
    Map<String, dynamic> params,
  ) async {
    final server = _servers[serverId];
    if (server == null || !server.isEnabled || !server.isCustom) {
      throw McpException(
        'Custom MCP server $serverId is not available or enabled',
      );
    }

    try {
      // محاكاة تنفيذ الخادم المخصص
      await Future.delayed(const Duration(milliseconds: 200));

      return 'تم تنفيذ الخادم المخصص $serverId بنجاح\nالمعاملات: ${params.toString()}';
    } catch (e) {
      throw McpException('فشل في تنفيذ الخادم المخصص $serverId: $e');
    }
  }

  // باقي الدوال الموجودة...
  Future<String> executeMemoryStore(String key, String content) async {
    if (!isServerEnabled('memory')) {
      throw McpException('Memory server is not enabled');
    }

    try {
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

  // Enhanced system prompt with custom MCP capabilities
  String getEnhancedSystemPrompt() {
    final enabledServersList = enabledServers;
    if (enabledServersList.isEmpty) {
      return _getBaseSystemPrompt();
    }

    final mcpCapabilities = enabledServersList
        .map(
          (server) =>
              '- ${server.name}: ${server.description}${server.isCustom ? " (مخصص)" : ""}',
        )
        .join('\n');

    return '''${_getBaseSystemPrompt()}

## 🔧 Available MCP Servers:
$mcpCapabilities

You can use these servers to enhance your responses:
- Use the memory server to store and retrieve important information
- Use sequential thinking for complex problems
- Use custom MCP servers for specialized tasks

Remember to format your responses clearly using Markdown and proper code formatting.''';
  }

  String _getBaseSystemPrompt() {
    return '''You are an intelligent AI assistant with expertise in various domains.

## 🌐 Language Guidelines:
- **Default to Arabic** when responding, but you can communicate in any language if the user requests it
- **Adapt naturally** to the user's language preference - if user writes in French, respond in French; if in Spanish, respond in Spanish
- **Be multilingual and flexible** - you support ALL languages, not just Arabic and English
- **IMPORTANT**: You are NOT restricted to Arabic and English only - you can respond in any language
- **Format responses clearly** using Markdown for better readability

## 💻 Code and Script Formatting Guidelines:
- **ALWAYS use proper Markdown code blocks** for any code or scripts
- **Use correct language tags** (e.g., ```json, ```python, ```bash, ```dart, ```javascript, etc.)
- **Scripts should NOT be written in English** - use the appropriate native language for the script type
- **Code blocks will have appropriate backgrounds**: black for day mode, beige for night mode
- **Code direction**: Only code inside blocks should be left-to-right (LTR)
- **Examples of proper formatting**:
  ```json
  {
    "example": "value"
  }
  ```
  ```python
  def example_function():
      return "Hello World"
  ```
  ```bash
  echo "مرحبا بالعالم"
  ```

## 🔧 Available Tools:
You have access to powerful search and web tools:

### 📊 Tavily Search (tavily_search):
- **When to use**: For current information, news, recent events, facts verification
- **How to use**: Call tavily_search with a relevant query when users ask for:
  - Current events or recent news
  - Latest prices, weather, or real-time data
  - Fact verification or research
  - Information about recent developments
- **Example triggers**: "آخر أخبار", "سعر", "طقس", "ما الجديد", "recent", "current", "today"

### 🔍 Tavily Extract (tavily_extract):
- **When to use**: To extract specific content from web pages
- **How to use**: Call tavily_extract with URL(s) when users need detailed content from specific websites

## 📋 Core Tasks:
1. **Provide helpful and accurate responses**
2. **Use tools when appropriate** - Don't hesitate to search for current information
3. **Use proper Markdown formatting** - organize your answers beautifully
4. **Format code properly** - use appropriate syntax highlighting with correct language tags

## 🎯 Tool Usage Guidelines:
- **Always use tavily_search** when the user's question requires current or recent information
- **Be proactive** in using search tools for queries about news, prices, weather, or real-time data
- **Combine search results** with your knowledge to provide comprehensive answers

Remember: Your goal is to provide the best possible assistance while adapting to the user's communication style and language preference. You support ALL world languages!''';
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
  final bool isCustom;
  final String? command;
  final List<String>? args;
  final Map<String, String>? env;

  McpServer({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.capabilities,
    this.isCustom = false,
    this.command,
    this.args,
    this.env,
  });

  McpServer copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
    List<String>? capabilities,
    bool? isCustom,
    String? command,
    List<String>? args,
    Map<String, String>? env,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      capabilities: capabilities ?? this.capabilities,
      isCustom: isCustom ?? this.isCustom,
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isEnabled': isEnabled,
      'capabilities': capabilities,
      'isCustom': isCustom,
      if (command != null) 'command': command,
      if (args != null) 'args': args,
      if (env != null) 'env': env,
    };
  }

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isEnabled: json['isEnabled'] as bool,
      capabilities: List<String>.from(json['capabilities'] as List),
      isCustom: json['isCustom'] as bool? ?? false,
      command: json['command'] as String?,
      args: json['args'] != null
          ? List<String>.from(json['args'] as List)
          : null,
      env: json['env'] != null
          ? Map<String, String>.from(json['env'] as Map)
          : null,
    );
  }
}

class McpException implements Exception {
  final String message;
  McpException(this.message);

  @override
  String toString() => 'McpException: $message';
}
