import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_key_manager.dart';
import '../../providers/chat_provider.dart';
import '../../../generated/l10n/app_localizations.dart';

class ApiKeysSection extends StatefulWidget {
  const ApiKeysSection({super.key});

  @override
  State<ApiKeysSection> createState() => _ApiKeysSectionState();
}

class _ApiKeysSectionState extends State<ApiKeysSection> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _obscureText = {};
  final Map<String, bool> _isLoading = {};

  List<Map<String, dynamic>> _getApiServices(BuildContext context) => [
    {
      'id': 'groq',
      'name': 'Groq',
      'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نماذج Llama و Mixtral السريعة' : 'Fast Llama & Mixtral models',
      'icon': Icons.flash_on,
      'color': Colors.orange,
      'envKey': 'GROQ_API_KEY',
      'required': true,
    },
    {
      'id': 'gptgod',
      'name': 'GPTGod',
      'description': Localizations.localeOf(context).languageCode == 'ar' ? 'GPT-4o و Claude-3.5' : 'GPT-4o & Claude-3.5',
      'icon': Icons.auto_awesome,
      'color': Colors.purple,
      'envKey': 'GPTGOD_API_KEY',
      'required': false,
    },
    {
      'id': 'openrouter',
      'name': 'OpenRouter',
      'description': Localizations.localeOf(context).languageCode == 'ar' ? 'مجموعة واسعة من النماذج' : 'Wide range of models',
      'icon': Icons.router,
      'color': Colors.blue,
      'envKey': 'OPEN_ROUTER_API',
      'required': false,
    },
    {
      'id': 'huggingface',
      'name': 'HuggingFace',
      'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نماذج مفتوحة المصدر' : 'Open source models',
      'icon': Icons.hub,
      'color': Colors.yellow,
      'envKey': 'HUGGINGFACE_API_KEY',
      'required': false,
    },
    {
      'id': 'tavily',
      'name': 'Tavily',
      'description': Localizations.localeOf(context).languageCode == 'ar' ? 'البحث في الإنترنت' : 'Internet search',
      'icon': Icons.search,
      'color': Colors.green,
      'envKey': 'TAVILY_API_KEY',
      'required': false,
    },
    {
      'id': 'localai',
      'name': 'LocalAI / Ollama',
      'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نماذج محلية للخصوصية الكاملة' : 'Local models for complete privacy',
      'icon': Icons.computer,
      'color': Colors.teal,
      'envKey': 'LOCALAI_URL',
      'required': false,
      'isLocal': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadApiKeys();
  }

  void _initializeControllers() {
    final services = _getApiServices(context);
    for (final service in services) {
      final id = service['id'] as String;
      _controllers[id] = TextEditingController();
      _obscureText[id] = true;
      _isLoading[id] = false;
    }
  }

  Future<void> _loadApiKeys() async {
    final services = _getApiServices(context);
    for (final service in services) {
      final id = service['id'] as String;
      try {
        final apiKey = await ApiKeyManager.getApiKey(id);
        if (mounted) {
          _controllers[id]?.text = apiKey;
        }
      } catch (e) {
        print('Error loading key $id: $e');
      }
    }
  }

  Future<void> _saveApiKey(String serviceId) async {
    setState(() {
      _isLoading[serviceId] = true;
    });

    try {
      final apiKey = _controllers[serviceId]?.text ?? '';
      await ApiKeyManager.saveApiKey(serviceId, apiKey);
      
      // تحديث الخدمة الموحدة
      if (mounted) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        await chatProvider.updateApiKey(serviceId, apiKey);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم حفظ مفتاح $serviceId بنجاح' : '$serviceId key saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'خطأ في حفظ مفتاح $serviceId: $e' : 'Error saving $serviceId key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading[serviceId] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'ar' ? '🔑 مفاتيح API' : '🔑 API Keys',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Localizations.localeOf(context).languageCode == 'ar' ? 'أدخل مفاتيح API الخاصة بك للوصول إلى النماذج المختلفة' : 'Enter your API keys to access different models',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        
        // قائمة الخدمات
        ...(_getApiServices(context).map((service) => _buildServiceCard(service))),
        
        const SizedBox(height: 16),
        
        // معلومات إضافية
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'معلومات مهمة' : 'Important Information',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'ar' 
                    ? '• يمكنك استخدام ملف .env لتخزين المفاتيح\n'
                      '• المفاتيح محفوظة بشكل آمن ومشفر\n'
                      '• يمكن استخدام عدة مفاتيح للخدمة الواحدة\n'
                      '• التطبيق يختار أفضل خدمة تلقائياً'
                    : '• You can use .env file to store keys\n'
                      '• Keys are stored securely and encrypted\n'
                      '• Multiple keys can be used per service\n'
                      '• App automatically chooses best service',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final id = service['id'] as String;
    final name = service['name'] as String;
    final description = service['description'] as String;
    final icon = service['icon'] as IconData;
    final color = service['color'] as Color;
    final isRequired = service['required'] as bool? ?? false;
    final isLocal = service['isLocal'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isRequired)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                Localizations.localeOf(context).languageCode == 'ar' ? 'مطلوب' : 'Required',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isLocal)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                Localizations.localeOf(context).languageCode == 'ar' ? 'محلي' : 'Local',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[id],
                    obscureText: !isLocal && (_obscureText[id] ?? true),
                    decoration: InputDecoration(
                      hintText: isLocal
                          ? (Localizations.localeOf(context).languageCode == 'ar' 
                              ? 'أدخل عنوان URL للخادم المحلي (مثل: http://localhost:11434)'
                              : 'Enter local server URL (e.g.: http://localhost:11434)')
                          : (Localizations.localeOf(context).languageCode == 'ar' 
                              ? 'أدخل مفتاح $name API'
                              : 'Enter $name API key'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLocal)
                            IconButton(
                              icon: Icon(
                                (_obscureText[id] ?? true)
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText[id] = !(_obscureText[id] ?? true);
                                });
                              },
                            ),
                          if (_isLoading[id] ?? false)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () => _saveApiKey(id),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // إضافة معلومات إضافية للخدمات المحلية
            if (isLocal)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'ar' 
                              ? 'تأكد من تشغيل Ollama أو LocalAI على جهازك'
                              : 'Make sure Ollama or LocalAI is running on your device',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
