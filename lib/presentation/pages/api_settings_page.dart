import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/unified_ai_service.dart';
import '../../core/services/tavily_service.dart';
import '../../core/services/api_key_manager.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/models_info_dialog.dart';

class ApiSettingsPage extends StatefulWidget {
  const ApiSettingsPage({super.key});

  @override
  State<ApiSettingsPage> createState() => _ApiSettingsPageState();
}

class _ApiSettingsPageState extends State<ApiSettingsPage> {
  final _groqController = TextEditingController();
  final _gptgodController = TextEditingController();
  final _tavilyController = TextEditingController();
  final _huggingfaceController = TextEditingController();
  final _openrouterController = TextEditingController();

  bool _isLoading = false;
  bool _obscureKeys = true;

  // حالة المفاتيح
  bool hasRequiredKeys = false;
  bool hasAnyKeys = false;
  bool isUsingDefaultKeys = false;
  Map<String, Map<String, dynamic>> serviceInfo = {};

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
        // تحديث حالة المفاتيح
        this.hasRequiredKeys = hasRequiredKeys;
        this.hasAnyKeys = hasAnyKeys;
        this.isUsingDefaultKeys = isUsingDefaultKeys;
      });
    }
  }

  Future<void> _loadSavedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _groqController.text = prefs.getString('groq_api_key') ?? '';
      _gptgodController.text = prefs.getString('gptgod_api_key') ?? '';
      _tavilyController.text = prefs.getString('tavily_api_key') ?? '';
      _huggingfaceController.text =
          prefs.getString('huggingface_api_key') ?? '';
      _openrouterController.text = prefs.getString('openrouter_api_key') ?? '';
    });

    // تحديث حالة المفاتيح
    await _updateKeysStatus();
  }

  Future<void> _saveKeys() async {
    setState(() => _isLoading = true);

    try {
      // حفظ المفاتيح باستخدام ApiKeyManager
      if (_groqController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey('groq', _groqController.text.trim());
      }
      if (_gptgodController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey('gptgod', _gptgodController.text.trim());
      }
      if (_tavilyController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey('tavily', _tavilyController.text.trim());
      }
      if (_huggingfaceController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey(
          'huggingface',
          _huggingfaceController.text.trim(),
        );
      }
      if (_openrouterController.text.trim().isNotEmpty) {
        await ApiKeyManager.saveApiKey(
          'openrouter',
          _openrouterController.text.trim(),
        );
      }

      // إعادة تهيئة الخدمات بالمفاتيح الجديدة
      await _reinitializeServices();

      // تحديث حالة المفاتيح
      await _updateKeysStatus();

      _showSnackBar('تم حفظ المفاتيح بنجاح! ✅', Colors.green);
    } catch (e) {
      _showSnackBar('خطأ في حفظ المفاتيح: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reinitializeServices() async {
    try {
      // الحصول على المفاتيح الحالية (مستخدمة أو افتراضية)
      final groqKey = await ApiKeyManager.getApiKey('groq');
      final gptgodKey = await ApiKeyManager.getApiKey('gptgod');
      final tavilyKey = await ApiKeyManager.getApiKey('tavily');
      final huggingfaceKey = await ApiKeyManager.getApiKey('huggingface');
      final openrouterKey = await ApiKeyManager.getApiKey('openrouter');

      // إعادة تهيئة خدمات API بالمفاتيح الجديدة
      final aiService = UnifiedAIService();
      await aiService.initialize();

      if (tavilyKey.isNotEmpty) {
        TavilyService().updateApiKey(tavilyKey);
      }
    } catch (e) {
      print('[SERVICE REINITIALIZATION ERROR] $e');
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
                    'حالة مفاتيح API',
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
                                    ? 'التطبيق جاهز للعمل ✅'
                                    : 'مفتاح Groq مطلوب ⚠️',
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
                                    'يتم استخدام المفاتيح الافتراضية المجانية',
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
                    'تفاصيل المفاتيح:',
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
                          'إحصائيات:',
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
                          '• المفاتيح المتوفرة: ${keysStatus.values.where((status) => status['hasKey'] == true).length}/5',
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
                          '• المفاتيح المطلوبة: ${hasRequiredKeys ? "متوفرة" : "مفقودة"}',
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
                          '• استخدام المفاتيح الافتراضية: ${isUsingDefaultKeys ? "نعم" : "لا"}',
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
                  'إغلاق',
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
                    'مطلوب',
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
                    'مفتاح افتراضي',
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
                  'مسح مفاتيح API',
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
                'هل تريد مسح مفاتيح API المحفوظة؟',
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
                          'تحذير',
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
                      '• سيتم مسح جميع المفاتيح المحفوظة\n'
                      '• سيتم استخدام المفاتيح الافتراضية المجانية\n'
                      '• يمكنك إعادة إدخال مفاتيحك الخاصة لاحقاً\n'
                      '• لا يمكن التراجع عن هذا الإجراء',
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
                'إلغاء',
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
                'مسح الكل',
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
  Future<void> _clearAllKeys() async {
    try {
      await ApiKeyManager.clearAllApiKeys();

      // مسح الحقول
      setState(() {
        _groqController.clear();
        _gptgodController.clear();
        _tavilyController.clear();
        _huggingfaceController.clear();
        _openrouterController.clear();
      });

      // تحديث حالة المفاتيح
      await _updateKeysStatus();

      _showSnackBar(
        'تم مسح جميع مفاتيح API بنجاح! ✅\nسيتم استخدام المفاتيح الافتراضية المجانية',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('خطأ في مسح المفاتيح: $e', Colors.red);
    }
  }

  // عرض dialog مسح مفتاح محدد
  void _showClearSpecificKeyDialog(String keyTitle) {
    String keyName = '';
    TextEditingController? controller;

    // تحديد اسم المفتاح والـ controller المناسب
    switch (keyTitle) {
      case 'Groq API Key':
        keyName = 'groq';
        controller = _groqController;
        break;
      case 'GPTGod API Key':
        keyName = 'gptgod';
        controller = _gptgodController;
        break;
      case 'Tavily API Key':
        keyName = 'tavily';
        controller = _tavilyController;
        break;
      case 'Hugging Face API Key':
        keyName = 'huggingface';
        controller = _huggingfaceController;
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
                      keyName == 'groq'
                          ? '• مفتاح Groq مطلوب للعمل الأساسي\n• سيتم استخدام المفتاح الافتراضي المجاني\n• يمكنك إعادة إدخال مفتاحك الخاص لاحقاً'
                          : '• سيتم مسح المفتاح من التخزين\n• سيتم استخدام المفتاح الافتراضي المجاني\n• يمكنك إعادة إدخاله لاحقاً',
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
                'إلغاء',
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
      _showSnackBar('خطأ في مسح المفتاح: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات API'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => setState(() => _obscureKeys = !_obscureKeys),
              icon: Icon(
                _obscureKeys ? Icons.visibility : Icons.visibility_off,
              ),
              tooltip: _obscureKeys ? 'إظهار المفاتيح' : 'إخفاء المفاتيح',
            ),
            IconButton(
              onPressed: _showKeysStatusDialog,
              icon: const Icon(Icons.info_outline),
              tooltip: 'حالة المفاتيح',
            ),
            IconButton(
              onPressed: _showClearKeysDialog,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'مسح المفاتيح',
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
                                      'معلومات مهمة',
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
                                  '• مفتاح Groq مطلوب للعمل الأساسي\n'
                                  '• مفاتيح أخرى اختيارية للمزيد من الميزات\n'
                                  '• يتم حفظ المفاتيح محلياً على جهازك\n'
                                  '• يمكنك الحصول على مفاتيح مجانية من المواقع الرسمية\n'
                                  '• إذا لم تدخل مفتاحاً، سيتم استخدام المفتاح الافتراضي المجاني',
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
                        ), // Groq API Key (مطلوب)
                        _buildApiKeyField(
                          controller: _groqController,
                          title: 'Groq API Key',
                          subtitle: 'مطلوب - للنماذج الأساسية',
                          icon: Icons.smart_toy,
                          isRequired: true,
                          helpUrl: 'https://console.groq.com/keys',
                        ),

                        const SizedBox(height: 16),

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

                        // Hugging Face API Key (اختياري)
                        _buildApiKeyField(
                          controller: _huggingfaceController,
                          title: 'Hugging Face API Key',
                          subtitle: 'اختياري - لنماذج Hugging Face',
                          icon: Icons.psychology,
                          isRequired: false,
                          helpUrl: 'https://huggingface.co/settings/tokens',
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
                                      ? const Text('جاري الحفظ...')
                                      : Text(
                                          'حفظ المفاتيح',
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
                                  'النماذج المتاحة',
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
    if (title.contains('Groq')) {
      serviceName = 'groq';
    } else if (title.contains('GPTGod')) {
      serviceName = 'gptgod';
    } else if (title.contains('Tavily')) {
      serviceName = 'tavily';
    } else if (title.contains('Hugging Face')) {
      serviceName = 'huggingface';
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
            TextField(
              controller: controller,
              obscureText: _obscureKeys,
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
                          'النماذج المجانية المتوفرة:',
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
    _groqController.dispose();
    _gptgodController.dispose();
    _tavilyController.dispose();
    _huggingfaceController.dispose();
    _openrouterController.dispose();
    super.dispose();
  }
}
