import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsProvider extends ChangeNotifier {
  String _selectedModel = 'gemma2-9b-it';
  double _temperature = 1.0;
  int _maxTokens = 1024;
  bool _streamResponse = true;
  bool _enableWebSearch = true;
  bool _enableMcpServers = true;
  Map<String, bool> _mcpServerStatus = {
    'memory': true,
    'sequential-thinking': true,
  };
  
  // إضافة دعم MCP مخصص
  Map<String, dynamic> _customMcpServers = {};
  String _customMcpJson = '';

  // Getters
  String get selectedModel => _selectedModel;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  bool get streamResponse => _streamResponse;
  bool get enableWebSearch => _enableWebSearch;
  bool get enableMcpServers => _enableMcpServers;
  Map<String, bool> get mcpServerStatus => Map.unmodifiable(_mcpServerStatus);
  Map<String, dynamic> get customMcpServers => Map.unmodifiable(_customMcpServers);
  String get customMcpJson => _customMcpJson;

  SettingsProvider() {
    _loadSettings();
  }

  void setModel(String model) {
    _selectedModel = model;
    _saveSettings();
    notifyListeners();
  }

  void setTemperature(double temp) {
    _temperature = temp;
    _saveSettings();
    notifyListeners();
  }

  void setMaxTokens(int tokens) {
    _maxTokens = tokens;
    _saveSettings();
    notifyListeners();
  }

  void setStreamResponse(bool enable) {
    _streamResponse = enable;
    _saveSettings();
    notifyListeners();
  }

  void setEnableWebSearch(bool enable) {
    _enableWebSearch = enable;
    _saveSettings();
    notifyListeners();
  }

  void setEnableMcpServers(bool enable) {
    _enableMcpServers = enable;
    _saveSettings();
    notifyListeners();
  }

  void setMcpServerStatus(String serverName, bool enabled) {
    _mcpServerStatus[serverName] = enabled;
    _saveSettings();
    notifyListeners();
  }

  // دوال MCP المخصصة الجديدة
  Future<bool> setCustomMcpJson(String jsonString) async {
    try {
      if (jsonString.trim().isEmpty) {
        _customMcpJson = '';
        _customMcpServers = {};
        _saveSettings();
        notifyListeners();
        return true;
      }

      // تحقق من صحة JSON
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // تحقق من البنية المطلوبة
      if (!_validateMcpJson(parsed)) {
        return false;
      }

      _customMcpJson = jsonString;
      _customMcpServers = parsed;
      
      // إضافة الخوادم المخصصة إلى حالة الخوادم
      for (String serverName in _customMcpServers.keys) {
        if (!_mcpServerStatus.containsKey(serverName)) {
          _mcpServerStatus[serverName] = false; // معطل افتراضياً
        }
      }

      _saveSettings();
      notifyListeners();
      return true;
    } catch (e) {
      print('[SETTINGS] خطأ في تحليل JSON: $e');
      return false;
    }
  }

  bool _validateMcpJson(Map<String, dynamic> json) {
    try {
      // التحقق من أن كل خادم له البنية المطلوبة
      for (String serverName in json.keys) {
        final server = json[serverName] as Map<String, dynamic>?;
        if (server == null) return false;

        // التحقق من الحقول المطلوبة
        if (!server.containsKey('command') || 
            !server.containsKey('args')) {
          return false;
        }

        // التحقق من نوع البيانات
        if (server['command'] is! String || 
            server['args'] is! List) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  List<String> getAvailableMcpServers() {
    final defaultServers = ['memory', 'sequential-thinking'];
    final customServers = _customMcpServers.keys.toList();
    return [...defaultServers, ...customServers];
  }

  Map<String, dynamic> getMcpServerConfig(String serverName) {
    // الخوادم الافتراضية
    const defaultServers = {
      'memory': {
        'command': 'npx',
        'args': ['-y', '@modelcontextprotocol/server-memory'],
        'env': {'MEMORY_FILE_PATH': '/home/msr/Desktop/flutter_AI_memory.json'},
      },
      'sequential-thinking': {
        'command': 'npx',
        'args': ['-y', '@modelcontextprotocol/server-sequential-thinking'],
      },
    };

    if (defaultServers.containsKey(serverName)) {
      return defaultServers[serverName]!;
    }

    return _customMcpServers[serverName] ?? {};
  }

  void removeCustomMcpServer(String serverName) {
    if (_customMcpServers.containsKey(serverName)) {
      _customMcpServers.remove(serverName);
      _mcpServerStatus.remove(serverName);
      
      // تحديث JSON
      _customMcpJson = _customMcpServers.isEmpty 
          ? '' 
          : jsonEncode(_customMcpServers);
      
      _saveSettings();
      notifyListeners();
    }
  }

  void _loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _selectedModel = prefs.getString('selectedModel') ?? 'gemma2-9b-it';
      _temperature = prefs.getDouble('temperature') ?? 1.0;
      _maxTokens = prefs.getInt('maxTokens') ?? 1024;
      _streamResponse = prefs.getBool('streamResponse') ?? true;
      _enableWebSearch = prefs.getBool('enableWebSearch') ?? true;
      _enableMcpServers = prefs.getBool('enableMcpServers') ?? true;

      // تحميل إعدادات MCP
      final mcpMemory = prefs.getBool('mcp_memory') ?? true;
      final mcpThinking = prefs.getBool('mcp_sequential-thinking') ?? true;
      _mcpServerStatus = {
        'memory': mcpMemory,
        'sequential-thinking': mcpThinking,
      };

      // تحميل MCP المخصص
      _customMcpJson = prefs.getString('customMcpJson') ?? '';
      if (_customMcpJson.isNotEmpty) {
        try {
          _customMcpServers = jsonDecode(_customMcpJson) as Map<String, dynamic>;
          
          // إضافة حالة الخوادم المخصصة
          for (String serverName in _customMcpServers.keys) {
            _mcpServerStatus[serverName] = prefs.getBool('mcp_$serverName') ?? false;
          }
        } catch (e) {
          print('[SETTINGS] خطأ في تحميل MCP المخصص: $e');
          _customMcpJson = '';
          _customMcpServers = {};
        }
      }

      notifyListeners();
    } catch (e) {
      print('[SETTINGS] خطأ في تحميل الإعدادات: $e');
    }
  }

  void _saveSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedModel', _selectedModel);
      prefs.setDouble('temperature', _temperature);
      prefs.setInt('maxTokens', _maxTokens);
      prefs.setBool('streamResponse', _streamResponse);
      prefs.setBool('enableWebSearch', _enableWebSearch);
      prefs.setBool('enableMcpServers', _enableMcpServers);

      // حفظ إعدادات MCP
      for (String serverName in _mcpServerStatus.keys) {
        prefs.setBool('mcp_$serverName', _mcpServerStatus[serverName] ?? false);
      }

      // حفظ MCP المخصص
      prefs.setString('customMcpJson', _customMcpJson);
    } catch (e) {
      print('[SETTINGS] خطأ في حفظ الإعدادات: $e');
    }
  }

  void resetToDefaults() {
    _selectedModel = 'gemma2-9b-it';
    _temperature = 1.0;
    _maxTokens = 1024;
    _streamResponse = true;
    _enableWebSearch = true;
    _enableMcpServers = true;
    _mcpServerStatus = {'memory': true, 'sequential-thinking': true};
    _customMcpServers = {};
    _customMcpJson = '';
    _saveSettings();
    notifyListeners();
  }
}
