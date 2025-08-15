import 'package:flutter/material.dart';
import '../../core/services/groq_service.dart';
import '../../core/services/gptgod_service.dart';
import '../../core/services/api_key_manager.dart';
import '../../core/services/openrouter_service.dart';
import '../../core/services/huggingface_service.dart';

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
    
    try {
      // فحص Groq
      final groqService = GroqService();
      if (groqService.isInitialized) {
        results['groq'] = await groqService.performHealthCheck();
      } else {
        results['groq'] = false;
      }
    } catch (e) {
      results['groq'] = false;
    }

    try {
      // فحص GPTGod
      final gptgodService = GPTGodService();
      if (gptgodService.isInitialized) {
        results['gptgod'] = await gptgodService.performHealthCheck();
      } else {
        results['gptgod'] = false;
      }
    } catch (e) {
      results['gptgod'] = false;
    }

    try {
      // فحص HuggingFace
      final huggingfaceService = HuggingFaceService();
      if (huggingfaceService.isInitialized) {
        results['huggingface'] = await huggingfaceService.performHealthCheck();
      } else {
        results['huggingface'] = false;
      }
    } catch (e) {
      results['huggingface'] = false;
    }

    try {
      // فحص OpenRouter
      final openrouterService = OpenRouterService();
      if (openrouterService.isInitialized) {
        results['openrouter'] = await openrouterService.performHealthCheck();
      } else {
        results['openrouter'] = false;
      }
    } catch (e) {
      results['openrouter'] = false;
    }

    try {
      // فحص LocalAI
      // LocalAI لا يحتاج health check لأنه محلي
      results['localai'] = true;
    } catch (e) {
      results['localai'] = false;
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات API التشخيصية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
            tooltip: 'تحديث',
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
    final status = data['status'] as String? ?? 'غير معروف';
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
        subtitle: Text('الحالة: ${isHealthy ? 'نشط' : 'غير نشط'}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('الحالة العامة', status),
                _buildInfoRow('عدد الطلبات', requests.toString()),
                _buildInfoRow('عدد الأخطاء', errors.toString()),
                _buildInfoRow('معدل النجاح', successRate),
                if (lastUsed != null)
                  _buildInfoRow('آخر استخدام', _formatDateTime(lastUsed)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _clearServiceStats(serviceName),
                        icon: const Icon(Icons.clear),
                        label: const Text('مسح الإحصائيات'),
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
                        label: const Text('إعادة تهيئة'),
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
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  Future<void> _clearServiceStats(String serviceName) async {
    try {
      await ApiKeyManager.clearUsageStats(serviceName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم مسح إحصائيات $serviceName'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDebugInfo(); // إعادة تحميل البيانات
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في مسح إحصائيات $serviceName: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reinitializeService(String serviceName) async {
    try {
      switch (serviceName) {
        case 'groq':
          final service = GroqService();
          await service.reinitialize();
          await service.initialize();
          break;
        case 'gptgod':
          final service = GPTGodService();
          await service.reinitialize();
          await service.initialize();
          break;
        case 'huggingface':
          final service = HuggingFaceService();
          await service.reinitialize();
          await service.initialize();
          break;
        case 'openrouter':
          final service = OpenRouterService();
          await service.reinitialize();
          break;
        case 'localai':
          // LocalAI لا يحتاج إعادة تهيئة
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إعادة تهيئة $serviceName'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDebugInfo(); // إعادة تحميل البيانات
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إعادة تهيئة $serviceName: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
