import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/services/permissions_manager.dart';
import '../../core/utils/network_checker.dart';

class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'لوحة التشخيص',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Consumer2<ChatProvider, SettingsProvider>(
                builder: (context, chatProvider, settingsProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Info
                      _buildSection(context, 'معلومات التطبيق', [
                        'الاسم: ${AppConfig.appName}',
                        'الإصدار: ${AppConfig.version}',
                        'النموذج الافتراضي: ${AppConfig.defaultModel}',
                        'درجة الحرارة: ${AppConfig.defaultTemperature}',
                        'الحد الأقصى للرموز: ${AppConfig.defaultMaxTokens}',
                      ]),

                      const SizedBox(height: 16),

                      // Current Settings
                      _buildSection(context, 'الإعدادات الحالية', [
                        'النموذج: ${settingsProvider.selectedModel}',
                        'درجة الحرارة: ${settingsProvider.temperature}',
                        'الحد الأقصى للرموز: ${settingsProvider.maxTokens}',
                        'الاستجابة المتدفقة: ${settingsProvider.streamResponse ? "مفعل" : "معطل"}',
                        'البحث في الويب: ${settingsProvider.enableWebSearch ? "مفعل" : "معطل"}',
                        'خوادم MCP: ${settingsProvider.enableMcpServers ? "مفعل" : "معطل"}',
                        'المعالجة التلقائية للنص: ${settingsProvider.enableAutoTextFormatting ? "مفعل" : "معطل"}',
                      ]),

                      const SizedBox(height: 16),

                      // Chat Status
                      _buildSection(context, 'حالة المحادثة', [
                        'عدد الرسائل: ${chatProvider.messages.length}',
                        'عدد الجلسات: ${chatProvider.sessions.length}',
                        'عدد المرفقات: ${chatProvider.attachments.length}',
                        'وضع التشخيص: ${chatProvider.debugMode ? "مفعل" : "معطل"}',
                        'يكتب الآن: ${chatProvider.isTyping ? "نعم" : "لا"}',
                        'يفكر الآن: ${chatProvider.isThinking ? "نعم" : "لا"}',
                      ]),
                      const SizedBox(height: 16),
                      _buildSection(context, 'حالة مفاتيح API', [
                        'Groq API: ${AppConfig.groqApiKey.isNotEmpty ? "متوفر" : "غير متوفر"}',
                        'Tavily API: ${AppConfig.tavilyApiKey.isNotEmpty ? "متوفر" : "غير متوفر"}',
                      ]),

                      const SizedBox(height: 16),

                      // Network Diagnostics Section
                      _buildNetworkDiagnosticsSection(context),

                      const SizedBox(height: 16),

                      // Permissions Section
                      _buildPermissionsSection(context),

                      const SizedBox(height: 16),
                      _buildSection(context, 'حالة خوادم MCP', [
                        'خادم الذاكرة: ${settingsProvider.mcpServerStatus["memory"] == true ? "مفعل" : "معطل"}',
                        'التفكير التسلسلي: ${settingsProvider.mcpServerStatus["sequential-thinking"] == true ? "مفعل" : "معطل"}',
                      ]),
                      const SizedBox(height: 16),
                      if (chatProvider.currentThinking != null)
                        _buildSection(context, 'عملية التفكير الحالية', [
                          'عدد الخطوات: ${chatProvider.currentThinking!.steps.length}',
                          'مكتملة: ${chatProvider.currentThinking!.isComplete ? "نعم" : "لا"}',
                          'بدأت في: ${_formatDateTime(chatProvider.currentThinking!.startedAt)}',
                          if (chatProvider.currentThinking!.completedAt != null)
                            'انتهت في: ${_formatDateTime(chatProvider.currentThinking!.completedAt!)}',
                        ]),
                      const SizedBox(height: 16),
                      if (chatProvider.systemPrompt != null)
                        _buildSection(context, 'التعليمات النظام', [
                          chatProvider.systemPrompt!,
                        ]),
                      const SizedBox(height: 16),
                      _buildSection(context, 'استخدام الذاكرة', [
                        'رسائل محفوظة: ${chatProvider.messages.length * 100} bytes تقريباً',
                        'جلسات محفوظة: ${chatProvider.sessions.length * 500} bytes تقريباً',
                      ]),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall,
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildNetworkDiagnosticsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.network_check,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'فحص الشبكة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _runNetworkDiagnostics(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('تشغيل فحص الشبكة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'يتحقق هذا الفحص من الاتصال بالإنترنت والوصول إلى خوادم Groq و Tavily',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'فحص الأذونات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _checkAllPermissions(context),
                    icon: const Icon(Icons.fact_check),
                    label: const Text('فحص الأذونات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _requestAllPermissions(context),
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('طلب الأذونات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'يتحقق من أذونات التخزين، الكاميرا، المايكروفون، والتنبيهات',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runNetworkDiagnostics(BuildContext context) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جار فحص الشبكة...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // تشغيل فحص الشبكة
      final diagnostics = await NetworkChecker.runFullDiagnostics();

      // إغلاق مؤشر التحميل
      if (context.mounted) Navigator.of(context).pop();

      // عرض النتائج
      if (context.mounted) {
        _showNetworkDiagnosticsResults(context, diagnostics);
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (context.mounted) Navigator.of(context).pop();

      // عرض رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تشغيل فحص الشبكة: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _checkAllPermissions(BuildContext context) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جار فحص الأذونات...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final permissionsManager = PermissionsManager();
      final permissions = await permissionsManager.checkAllPermissions();

      // إغلاق مؤشر التحميل
      if (context.mounted) Navigator.of(context).pop();

      // عرض النتائج
      if (context.mounted) {
        _showPermissionsResults(context, permissions, false);
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (context.mounted) Navigator.of(context).pop();

      // عرض رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في فحص الأذونات: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _requestAllPermissions(BuildContext context) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جار طلب الأذونات...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final permissionsManager = PermissionsManager();
      await permissionsManager.checkAndRequestAllPermissions();
      final permissions = await permissionsManager.checkAllPermissions();

      // إغلاق مؤشر التحميل
      if (context.mounted) Navigator.of(context).pop();

      // عرض النتائج
      if (context.mounted) {
        _showPermissionsResults(context, permissions, true);
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (context.mounted) Navigator.of(context).pop();

      // عرض رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في طلب الأذونات: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showNetworkDiagnosticsResults(
    BuildContext context,
    NetworkDiagnostics diagnostics,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    diagnostics.allTestsPassed
                        ? Icons.check_circle
                        : Icons.error,
                    color: diagnostics.allTestsPassed
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'نتائج فحص الشبكة',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),

              // Results
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDiagnosticItem(
                        context,
                        'الاتصال بالإنترنت',
                        diagnostics.hasInternetConnection,
                        diagnostics.hasInternetConnection ? 'متصل' : 'غير متصل',
                      ),
                      _buildDiagnosticItem(
                        context,
                        'DNS لـ Groq',
                        diagnostics.groqDNSResolved,
                        diagnostics.groqDNSResolved ? 'يعمل' : 'فشل',
                      ),
                      _buildDiagnosticItem(
                        context,
                        'DNS لـ Tavily',
                        diagnostics.tavilyDNSResolved,
                        diagnostics.tavilyDNSResolved ? 'يعمل' : 'فشل',
                      ),
                      _buildDiagnosticItem(
                        context,
                        'Groq API',
                        diagnostics.groqApiResult.success,
                        diagnostics.groqApiResult.message,
                      ),
                      _buildDiagnosticItem(
                        context,
                        'Tavily API',
                        diagnostics.tavilyApiResult.success,
                        diagnostics.tavilyApiResult.message,
                      ),

                      if (!diagnostics.allTestsPassed) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'التوصيات لحل المشاكل:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...(_getRecommendations(diagnostics).map(
                          (rec) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(rec)),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionsResults(
    BuildContext context,
    Map<String, PermissionStatus> permissions,
    bool wasRequested,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    wasRequested
                        ? 'نتائج طلب الأذونات'
                        : 'حالة الأذونات الحالية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),

              // Results
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...permissions.entries.map(
                        (entry) => _buildPermissionItem(
                          context,
                          _getPermissionDisplayName(entry.key),
                          entry.value,
                          _getPermissionDescription(entry.key),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Actions
                      if (permissions.values.any(
                        (status) => status.isPermanentlyDenied,
                      )) ...[
                        Text(
                          'بعض الأذونات مرفوضة نهائياً:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => openAppSettings(),
                          icon: const Icon(Icons.settings),
                          label: const Text('فتح إعدادات التطبيق'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يمكنك تفعيل الأذونات يدوياً من إعدادات التطبيق',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticItem(
    BuildContext context,
    String title,
    bool success,
    String message,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: success ? Colors.green : Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    String title,
    PermissionStatus status,
    String description,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case PermissionStatus.granted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'مُمنوح';
        break;
      case PermissionStatus.denied:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'مرفوض';
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'مرفوض نهائياً';
        break;
      case PermissionStatus.restricted:
        statusColor = Colors.grey;
        statusIcon = Icons.lock;
        statusText = 'مقيد';
        break;
      case PermissionStatus.limited:
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        statusText = 'محدود';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'غير معروف';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getRecommendations(NetworkDiagnostics diagnostics) {
    final recommendations = <String>[];

    if (!diagnostics.hasInternetConnection) {
      recommendations.addAll([
        'تحقق من اتصال Wi-Fi أو بيانات الهاتف',
        'جرب التبديل بين Wi-Fi وبيانات الهاتف',
        'أعد تشغيل اتصال الشبكة',
      ]);
    }

    if (diagnostics.hasInternetConnection &&
        (!diagnostics.groqDNSResolved || !diagnostics.tavilyDNSResolved)) {
      recommendations.addAll([
        'جرب استخدام خادم DNS مختلف (8.8.8.8، 1.1.1.1)',
        'تحقق من عدم حجب الشبكة لمواقع معينة',
        'جرب استخدام VPN لتجاوز قيود الشبكة',
      ]);
    }

    if (!diagnostics.groqApiResult.success ||
        !diagnostics.tavilyApiResult.success) {
      recommendations.addAll([
        'تحقق من مفاتيح API في الإعدادات',
        'تأكد من صحة مفاتيح API المستخدمة',
        'جرب إعادة تشغيل التطبيق',
      ]);
    }

    return recommendations;
  }

  String _getPermissionDisplayName(String key) {
    switch (key) {
      case 'storage':
        return 'التخزين';
      case 'camera':
        return 'الكاميرا';
      case 'microphone':
        return 'المايكروفون';
      case 'photos':
        return 'الصور';
      case 'videos':
        return 'الفيديوهات';
      case 'audio':
        return 'الملفات الصوتية';
      case 'notification':
        return 'التنبيهات';
      case 'manageExternalStorage':
        return 'إدارة التخزين الخارجي';
      default:
        return key;
    }
  }

  String _getPermissionDescription(String key) {
    switch (key) {
      case 'storage':
        return 'لحفظ المحادثات والملفات المُصدرة';
      case 'camera':
        return 'لالتقاط الصور ومعالجتها';
      case 'microphone':
        return 'لتسجيل المذكرات الصوتية';
      case 'photos':
        return 'للوصول لمكتبة الصور';
      case 'videos':
        return 'للوصول لمقاطع الفيديو';
      case 'audio':
        return 'للوصول للملفات الصوتية';
      case 'notification':
        return 'لإرسال تنبيهات مفيدة';
      case 'manageExternalStorage':
        return 'لإدارة ملفات التطبيق في التخزين الخارجي';
      default:
        return '';
    }
  }
}
