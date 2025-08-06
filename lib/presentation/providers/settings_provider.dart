import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Getters
  String get selectedModel => _selectedModel;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  bool get streamResponse => _streamResponse;
  bool get enableWebSearch => _enableWebSearch;
  bool get enableMcpServers => _enableMcpServers;
  Map<String, bool> get mcpServerStatus => Map.unmodifiable(_mcpServerStatus);

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

  void _loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _selectedModel = prefs.getString('selectedModel') ?? 'gemma2-9b-it';
      _temperature = prefs.getDouble('temperature') ?? 1.0;
      _maxTokens = prefs.getInt('maxTokens') ?? 1024;
      _streamResponse = prefs.getBool('streamResponse') ?? true;
      _enableWebSearch = prefs.getBool('enableWebSearch') ?? true;
      _enableMcpServers = prefs.getBool('enableMcpServers') ?? true;

      // Load MCP server status
      final mcpMemory = prefs.getBool('mcp_memory') ?? true;
      final mcpThinking = prefs.getBool('mcp_sequential-thinking') ?? true;
      _mcpServerStatus = {
        'memory': mcpMemory,
        'sequential-thinking': mcpThinking,
      };

      notifyListeners();
    } catch (e) {
      // Error loading settings: $e (تم إخفاء طباعة الأخطاء)
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

      // Save MCP server status
      prefs.setBool('mcp_memory', _mcpServerStatus['memory'] ?? true);
      prefs.setBool(
        'mcp_sequential-thinking',
        _mcpServerStatus['sequential-thinking'] ?? true,
      );
    } catch (e) {
      // Error saving settings: $e (تم إخفاء طباعة الأخطاء)
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
    _saveSettings();
    notifyListeners();
  }
}
