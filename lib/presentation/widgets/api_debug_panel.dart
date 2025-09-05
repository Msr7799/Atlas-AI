import 'package:flutter/material.dart';
import '../../core/services/api_key_manager.dart';
import '../../core/services/unified_ai_service.dart';

/// لوحة تشخيص API لعرض معلومات الخدمات
class ApiDebugPanel extends StatefulWidget {
  const ApiDebugPanel({super.key});

  @override
  State<ApiDebugPanel> createState() => _ApiDebugPanelState();
}

class _ApiDebugPanelState extends State<ApiDebugPanel> {
  final Map<String, Map<String, dynamic>> _debugInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await ApiKeyManager.getAllUsageStats();
      final healthChecks = await _performHealthChecks();
      
      // دمج الإحصائيات مع فحوصات الصحة
      for (final entry in stats.entries) {
        final serviceName = entry.key;
        final serviceStats = entry.value;
        
        _debugInfo[serviceName] = {
          ...serviceStats,
          'health': healthChecks[serviceName] ?? false,
        };
      }
    } catch (e) {
      print('❌ [API_DEBUG_PANEL] فشل في تحميل معلومات التشخيص: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<Map<String, bool>> _performHealthChecks() async {
    final results = <String, bool>{};
    final unifiedService = UnifiedAIService();
    
    try {
      await unifiedService.initialize();
      
      // فحص جميع الخدمات من خلال الخدمة الموحدة
      final services = ['groq', 'gptgod', 'huggingface', 'openrouter', 'localai'];
      
      for (final serviceName in services) {
        try {
          // فحص وجود مفتاح API للخدمة
          final hasApiKey = await _checkServiceApiKey(serviceName);
          results[serviceName] = hasApiKey;
        } catch (e) {
          results[serviceName] = false;
        }
      }
    } catch (e) {
      // في حالة فشل تهيئة الخدمة الموحدة، اجعل جميع الخدمات غير نشطة
      for (final serviceName in ['groq', 'gptgod', 'huggingface', 'openrouter', 'localai']) {
        results[serviceName] = false;
      }
    }

    return results;
  }

  Future<bool> _checkServiceApiKey(String serviceName) async {
    try {
      switch (serviceName) {
        case 'groq':
          final key = await ApiKeyManager.getApiKey('groq_api_key');
          return key.isNotEmpty;
        case 'gptgod':
          final key = await ApiKeyManager.getApiKey('gptgod_api_key');
          return key.isNotEmpty;
        case 'huggingface':
          final key = await ApiKeyManager.getApiKey('huggingface_api_key');
          return key.isNotEmpty;
        case 'openrouter':
          final key = await ApiKeyManager.getApiKey('openrouter_api_key');
          return key.isNotEmpty;
        case 'localai':
          return true; // LocalAI لا يحتاج مفتاح API
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'معلومات API التشخيصية' : 'API Debug Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
            tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'تحديث' : 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _debugInfo.length,
              itemBuilder: (context, index) {
                final serviceName = _debugInfo.keys.elementAt(index);
                final serviceData = _debugInfo[serviceName]!;
                
                return _buildServiceTile(serviceName, serviceData);
              },
            ),
    );
  }

  Widget _buildServiceTile(String serviceName, Map<String, dynamic> data) {
    final isHealthy = data['health'] as bool? ?? false;
    final status = data['status'] as String? ?? (Localizations.localeOf(context).languageCode == 'ar' ? 'غير معروف' : 'Unknown');
    final requests = data['requests'] as int? ?? 0;
    final errors = data['errors'] as int? ?? 0;
    final successRate = data['successRate'] as String? ?? '0%';
    final lastUsed = data['lastUsed'] as DateTime?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          isHealthy ? Icons.check_circle : Icons.error,
          color: isHealthy ? Colors.green : Colors.red,
          size: 28,
        ),
        title: Text(
          _getServiceDisplayName(serviceName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الحالة: ${isHealthy ? "نشط" : "غير نشط"}' : 'Status: ${isHealthy ? "Active" : "Inactive"}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Localizations.localeOf(context).languageCode == 'ar' ? 'الحالة العامة' : 'General Status', status),
                _buildInfoRow(Localizations.localeOf(context).languageCode == 'ar' ? 'عدد الطلبات' : 'Request Count', requests.toString()),
                _buildInfoRow(Localizations.localeOf(context).languageCode == 'ar' ? 'عدد الأخطاء' : 'Error Count', errors.toString()),
                _buildInfoRow(Localizations.localeOf(context).languageCode == 'ar' ? 'معدل النجاح' : 'Success Rate', successRate),
                if (lastUsed != null)
                  _buildInfoRow(Localizations.localeOf(context).languageCode == 'ar' ? 'آخر استخدام' : 'Last Used', _formatDateTime(lastUsed)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _clearServiceStats(serviceName),
                        icon: const Icon(Icons.clear),
                        label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مسح الإحصائيات' : 'Clear Stats'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _reinitializeService(serviceName),
                        icon: const Icon(Icons.refresh),
                        label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تهيئة' : 'Reinitialize'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceDisplayName(String serviceName) {
    switch (serviceName) {
      case 'groq':
        return 'Groq';
      case 'gptgod':
        return 'GPTGod';
      case 'huggingface':
        return 'Hugging Face';
      case 'openrouter':
        return 'OpenRouter';
      case 'localai':
        return 'Local AI';
      case 'tavily':
        return 'Tavily';
      default:
        return serviceName;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return Localizations.localeOf(context).languageCode == 'ar' ? 'منذ ${difference.inDays} يوم' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return Localizations.localeOf(context).languageCode == 'ar' ? 'منذ ${difference.inHours} ساعة' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return Localizations.localeOf(context).languageCode == 'ar' ? 'منذ ${difference.inMinutes} دقيقة' : '${difference.inMinutes} minutes ago';
    } else {
      return Localizations.localeOf(context).languageCode == 'ar' ? 'الآن' : 'Now';
    }
  }

  Future<void> _clearServiceStats(String serviceName) async {
    try {
      await ApiKeyManager.clearUsageStats(serviceName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم مسح إحصائيات $serviceName' : 'Cleared stats for $serviceName'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDebugInfo(); // إعادة تحميل البيانات
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'فشل في مسح إحصائيات $serviceName: $e' : 'Failed to clear stats for $serviceName: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reinitializeService(String serviceName) async {
    try {
      final unifiedService = UnifiedAIService();
      
      // إعادة تهيئة الخدمة الموحدة
      await unifiedService.initialize();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم إعادة تهيئة $serviceName' : 'Reinitialized $serviceName'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDebugInfo(); // إعادة تحميل البيانات
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'فشل في إعادة تهيئة $serviceName: $e' : 'Failed to reinitialize $serviceName: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
