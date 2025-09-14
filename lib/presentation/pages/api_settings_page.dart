import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/unified_ai_service.dart';
import '../../core/services/tavily_service.dart';
import '../../core/services/api_key_manager.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/models_info_dialog.dart';
import '../../generated/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiSettingsPage extends StatefulWidget {
  const ApiSettingsPage({super.key});

  @override
  State<ApiSettingsPage> createState() => _ApiSettingsPageState();
}

class _ApiSettingsPageState extends State<ApiSettingsPage> {
  final _gptgodController = TextEditingController();
  final _tavilyController = TextEditingController();
  final _openRouterController = TextEditingController();
  final _openrouterController = TextEditingController();

  bool _isLoading = false;
  bool _obscureKeys = true;

  // حالة المفاتيح / Keys status
  bool hasRequiredKeys = false;
  bool hasAnyKeys = false;
  bool isUsingDefaultKeys = false;
  Map<String, Map<String, dynamic>> serviceInfo = {};

  // حالة صلاحية المفاتيح / API key validation status
  final Map<String, bool?> _keyValidationStatus = {
    'gptgod': null,
    'openrouter': null,
    'tavily': null,
  };

  // حالة التحقق من المفاتيح / Validation in progress status
  final Map<String, bool> _isValidating = {
    'gptgod': false,
    'openrouter': false,
    'tavily': false,
  };

  // حالة عرض الديباق / Debug display status
  final Map<String, bool> _showDebugInfo = {
    'gptgod': false,
    'openrouter': false,
    'tavily': false,
  };

  // تفاصيل الديباق للاستدعاءات / Debug info for API calls
  final Map<String, Map<String, dynamic>> _debugInfo = {
    'gptgod': {},
    'openrouter': {},
    'tavily': {},
  };

  @override
  void initState() {
    super.initState();
    _loadSavedKeys();
    _updateKeysStatus();
  }

  // تحديث حالة المفاتيح
  Future<void> _updateKeysStatus() async {
    final hasRequiredKeys = await ApiKeyManager.hasRequiredKeys();
    final hasAnyKeys = await ApiKeyManager.hasAnyKeys();
    final isUsingDefaultKeys = await ApiKeyManager.isUsingDefaultKeys();

    if (mounted) {
      setState(() {
        // تحديث حالة المفاتيح / Update keys status
        this.hasRequiredKeys = hasRequiredKeys;
        this.hasAnyKeys = hasAnyKeys;
        this.isUsingDefaultKeys = isUsingDefaultKeys;
      });
    }
  }

  Future<void> _loadSavedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gptgodController.text = prefs.getString('gptgod_api_key') ?? '';
      _tavilyController.text = prefs.getString('tavily_api_key') ?? '';
      _openrouterController.text = prefs.getString('openrouter_api_key') ?? '';
    });

    // تحديث حالة المفاتيح
    await _updateKeysStatus();
  }

  Future<void> _saveKeys() async {
    setState(() => _isLoading = true);

    try {
      // حفظ المفاتيح باستخدام ApiKeyManager / Save keys using ApiKeyManager
      if (_gptgodController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey('gptgod', _gptgodController.text.trim());
      }
      if (_tavilyController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey('tavily', _tavilyController.text.trim());
      }
      if (_openrouterController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey(
          'openrouter',
          _openrouterController.text.trim(),
        );
      }

      // إعادة تهيئة الخدمات بالمفاتيح الجديدة / Reinitialize services with new keys
      await _reinitializeServices();

      // تحديث حالة المفاتيح
      await _updateKeysStatus();

      _showSnackBar(
        AppLocalizations.of(context).keysSavedSuccess,
        Colors.green
      );
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context).errorSavingKeys(e.toString()),
        Colors.red
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reinitializeServices() async {
    try {
      final tavilyKey = await ApiKeyManager.getApiKey('tavily');
      try {
        final aiService = UnifiedAIService();
        await aiService.initialize();
        if (tavilyKey.isNotEmpty) {
          TavilyService().updateApiKey(tavilyKey);
        }
      } catch (serviceError) {
        print('[AI SERVICE INIT ERROR] $serviceError');
      }
    } catch (e) {
      print('[SERVICE REINITIALIZATION ERROR] $e');
    }
  }

  // دوال التحقق من صلاحية المفاتيح
  Future<void> _validateApiKey(String service) async {
    setState(() {
      _isValidating[service] = true;
      _keyValidationStatus[service] = null;
    });

    try {
      bool isValid = false;
      String message = '';

      switch (service) {
        case 'gptgod':
          final result = await _testGptGodKey();
          isValid = result['success'];
          message = result['message'];
          break;
        case 'openrouter':
          final result = await _testOpenRouterKey();
          isValid = result['success'];
          message = result['message'];
          break;
        case 'tavily':
          final result = await _testTavilyKey();
          isValid = result['success'];
          message = result['message'];
          break;
      }

      setState(() {
        _keyValidationStatus[service] = isValid;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isValid ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _keyValidationStatus[service] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'خطأ في التحقق من $service: $e'
                  : 'Error validating $service: $e'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isValidating[service] = false;
      });
    }
  }


  // اختبار مفتاح GPTGod مع GPT-3.5-turbo
  Future<Map<String, dynamic>> _testGptGodKey() async {
    try {
      final apiKey = await ApiKeyManager.getApiKey('gptgod');
      if (apiKey.isEmpty) {
        _debugInfo['gptgod'] = {
          'request': Localizations.localeOf(context).languageCode == 'ar' 
              ? 'لا يوجد مفتاح API' 
              : 'No API key found',
          'response': Localizations.localeOf(context).languageCode == 'ar'
              ? 'فشل - مفتاح غير موجود'
              : 'Failed - Key not found',
          'timestamp': DateTime.now().toString(),
        };
        return {
          'success': false, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح GPTGod غير موجود'
              : 'GPTGod API key not found'
        };
      }

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 5,
      };

      final response = await http.post(
        Uri.parse('https://api.gptgod.online/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // حفظ تفاصيل الديباق
      _debugInfo['gptgod'] = {
        'request': {
          'url': 'https://api.gptgod.online/v1/chat/completions',
          'method': 'POST',
          'headers': {
            'Authorization': 'Bearer ${apiKey.substring(0, 10)}...',
            'Content-Type': 'application/json',
          },
          'body': requestBody,
        },
        'response': {
          'status_code': response.statusCode,
          'body': response.body,
        },
        'timestamp': DateTime.now().toString(),
      };

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح GPTGod يعمل بشكل صحيح ✅'
              : 'GPTGod API key is working correctly ✅'
        };
      } else {
        return {
          'success': false, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح GPTGod غير صالح - كود الخطأ: ${response.statusCode}'
              : 'Invalid GPTGod API key - Error code: ${response.statusCode}'
        };
      }
    } catch (e) {
      _debugInfo['gptgod'] = {
        'request': Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في الاتصال'
            : 'Connection error',
        'response': Localizations.localeOf(context).languageCode == 'ar'
            ? 'استثناء: $e'
            : 'Exception: $e',
        'timestamp': DateTime.now().toString(),
      };
      return {
        'success': false, 
        'message': Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في اختبار GPTGod: $e'
            : 'Error testing GPTGod: $e'
      };
    }
  }

  // اختبار مفتاح OpenRouter مع نموذج مجاني صحيح
  Future<Map<String, dynamic>> _testOpenRouterKey() async {
    try {
      final apiKey = await ApiKeyManager.getApiKey('openrouter');
      if (apiKey.isEmpty) {
        _debugInfo['openrouter'] = {
          'request': Localizations.localeOf(context).languageCode == 'ar' 
              ? 'لا يوجد مفتاح API' 
              : 'No API key found',
          'response': Localizations.localeOf(context).languageCode == 'ar'
              ? 'فشل - مفتاح غير موجود'
              : 'Failed - Key not found',
          'timestamp': DateTime.now().toString(),
        };
        return {
          'success': false, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح OpenRouter غير موجود'
              : 'OpenRouter API key not found'
        };
      }

      final requestBody = {
        'model': 'meta-llama/llama-3.1-8b-instruct:free',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 5,
      };

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://atlas-ai.app',
          'X-Title': 'Atlas AI',
        },
        body: json.encode(requestBody),
      );

      // حفظ تفاصيل الديباق
      _debugInfo['openrouter'] = {
        'request': {
          'url': 'https://openrouter.ai/api/v1/chat/completions',
          'method': 'POST',
          'headers': {
            'Authorization': 'Bearer ${apiKey.substring(0, 10)}...',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://atlas-ai.app',
            'X-Title': 'Atlas AI',
          },
          'body': requestBody,
        },
        'response': {
          'status_code': response.statusCode,
          'body': response.body,
        },
        'timestamp': DateTime.now().toString(),
      };

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح OpenRouter يعمل بشكل صحيح ✅'
              : 'OpenRouter API key is working correctly ✅'
        };
      } else {
        return {
          'success': false, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح OpenRouter غير صالح - كود الخطأ: ${response.statusCode}'
              : 'Invalid OpenRouter API key - Error code: ${response.statusCode}'
        };
      }
    } catch (e) {
      _debugInfo['openrouter'] = {
        'request': Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في الاتصال'
            : 'Connection error',
        'response': Localizations.localeOf(context).languageCode == 'ar'
            ? 'استثناء: $e'
            : 'Exception: $e',
        'timestamp': DateTime.now().toString(),
      };
      return {
        'success': false, 
        'message': Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في اختبار OpenRouter: $e'
            : 'Error testing OpenRouter: $e'
      };
    }
  }

  // اختبار مفتاح Tavily مع بحث بسيط
  Future<Map<String, dynamic>> _testTavilyKey() async {
    try {
      final apiKey = await ApiKeyManager.getApiKey('tavily');
      if (apiKey.isEmpty) {
        _debugInfo['tavily'] = {
          'request': Localizations.localeOf(context).languageCode == 'ar' 
              ? 'لا يوجد مفتاح API' 
              : 'No API key found',
          'response': Localizations.localeOf(context).languageCode == 'ar'
              ? 'فشل - مفتاح غير موجود'
              : 'Failed - Key not found',
          'timestamp': DateTime.now().toString(),
        };
        return {
          'success': false, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح Tavily غير موجود'
              : 'Tavily API key not found'
        };
      }

      final requestBody = {
        'api_key': apiKey,
        'query': 'test',
        'max_results': 1,
      };

      final response = await http.post(
        Uri.parse('https://api.tavily.com/search'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // حفظ تفاصيل الديباق
      _debugInfo['tavily'] = {
        'request': {
          'url': 'https://api.tavily.com/search',
          'method': 'POST',
          'headers': {
            'Content-Type': 'application/json',
          },
          'body': {
            'api_key': '${apiKey.substring(0, 10)}...',
            'query': 'test',
            'max_results': 1,
          },
        },
        'response': {
          'status_code': response.statusCode,
          'body': response.body,
        },
        'timestamp': DateTime.now().toString(),
      };

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح Tavily يعمل بشكل صحيح ✅'
              : 'Tavily API key is working correctly ✅'
        };
      } else {
        return {
          'success': false, 
          'message': Localizations.localeOf(context).languageCode == 'ar'
              ? 'مفتاح Tavily غير صالح - كود الخطأ: ${response.statusCode}'
              : 'Invalid Tavily API key - Error code: ${response.statusCode}'
        };
      }
    } catch (e) {
      _debugInfo['tavily'] = {
        'request': Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في الاتصال'
            : 'Connection error',
        'response': Localizations.localeOf(context).languageCode == 'ar'
            ? 'استثناء: $e'
            : 'Exception: $e',
        'timestamp': DateTime.now().toString(),
      };
      return {
        'success': false, 
        'message': Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في اختبار Tavily: $e'
            : 'Error testing Tavily: $e'
      };
    }
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // دالة تحديد لون المؤشر البصري
  Color _getStatusColor(String serviceName) {
    final validationStatus = _keyValidationStatus[serviceName];
    if (validationStatus == null) {
      // لم يتم التحقق بعد - رمادي
      return Colors.grey;
    } else if (validationStatus) {
      // صالح - أخضر
      return Colors.green;
    } else {
      // غير صالح - أحمر
      return Colors.red;
    }
  }

  // دالة تحديد أيقونة زر التحقق
  IconData _getValidationIcon(String serviceName) {
    final validationStatus = _keyValidationStatus[serviceName];
    if (validationStatus == null) {
      return Icons.help_outline; // لم يتم التحقق
    } else if (validationStatus) {
      return Icons.check_circle; // صالح
    } else {
      return Icons.error_outline; // غير صالح
    }
  }

  // دالة تحديد نص زر التحقق
  String _getValidationText(String serviceName) {
    final validationStatus = _keyValidationStatus[serviceName];
    if (_isValidating[serviceName] == true) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'جاري التحقق...'
          : 'Validating...';
    } else if (validationStatus == null) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'تحقق من المفتاح'
          : 'Verify Key';
    } else if (validationStatus) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'المفتاح صالح ✅'
          : 'Valid Key ✅';
    } else {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'المفتاح غير صالح ❌'
          : 'Invalid Key ❌';
    }
  }

  // دالة تحديد لون زر التحقق
  Color _getValidationButtonColor(String serviceName) {
    final validationStatus = _keyValidationStatus[serviceName];
    if (_isValidating[serviceName] == true) {
      return Colors.orange; // جاري التحقق
    } else if (validationStatus == null) {
      return Colors.blue; // لم يتم التحقق
    } else if (validationStatus) {
      return Colors.green; // صالح
    } else {
      return Colors.red; // غير صالح
    }
  }

  // دالة بناء قسم الديباق
  Widget _buildDebugSection(String title, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr, // إجبار النص على الاتجاه من اليسار لليمين
            child: SelectableText(
              _formatDebugData(data),
              style: const TextStyle(
                fontFamily: 'Courier New',
                fontSize: 12,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // دالة تنسيق بيانات الديباق
  String _formatDebugData(dynamic data) {
    if (data is Map) {
      return data.entries.map((e) {
        final key = e.key.toString();
        final value = e.value;
        if (value is Map) {
          // تنسيق أفضل للخرائط المتداخلة
          final formattedValue = value.entries
              .map((entry) => '  ${entry.key}: ${entry.value}')
              .join('\n');
          return '$key:\n$formattedValue';
        } else {
          return '$key: $value';
        }
      }).join('\n\n');
    } else if (data is String) {
      return data;
    } else {
      return data.toString();
    }
  }

  // عرض dialog حالة المفاتيح
  void _showKeysStatusDialog() async {
    final keysStatus = await ApiKeyManager.getKeysStatus();
    // Check various key states
    await ApiKeyManager.hasAnyKeys();
    await ApiKeyManager.hasRequiredKeys();
    await ApiKeyManager.isUsingDefaultKeys();
    // Get service information
    serviceInfo = ApiKeyManager.getServiceInfo();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ar' 
                        ? 'حالة مفاتيح API'
                        : 'API Keys Status',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // حالة عامة
                  Container(
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(12),
                      tablet: const EdgeInsets.all(16),
                      desktop: const EdgeInsets.all(20),
                    ),
                    decoration: BoxDecoration(
                      color: hasRequiredKeys
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasRequiredKeys
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              hasRequiredKeys
                                  ? Icons.check_circle
                                  : Icons.warning_amber_rounded,
                              color: hasRequiredKeys
                                  ? Colors.green
                                  : Colors.orange,
                              size: ResponsiveHelper.getResponsiveIconSize(
                                context,
                                mobile: 20,
                                tablet: 24,
                                desktop: 28,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.getResponsiveWidth(
                                context,
                                mobile: 8,
                                tablet: 12,
                                desktop: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                hasRequiredKeys
                                    ? (Localizations.localeOf(context).languageCode == 'ar' 
                                        ? 'التطبيق جاهز للعمل ✅'
                                        : 'App ready to work ✅')
                                    : (Localizations.localeOf(context).languageCode == 'ar' 
                                        ? 'يجب إضافة مفاتيح API مطلوبة ⚠️'
                                        : 'Required API keys needed ⚠️'),
                                style: TextStyle(
                                  color: hasRequiredKeys
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isUsingDefaultKeys) ...[
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveHeight(
                              context,
                              mobile: 8,
                              tablet: 12,
                              desktop: 16,
                            ),
                          ),
                          Container(
                            padding: ResponsiveHelper.getResponsivePadding(
                              context,
                              mobile: const EdgeInsets.all(8),
                              tablet: const EdgeInsets.all(12),
                              desktop: const EdgeInsets.all(16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: ResponsiveHelper.getResponsiveIconSize(
                                    context,
                                    mobile: 16,
                                    tablet: 18,
                                    desktop: 20,
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveHelper.getResponsiveWidth(
                                    context,
                                    mobile: 6,
                                    tablet: 8,
                                    desktop: 10,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'أريد فقط لاستخدام النماذج الافتراضية المجاني' : 'I want to use only the default free models',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            mobile: 12,
                                            tablet: 14,
                                            desktop: 16,
                                          ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                  ),
                  // تفاصيل المفاتيح
                  Text(
                    AppLocalizations.of(context).apiKeysStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),
                  ...keysStatus.entries.map((entry) {
                    final service = entry.key;
                    final status = entry.value;
                    final info = serviceInfo[service] ?? {};

                    return _buildKeyStatusItem(
                      info['name'] ?? service,
                      status['hasKey'] ?? false,
                      status['isRequired'] ?? false,
                      isUsingDefault: status['isUsingDefault'] ?? false,
                      keyPreview: status['keyPreview'] ?? '',
                    );
                  }),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                  ),
                  // إحصائيات
                  Container(
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(12),
                      tablet: const EdgeInsets.all(16),
                      desktop: const EdgeInsets.all(20),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).statistics,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveHeight(
                            context,
                            mobile: 4,
                            tablet: 6,
                            desktop: 8,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).keysDetails,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).requiredKeys(hasRequiredKeys ? AppLocalizations.of(context).available : AppLocalizations.of(context).missing),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context).usingFreeDefaultKeys}: ${isUsingDefaultKeys ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).clear,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // بناء عنصر حالة المفتاح
  Widget _buildKeyStatusItem(
    String keyName,
    bool isSaved,
    bool isRequired, {
    bool isUsingDefault = false,
    String keyPreview = '',
  }) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.symmetric(vertical: 4),
        tablet: const EdgeInsets.symmetric(vertical: 6),
        desktop: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSaved ? Icons.check_circle : Icons.cancel,
                color: isSaved ? Colors.green : Colors.red,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      keyName,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (keyPreview.isNotEmpty)
                      Text(
                        keyPreview,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 10,
                            tablet: 12,
                            desktop: 14,
                          ),
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
              if (isRequired)
                Container(
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    mobile: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    tablet: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    desktop: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'مطلوب' : 'Required',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 10,
                        tablet: 12,
                        desktop: 14,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (isUsingDefault && isSaved)
            Container(
              margin: ResponsiveHelper.getResponsivePadding(
                context,
                mobile: const EdgeInsets.only(top: 4, left: 24),
                tablet: const EdgeInsets.only(top: 6, left: 30),
                desktop: const EdgeInsets.only(top: 8, left: 36),
              ),
              padding: ResponsiveHelper.getResponsivePadding(
                context,
                mobile: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                tablet: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                desktop: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(
                      context,
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'مفتاح افتراضي' : 'Default Key',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 10,
                        tablet: 12,
                        desktop: 14,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // عرض dialog مسح المفاتيح
  void _showClearKeysDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).clearApiKeys,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).clearKeysConfirmation,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              Container(
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(12),
                  tablet: const EdgeInsets.all(16),
                  desktop: const EdgeInsets.all(20),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 8,
                            tablet: 12,
                            desktop: 16,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).warning,
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).clearKeysWarning,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearAllKeys();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context).clear,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // مسح جميع المفاتيح
  // حفظ مفتاح واحد قبل الفحص
  Future<void> _saveCurrentKey(String serviceName, TextEditingController controller) async {
    if (controller.text.trim().isNotEmpty) {
      try {
        await ApiKeyManager.saveApiKey(serviceName, controller.text.trim());
      } catch (e) {
        print('[SAVE KEY ERROR] $serviceName: $e');
      }
    }
  }

  Future<void> _clearAllKeys() async {
    try {
      await ApiKeyManager.clearAllApiKeys();

      // مسح الحقول
      setState(() {
        _gptgodController.clear();
        _tavilyController.clear();
        _openrouterController.clear();
      });

      // تحديث حالة المفاتيح
      await _updateKeysStatus();

      _showSnackBar(
        Localizations.localeOf(context).languageCode == 'ar'
            ? 'تم مسح جميع مفاتيح API بنجاح! ✅\nسيتم استخدام المفاتيح الافتراضية المجانية'
            : 'All API keys cleared successfully! ✅\nDefault free keys will be used',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar(
        Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في مسح المفاتيح: $e'
            : 'Error clearing keys: $e',
        Colors.red
      );
    }
  }

  // عرض dialog مسح مفتاح محدد
  void _showClearSpecificKeyDialog(String keyTitle) {
    String keyName = '';
    TextEditingController? controller;

    // تحديد اسم المفتاح والـ controller المناسب
    switch (keyTitle) {
      case 'GPTGod API Key':
        keyName = 'gptgod';
        controller = _gptgodController;
        break;
      case 'Tavily API Key':
        keyName = 'tavily';
        controller = _tavilyController;
        break;
      case 'OpenRouter API Key':
        keyName = 'openrouter';
        controller = _openrouterController;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              Expanded(
                child: Text(
                  'مسح $keyTitle',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل تريد مسح مفتاح $keyTitle من التخزين؟',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              Container(
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(12),
                  tablet: const EdgeInsets.all(16),
                  desktop: const EdgeInsets.all(20),
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 8,
                            tablet: 12,
                            desktop: 16,
                          ),
                        ),
                        Text(
                          'تحذير',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Text(
                      (Localizations.localeOf(context).languageCode == 'ar'
                              ? '• سيتم مسح المفتاح من التخزين\n'
                                '• سيتم استخدام المفتاح الافتراضي المجاني\n'
                                '• يمكنك إعادة إدخاله لاحقاً'
                              : '• Key will be cleared from storage\n'
                                '• Default free key will be used\n'
                                '• You can re-enter it later'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearSpecificKey(keyName, controller);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'مسح المفتاح',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // مسح مفتاح محدد
  Future<void> _clearSpecificKey(
    String keyName,
    TextEditingController? controller,
  ) async {
    try {
      await ApiKeyManager.clearApiKey(keyName);

      // مسح الحقل
      if (controller != null) {
        setState(() {
          controller.clear();
        });
      }

      // تحديث حالة المفاتيح
      await _updateKeysStatus();

      final serviceInfo = ApiKeyManager.getServiceInfo()[keyName] ?? {};
      final serviceName = serviceInfo['name'] ?? keyName;

      _showSnackBar(
        'تم مسح مفتاح $serviceName بنجاح! ✅\nسيتم استخدام المفتاح الافتراضي المجاني',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar(
        Localizations.localeOf(context).languageCode == 'ar'
            ? 'خطأ في مسح المفاتيح: $e'
            : 'Error clearing keys: $e',
        Colors.red
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'إعدادات API'
                : 'API Settings'
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => setState(() => _obscureKeys = !_obscureKeys),
              icon: Icon(
                _obscureKeys ? Icons.visibility : Icons.visibility_off,
              ),
              tooltip: _obscureKeys 
                  ? (Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'إظهار المفاتيح' 
                      : 'Show Keys')
                  : (Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'إخفاء المفاتيح' 
                      : 'Hide Keys'),
            ),
            IconButton(
              onPressed: _showKeysStatusDialog,
              icon: const Icon(Icons.info_outline),
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'حالة المفاتيح'
                  : 'Keys Status',
            ),
            IconButton(
              onPressed: _showClearKeysDialog,
              icon: const Icon(Icons.delete_sweep),
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'مسح المفاتيح'
                  : 'Clear Keys',
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, constraints, deviceType) {
              return Center(
                child: ConstrainedBox(
                  constraints: ResponsiveHelper.getResponsiveConstraints(
                    context,
                    mobile: const BoxConstraints(maxWidth: double.infinity),
                    tablet: const BoxConstraints(maxWidth: 800),
                    desktop: const BoxConstraints(maxWidth: 1000),
                  ),
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(16),
                      tablet: const EdgeInsets.all(24),
                      desktop: const EdgeInsets.all(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // معلومات عامة
                        Card(
                          child: Padding(
                            padding: ResponsiveHelper.getResponsivePadding(
                              context,
                              mobile: const EdgeInsets.all(16),
                              tablet: const EdgeInsets.all(20),
                              desktop: const EdgeInsets.all(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                      width:
                                          ResponsiveHelper.getResponsiveWidth(
                                            context,
                                            mobile: 8,
                                            tablet: 12,
                                            desktop: 16,
                                          ),
                                    ),
                                    Text(
                                      Localizations.localeOf(context).languageCode == 'ar' ? 'معلومات مهمة' : 'Important Information',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                ResponsiveHelper.getResponsiveFontSize(
                                                  context,
                                                  mobile: 16,
                                                  tablet: 18,
                                                  desktop: 20,
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: ResponsiveHelper.getResponsiveHeight(
                                    context,
                                    mobile: 12,
                                    tablet: 16,
                                    desktop: 20,
                                  ),
                                ),
                                Text(
                                  Localizations.localeOf(context).languageCode == 'ar'
                                      ? '• جميع المفاتيح اختيارية للمزيد من الميزات\n'
                                        '• يتم حفظ المفاتيح محلياً على جهازك\n'
                                        '• يمكنك الحصول على مفاتيح مجانية من المواقع الرسمية\n'
                                        '• إذا لم تدخل مفتاحاً، سيتم استخدام المفتاح الافتراضي المجاني'
                                      : '• All keys are optional for additional features\n'
                                        '• Keys are saved locally on your device\n'
                                        '• You can get free keys from official websites\n'
                                        '• If you don\'t enter a key, the default free key will be used',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              context,
                                              mobile: 14,
                                              tablet: 15,
                                              desktop: 16,
                                            ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.getResponsiveHeight(
                            context,
                            mobile: 24,
                            tablet: 32,
                            desktop: 40,
                          ),
                        ),

                        // GPTGod API Key (اختياري)
                        _buildApiKeyField(
                          controller: _gptgodController,
                          title: 'GPTGod API Key',
                          subtitle: 'اختياري - لنماذج GPT-3.5',
                          icon: Icons.psychology,
                          isRequired: false,
                          helpUrl: 'https://gptgod.site',
                        ),

                        const SizedBox(height: 16),

                        // Tavily API Key (اختياري)
                        _buildApiKeyField(
                          controller: _tavilyController,
                          title: 'Tavily API Key',
                          subtitle: 'اختياري - للبحث على الإنترنت',
                          icon: Icons.search,
                          isRequired: false,
                          helpUrl: 'https://tavily.com',
                        ),

                        const SizedBox(height: 16),


                        // OpenRouter API Key (اختياري)
                        _buildApiKeyField(
                          controller: _openrouterController,
                          title: 'OpenRouter API Key',
                          subtitle:
                              'اختياري - لنماذج متعددة (GPT-4, Claude, Gemini)',
                          icon: Icons.router,
                          isRequired: false,
                          helpUrl: 'https://openrouter.ai/keys',
                        ),

                        // أزرار الحفظ وعرض النماذج
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: ResponsiveHelper.getResponsiveHeight(
                                  context,
                                  mobile: 48,
                                  tablet: 56,
                                  desktop: 64,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _saveKeys,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: _isLoading
                                      ? Text(
                                          Localizations.localeOf(context).languageCode == 'ar'
                                              ? 'جاري الحفظ...'
                                              : 'Saving...'
                                        )
                                      : Text(
                                          Localizations.localeOf(context).languageCode == 'ar'
                                              ? 'حفظ المفاتيح'
                                              : 'Save Keys',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveHelper.getResponsiveFontSize(
                                                  context,
                                                  mobile: 16,
                                                  tablet: 18,
                                                  desktop: 20,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.getResponsiveWidth(
                                context,
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveHeight(
                                context,
                                mobile: 48,
                                tablet: 56,
                                desktop: 64,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _showModelsInfoDialog(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.psychology),
                                label: Text(
                                  Localizations.localeOf(context).languageCode == 'ar' ? 'النماذج المتوفرة:' : 'Available Models:',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 14,
                                          tablet: 16,
                                          desktop: 18,
                                        ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeyField({
    required TextEditingController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isRequired,
    required String helpUrl,
  }) {
    // تحديد اسم الخدمة من العنوان
    String serviceName = '';
    if (title.contains('GPTGod')) {
      serviceName = 'gptgod';
    } else if (title.contains('Tavily')) {
      serviceName = 'tavily';
    } else if (title.contains('OpenRouter')) {
      serviceName = 'openrouter';
    }

    final freeModels = ApiKeyManager.getFreeModels(serviceName);

    return Card(
      elevation: 2,
      child: Padding(
        padding: ResponsiveHelper.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // مؤشر حالة المفتاح (ضوء أخضر/أحمر)
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(serviceName),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor(serviceName).withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 4),
                            const Text(
                              '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showHelpDialog(title, helpUrl),
                  icon: Icon(
                    Icons.help_outline,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                  ),
                  tooltip: 'مساعدة',
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr, // إجبار الاتجاه من اليسار لليمين للمفاتيح
              child: TextField(
                controller: controller,
                obscureText: _obscureKeys,
                textDirection: TextDirection.ltr, // التأكد من كتابة المفتاح من اليسار لليمين
                decoration: InputDecoration(
                  hintText: controller.text.isEmpty
                      ? 'اترك فارغاً لاستخدام المفتاح الافتراضي المجاني'
                      : 'أدخل $title هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: controller.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => controller.clear(),
                              icon: const Icon(Icons.clear),
                              tooltip: 'مسح الحقل',
                            ),
                            IconButton(
                              onPressed: () => _showClearSpecificKeyDialog(title),
                              icon: const Icon(Icons.delete_forever),
                              tooltip: 'مسح المفتاح من التخزين',
                            ),
                          ],
                        )
                      : null,
                  contentPadding: ResponsiveHelper.getResponsivePadding(
                    context,
                    mobile: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    tablet: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    desktop: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            
            // زر التحقق من صلاحية المفتاح (لا يظهر للـ LocalAI)
            if (serviceName != 'localai' && serviceName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isValidating[serviceName] == true 
                          ? null 
                          : () {
                              // تنبيه المستخدم قبل الاختبار
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    Localizations.localeOf(context).languageCode == 'ar'
                                        ? 'تحقق من صلاحية المفتاح'
                                        : 'Verify API Key'
                                  ),
                                  content: Text(
                                    Localizations.localeOf(context).languageCode == 'ar'
                                        ? 'سيتم القيام بمكالمة تجريبية إلى $title للتحقق من صلاحية المفتاح. هل تريد المتابعة؟'
                                        : 'A test call will be made to $title to verify the API key. Do you want to continue?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        Localizations.localeOf(context).languageCode == 'ar'
                                            ? 'إلغاء'
                                            : 'Cancel'
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        // حفظ المفتاح أولاً قبل الفحص
                                        await _saveCurrentKey(serviceName, controller);
                                        _validateApiKey(serviceName);
                                      },
                                      child: Text(
                                        Localizations.localeOf(context).languageCode == 'ar'
                                            ? 'تحقق'
                                            : 'Verify'
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                      icon: _isValidating[serviceName] == true
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_getValidationIcon(serviceName)),
                      label: Text(_getValidationText(serviceName)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getValidationButtonColor(serviceName),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // زر الديباق - يظهر دائماً
                  IconButton(
                    onPressed: _debugInfo[serviceName]?.isNotEmpty == true
                        ? () {
                            setState(() {
                              _showDebugInfo[serviceName] = !(_showDebugInfo[serviceName] ?? false);
                            });
                          }
                        : null, // معطل إذا لم تكن هناك معلومات ديباق
                    icon: Icon(
                      _showDebugInfo[serviceName] == true 
                          ? Icons.keyboard_arrow_up 
                          : Icons.bug_report,
                      color: _debugInfo[serviceName]?.isNotEmpty == true 
                          ? Colors.grey[600] 
                          : Colors.grey[400],
                    ),
                    tooltip: _debugInfo[serviceName]?.isNotEmpty == true
                        ? 'ديباق - عرض تفاصيل الاستدعاء'
                        : 'ديباق - قم بفحص المفتاح أولاً',
                    style: IconButton.styleFrom(
                      backgroundColor: _debugInfo[serviceName]?.isNotEmpty == true 
                          ? Colors.grey[100] 
                          : Colors.grey[50],
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
            
            // عرض تفاصيل الديباق
            if (_showDebugInfo[serviceName] == true && _debugInfo[serviceName]?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'تفاصيل الديباق',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildDebugSection('📤 الطلب (Request)', _debugInfo[serviceName]!['request']),
                    const SizedBox(height: 8),
                    _buildDebugSection('📥 الاستجابة (Response)', _debugInfo[serviceName]!['response']),
                    const SizedBox(height: 8),
                    Text(
                      '⏰ الوقت: ${_debugInfo[serviceName]!['timestamp']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
            
            // عرض النماذج المجانية إذا كانت متوفرة
            if (freeModels.isNotEmpty) ...[
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              Container(
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(12),
                  tablet: const EdgeInsets.all(16),
                  desktop: const EdgeInsets.all(20),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.free_breakfast,
                          color: Colors.green,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 6,
                            tablet: 8,
                            desktop: 10,
                          ),
                        ),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar' ? 'النماذج المجانية المتوفرة:' : 'Available Free Models:',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Wrap(
                      spacing: ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: 4,
                        tablet: 6,
                        desktop: 8,
                      ),
                      runSpacing: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 4,
                        tablet: 6,
                        desktop: 8,
                      ),
                      children: freeModels
                          .take(6)
                          .map(
                            (model) => Tooltip(
                              message: _buildModelTooltip(model),
                              preferBelow: false,
                              child: Container(
                                padding: ResponsiveHelper.getResponsivePadding(
                                  context,
                                  mobile: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  tablet: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  desktop: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  model['name'] ?? model['id'],
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 10,
                                          tablet: 12,
                                          desktop: 14,
                                        ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (freeModels.length > 6)
                      Padding(
                        padding: ResponsiveHelper.getResponsivePadding(
                          context,
                          mobile: const EdgeInsets.only(top: 8),
                          tablet: const EdgeInsets.only(top: 12),
                          desktop: const EdgeInsets.only(top: 16),
                        ),
                        child: Text(
                          'و ${freeModels.length - 6} نموذج آخر...',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(String title, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: ResponsiveHelper.getResponsiveConstraints(
            context,
            mobile: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.9,
              maxHeight: MediaQuery.sizeOf(context).height * 0.6,
            ),
            tablet: const BoxConstraints(maxWidth: 500, maxHeight: 400),
            desktop: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          ),
          child: Padding(
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(16),
              tablet: const EdgeInsets.all(24),
              desktop: const EdgeInsets.all(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيفية الحصول على $title',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Text(
                  'للحصول على $title:',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Text(
                  '1. اذهب إلى: $url',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                Text(
                  '2. أنشئ حساب مجاني',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                Text(
                  '3. انسخ مفتاح API',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                Text(
                  '4. الصقه هنا',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'فهمت',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // عرض dialog معلومات النماذج
  void _showModelsInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => const ModelsInfoDialog(),
    );
  }

  // بناء tooltip للنموذج
  String _buildModelTooltip(Map<String, dynamic> model) {
    final name = model['name'] ?? model['id'];
    final description = model['description'] ?? '';
    final features = (model['features'] as List<dynamic>?)?.join(', ') ?? '';
    final speed = model['speed'] ?? '';
    final quality = model['quality'] ?? '';
    final context = model['context'] ?? '';

    return '''$name

$description

المميزات: $features
السرعة: $speed
الجودة: $quality
السياق: $context''';
  }

  @override
  void dispose() {
    _gptgodController.dispose();
    _tavilyController.dispose();
    _openrouterController.dispose();
    super.dispose();
  }
}
