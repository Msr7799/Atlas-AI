import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../../core/config/app_config.dart';

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
                      _buildSection(
                        context,
                        'معلومات التطبيق',
                        [
                          'الاسم: ${AppConfig.appName}',
                          'الإصدار: ${AppConfig.version}',
                          'النموذج الافتراضي: ${AppConfig.defaultModel}',
                          'درجة الحرارة: ${AppConfig.defaultTemperature}',
                          'الحد الأقصى للرموز: ${AppConfig.defaultMaxTokens}',
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Current Settings
                      _buildSection(
                        context,
                        'الإعدادات الحالية',
                        [
                          'النموذج: ${settingsProvider.selectedModel}',
                          'درجة الحرارة: ${settingsProvider.temperature}',
                          'الحد الأقصى للرموز: ${settingsProvider.maxTokens}',
                          'الاستجابة المتدفقة: ${settingsProvider.streamResponse ? "مفعل" : "معطل"}',
                          'البحث في الويب: ${settingsProvider.enableWebSearch ? "مفعل" : "معطل"}',
                          'خوادم MCP: ${settingsProvider.enableMcpServers ? "مفعل" : "معطل"}',
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Chat Status
                      _buildSection(
                        context,
                        'حالة المحادثة',
                        [
                          'عدد الرسائل: ${chatProvider.messages.length}',
                          'عدد الجلسات: ${chatProvider.sessions.length}',
                          'عدد المرفقات: ${chatProvider.attachments.length}',
                          'وضع التشخيص: ${chatProvider.debugMode ? "مفعل" : "معطل"}',
                          'يكتب الآن: ${chatProvider.isTyping ? "نعم" : "لا"}',
                          'يفكر الآن: ${chatProvider.isThinking ? "نعم" : "لا"}',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'حالة مفاتيح API',
                        [
                          'Groq API: ${AppConfig.groqApiKey.isNotEmpty ? "متوفر" : "غير متوفر"}',
                          'Tavily API: ${AppConfig.tavilyApiKey.isNotEmpty ? "متوفر" : "غير متوفر"}',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'حالة خوادم MCP',
                        [
                          'خادم الذاكرة: ${settingsProvider.mcpServerStatus["memory"] == true ? "مفعل" : "معطل"}',
                          'التفكير التسلسلي: ${settingsProvider.mcpServerStatus["sequential-thinking"] == true ? "مفعل" : "معطل"}',
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (chatProvider.currentThinking != null)
                        _buildSection(
                          context,
                          'عملية التفكير الحالية',
                          [
                            'عدد الخطوات: ${chatProvider.currentThinking!.steps.length}',
                            'مكتملة: ${chatProvider.currentThinking!.isComplete ? "نعم" : "لا"}',
                            'بدأت في: ${_formatDateTime(chatProvider.currentThinking!.startedAt)}',
                            if (chatProvider.currentThinking!.completedAt != null)
                              'انتهت في: ${_formatDateTime(chatProvider.currentThinking!.completedAt!)}',
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (chatProvider.systemPrompt != null)
                        _buildSection(
                          context,
                          'التعليمات النظام',
                          [chatProvider.systemPrompt!],
                        ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'استخدام الذاكرة',
                        [
                          'رسائل محفوظة: ${chatProvider.messages.length * 100} bytes تقريباً',
                          'جلسات محفوظة: ${chatProvider.sessions.length * 500} bytes تقريباً',
                        ],
                      ),
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
            ...items.map((item) => Padding(
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
            )),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
