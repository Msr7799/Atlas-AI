import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../generated/l10n/app_localizations.dart';

/// قسم إعدادات النموذج
class ModelSettingsSection extends StatelessWidget {
  const ModelSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ExpansionTile(
          leading: const Icon(Icons.psychology),
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات النموذج' : 'Model Settings'),
          children: [
            // اختيار النموذج
            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'النموذج' : 'Model'),
              subtitle: Text(settings.selectedModel),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showModelSelector(context, settings),
            ),
            
            // Temperature
            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الإبداع (${settings.temperature.toStringAsFixed(1)})' : 'Creativity (${settings.temperature.toStringAsFixed(1)})'),
              subtitle: Slider(
                value: settings.temperature,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                onChanged: settings.setTemperature,
              ),
            ),
            
            // Max Tokens
            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الحد الأقصى للكلمات (${settings.maxTokens})' : 'Max Tokens (${settings.maxTokens})'),
              subtitle: Slider(
                value: settings.maxTokens.toDouble(),
                min: 256,
                max: 8192,
                divisions: 31,
                onChanged: (value) => settings.setMaxTokens(value.toInt()),
              ),
            ),

            // زر معلومات النماذج
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showModelsInfoDialog(context),
                  icon: const Icon(Icons.info_outline),
                  label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'عرض معلومات مفصلة عن جميع النماذج' : 'View detailed information about all models'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showModelSelector(BuildContext context, SettingsProvider settings) {
    final availableModels = [
      // Groq Models (مجاني)
      {'id': 'llama-3.1-8b-instant', 'name': 'Llama 3.1 8B Instant', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج سريع ومتطور - Groq' : 'Fast and advanced model - Groq', 'service': 'Groq'},
      {'id': 'llama-3.1-70b-versatile', 'name': 'Llama 3.1 70B Versatile', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج قوي متعدد الاستخدامات - Groq' : 'Powerful versatile model - Groq', 'service': 'Groq'},
      {'id': 'llama-3.1-405b-reasoning', 'name': 'Llama 3.1 405B Reasoning', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'أقوى نموذج للتفكير المنطقي - Groq' : 'Most powerful reasoning model - Groq', 'service': 'Groq'},
      {'id': 'mixtral-8x7b-32768', 'name': 'Mixtral 8x7B', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج متعدد الخبرات - Groq' : 'Multi-expert model - Groq', 'service': 'Groq'},
      {'id': 'gemma2-9b-it', 'name': 'Gemma 2 9B IT', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج محادثة محسن - Groq' : 'Enhanced conversation model - Groq', 'service': 'Groq'},

      // GPTGod Models (مجاني)
      {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج سريع وذكي - GPTGod' : 'Fast and smart model - GPTGod', 'service': 'GPTGod'},
      {'id': 'gpt-4o-mini', 'name': 'GPT-4o Mini', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نسخة مصغرة من GPT-4o - GPTGod' : 'Compact version of GPT-4o - GPTGod', 'service': 'GPTGod'},

      // OpenRouter Models (مجاني)
      {'id': 'openai/gpt-oss-20b:free', 'name': 'GPT OSS 20B', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج OpenAI مفتوح المصدر - OpenRouter' : 'OpenAI open source model - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'z-ai/glm-4.5-air:free', 'name': 'GLM 4.5 Air', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج Z.AI خفيف مع وضع تفكير - OpenRouter' : 'Z.AI lightweight model with thinking mode - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'qwen/qwen3-coder:free', 'name': 'Qwen3 Coder', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج برمجة متطور - OpenRouter' : 'Advanced coding model - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'moonshotai/kimi-k2:free', 'name': 'Kimi K2', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج 1T معامل قوي - OpenRouter' : '1T parameter powerful model - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'venice/uncensored:free', 'name': 'Venice Uncensored', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج غير مقيد - OpenRouter' : 'Unrestricted model - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'mistral/mistral-small-3.2-24b:free', 'name': 'Mistral Small 3.2', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج Mistral محسن - OpenRouter' : 'Enhanced Mistral model - OpenRouter', 'service': 'OpenRouter'},

      // LocalAI Models (محلي)
      {'id': 'llama3.1:8b', 'name': Localizations.localeOf(context).languageCode == 'ar' ? 'Llama 3.1 8B (محلي)' : 'Llama 3.1 8B (Local)', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج محلي للخصوصية الكاملة - LocalAI' : 'Local model for complete privacy - LocalAI', 'service': 'LocalAI'},
      {'id': 'mistral:7b', 'name': Localizations.localeOf(context).languageCode == 'ar' ? 'Mistral 7B (محلي)' : 'Mistral 7B (Local)', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج محلي متعدد اللغات - LocalAI' : 'Local multilingual model - LocalAI', 'service': 'LocalAI'},
      {'id': 'codellama:7b', 'name': Localizations.localeOf(context).languageCode == 'ar' ? 'Code Llama 7B (محلي)' : 'Code Llama 7B (Local)', 'description': Localizations.localeOf(context).languageCode == 'ar' ? 'نموذج برمجة محلي - LocalAI' : 'Local coding model - LocalAI', 'service': 'LocalAI'},
    ];

    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final dialogWidth = constraints.maxWidth < 400 ? constraints.maxWidth * 0.95 : 400.0;
          final dialogHeight = constraints.maxHeight < 600 ? constraints.maxHeight * 0.7 : 400.0;
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'اختيار النموذج' : 'Select Model',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'معلومات النماذج' : 'Model Info'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showModelsInfoDialog(context);
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableModels.length,
                itemBuilder: (context, index) {
                  final model = availableModels[index];
                  final isSelected = model['id'] == settings.selectedModel;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                    child: RadioListTile<String>(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              model['name'] ?? '',
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: dialogWidth < 350 ? 12 : 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getServiceColor(model['service'] ?? ''),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              model['service'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        model['description'] ?? '',
                        style: TextStyle(fontSize: dialogWidth < 350 ? 10 : 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: model['id'] ?? '',
                      groupValue: settings.selectedModel,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setSelectedModel(value);
                          Navigator.pop(context);
                        }
                      },
                      activeColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getServiceColor(String service) {
    switch (service) {
      case 'Groq':
        return Colors.orange;
      case 'GPTGod':
        return Colors.purple;
      case 'OpenRouter':
        return Colors.blue;
      case 'LocalAI':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showModelsInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'معلومات النماذج' : 'Model Information'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? '🚀 Groq (مجاني)' : '🚀 Groq (Free)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• نماذج سريعة جداً مع دعم مجاني' : '• Very fast models with free support'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• Llama 3.1 بأحجام مختلفة' : '• Llama 3.1 in different sizes'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• Mixtral و Gemma 2' : '• Mixtral and Gemma 2'),
                const SizedBox(height: 16),

                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? '🤖 GPTGod (مجاني)' : '🤖 GPTGod (Free)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• GPT-3.5 Turbo و GPT-4o Mini' : '• GPT-3.5 Turbo and GPT-4o Mini'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• جودة عالية مع استخدام مجاني' : '• High quality with free usage'),
                const SizedBox(height: 16),

                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? '🌐 OpenRouter (نماذج مجانية)' : '🌐 OpenRouter (Free Models)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• مجموعة واسعة من النماذج المجانية' : '• Wide range of free models'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• GPT OSS, GLM 4.5, Qwen3 Coder' : '• GPT OSS, GLM 4.5, Qwen3 Coder'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• Kimi K2, Venice Uncensored' : '• Kimi K2, Venice Uncensored'),
                const SizedBox(height: 16),

                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? '💻 LocalAI (محلي)' : '💻 LocalAI (Local)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• نماذج تعمل على جهازك' : '• Models running on your device'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• خصوصية كاملة بدون إنترنت' : '• Complete privacy without internet'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• يتطلب تثبيت Ollama' : '• Requires Ollama installation'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

/// قسم إعدادات المظهر
class ThemeSettingsSection extends StatelessWidget {
  const ThemeSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return ExpansionTile(
          leading: const Icon(Icons.palette),
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات المظهر' : 'Appearance Settings'),
          children: [
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الوضع الليلي' : 'Dark Mode'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تفعيل المظهر المظلم' : 'Enable dark theme'),
              value: theme.isDarkMode,
              onChanged: (_) => theme.toggleTheme(),
            ),
            
            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'لون التطبيق' : 'App Color'),
              trailing: CircleAvatar(
                backgroundColor: theme.primaryColor,
                radius: 15,
              ),
              onTap: () => _showColorPicker(context, theme),
            ),
            
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الرسوم المتحركة' : 'Animations'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تفعيل التأثيرات البصرية' : 'Enable visual effects'),
              value: theme.animationsEnabled,
              onChanged: theme.setAnimationsEnabled,
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider theme) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'اختيار اللون' : 'Choose Color'),
        content: Wrap(
          spacing: 10,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                theme.setPrimaryColor(color);
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: theme.primaryColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// قسم إعدادات الصوت
class AudioSettingsSection extends StatelessWidget {
  const AudioSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ExpansionTile(
          leading: const Icon(Icons.mic),
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات الصوت' : 'Audio Settings'),
          children: [
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'التعرف على الصوت' : 'Speech Recognition'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تفعيل الإدخال الصوتي' : 'Enable voice input'),
              value: settings.speechEnabled,
              onChanged: settings.setSpeechEnabled,
            ),
            
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'التشغيل التلقائي' : 'Auto Play'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تشغيل الردود صوتياً' : 'Play responses audibly'),
              value: settings.autoPlayEnabled,
              onChanged: settings.setAutoPlayEnabled,
            ),
            
            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مستوى الصوت (${(settings.volume * 100).toInt()}%)' : 'Volume Level (${(settings.volume * 100).toInt()}%)'),
              subtitle: Slider(
                value: settings.volume,
                min: 0.0,
                max: 1.0,
                onChanged: settings.setVolume,
              ),
            ),
          ],
        );
      },
    );
  }
}



/// قسم إعدادات MCP المتقدمة
class McpAdvancedSettingsSection extends StatelessWidget {
  const McpAdvancedSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ExpansionTile(
          leading: const Icon(Icons.hub),
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات MCP المتقدمة' : 'Advanced MCP Settings'),
          children: [
            SwitchListTile(
              title: const Text('تفعيل خوادم MCP'),
              subtitle: const Text('تمكين استخدام خوادم Model Context Protocol'),
              value: settings.enableMcpServers,
              onChanged: settings.setEnableMcpServers,
            ),

            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مهلة الاتصال' : 'Connection Timeout'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? '10 ثوان' : '10 seconds'),
              trailing: const Icon(Icons.timer),
            ),

            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة المحاولة التلقائية' : 'Auto Retry'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? '3 محاولات' : '3 attempts'),
              trailing: const Icon(Icons.refresh),
            ),

            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تشخيص الاتصال' : 'Connection Diagnostics'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'فحص حالة خوادم MCP' : 'Check MCP server status'),
              trailing: const Icon(Icons.network_check),
              onTap: () => _showMcpDiagnostics(context),
            ),

            ListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مسح ذاكرة التخزين المؤقت' : 'Clear Cache'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حذف البيانات المؤقتة لخوادم MCP' : 'Delete MCP server temporary data'),
              trailing: const Icon(Icons.clear_all),
              onTap: () => _clearMcpCache(context),
            ),
          ],
        );
      },
    );
  }

  void _showMcpDiagnostics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تشخيص خوادم MCP'),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.memory, color: Colors.green),
                title: Text('خادم الذاكرة'),
                subtitle: Text('متصل ويعمل بشكل طبيعي'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.psychology, color: Colors.green),
                title: Text('خادم التفكير التسلسلي'),
                subtitle: Text('متصل ويعمل بشكل طبيعي'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.extension, color: Colors.orange),
                title: Text('الخوادم المخصصة'),
                subtitle: Text('لا توجد خوادم مخصصة'),
                trailing: Icon(Icons.info, color: Colors.orange),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _clearMcpCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مسح ذاكرة التخزين المؤقت' : 'Clear Cache'),
        content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'هل تريد مسح جميع البيانات المؤقتة لخوادم MCP؟' : 'Do you want to clear all temporary data for MCP servers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح ذاكرة التخزين المؤقت')),
              );
            },
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مسح' : 'Clear'),
          ),
        ],
      ),
    );
  }
}

/// قسم إدارة خوادم MCP
class McpServersSection extends StatelessWidget {
  const McpServersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ExpansionTile(
          leading: const Icon(Icons.hub),
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'خوادم MCP' : 'MCP Servers'),
          children: [
            SwitchListTile(
              title: const Text('تفعيل خوادم MCP'),
              subtitle: const Text('تمكين استخدام خوادم Model Context Protocol'),
              value: settings.enableMcpServers,
              onChanged: settings.setEnableMcpServers,
            ),

            if (settings.enableMcpServers) ...[
              const Divider(),

              // عرض خوادم MCP المتاحة
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الخوادم المتاحة:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...settings.getAvailableMcpServers().map((server) {
                      final isEnabled = settings.mcpServerStatus[server] ?? false;
                      return ListTile(
                        leading: Icon(
                          server.contains('memory') ? Icons.memory :
                          server.contains('thinking') ? Icons.psychology : Icons.extension,
                          color: isEnabled ? Colors.green : Colors.grey,
                        ),
                        title: Text(server),
                        subtitle: Text(_getServerDescription(server)),
                        trailing: Switch(
                          value: isEnabled,
                          onChanged: (value) => settings.setMcpServerStatus(server, value),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showMcpDiagnostics(context),
                            icon: const Icon(Icons.network_check),
                            label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تشخيص الاتصال' : 'Connection Diagnostics'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddCustomServerDialog(context, settings),
                          icon: const Icon(Icons.add),
                          label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خادم' : 'Add Server'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _getServerDescription(String serverName) {
    switch (serverName) {
      case 'memory':
        return 'خادم الذاكرة الذكي لحفظ واسترجاع المعلومات';
      case 'sequential-thinking':
        return 'محرك التفكير التسلسلي للمشاكل المعقدة';
      default:
        return 'خادم MCP مخصص';
    }
  }

  void _showMcpDiagnostics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تشخيص خوادم MCP'),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.memory, color: Colors.green),
                title: Text('خادم الذاكرة'),
                subtitle: Text('متصل ويعمل بشكل طبيعي'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.psychology, color: Colors.green),
                title: Text('خادم التفكير التسلسلي'),
                subtitle: Text('متصل ويعمل بشكل طبيعي'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.extension, color: Colors.orange),
                title: Text('الخوادم المخصصة'),
                subtitle: Text('لا توجد خوادم مخصصة'),
                trailing: Icon(Icons.info, color: Colors.orange),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomServerDialog(BuildContext context, SettingsProvider settings) {
    final nameController = TextEditingController();
    final commandController = TextEditingController();
    final argsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خادم MCP مخصص' : 'Add Custom MCP Server'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الخادم',
                  hintText: 'my-custom-server',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commandController,
                decoration: const InputDecoration(
                  labelText: 'الأمر',
                  hintText: 'npx',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: argsController,
                decoration: const InputDecoration(
                  labelText: 'المعاملات (مفصولة بفواصل)',
                  hintText: '-y, @my/mcp-server',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && commandController.text.isNotEmpty) {
                final args = argsController.text.split(',').map((e) => e.trim()).toList();
                settings.addCustomMcpServer(
                  nameController.text,
                  commandController.text,
                  args,
                  {},
                );
                Navigator.pop(context);
              }
            },
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }
}

/// قسم الإعدادات المتقدمة
class AdvancedSettingsSection extends StatelessWidget {
  const AdvancedSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ExpansionTile(
          leading: const Icon(Icons.tune),
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات متقدمة' : 'Advanced Settings'),
          children: [
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'البحث على الويب' : 'Web Search'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تفعيل البحث على الإنترنت للحصول على معلومات محدثة' : 'Enable internet search for updated information'),
              value: settings.enableWebSearch,
              onChanged: settings.setEnableWebSearch,
            ),
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الاستجابة المباشرة' : 'Stream Response'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إظهار الاستجابة أثناء الكتابة (أسرع)' : 'Show response while typing (faster)'),
              value: settings.streamResponse,
              onChanged: settings.setStreamResponse,
            ),
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'المعالجة التلقائية للنص' : 'Auto Text Formatting'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تحسين تنسيق النص تلقائياً (Markdown، قوائم، أكواد)' : 'Improve text formatting automatically (Markdown, lists, codes)'),
              value: settings.enableAutoTextFormatting,
              onChanged: settings.setEnableAutoTextFormatting,
            ),
            SwitchListTile(
              title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الحفظ التلقائي' : 'Auto Save'),
              subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حفظ المحادثات تلقائياً' : 'Save conversations automatically'),
              value: settings.autoSaveEnabled,
              onChanged: settings.setAutoSaveEnabled,
            ),
          ],
        );
      },
    );
  }
}

/// قسم معلومات التطبيق
class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.info),
      title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'معلومات التطبيق' : 'App Information'),
      children: [
        ListTile(
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الإصدار' : 'Version'),
          subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? '1.0.0' : '1.0.0'),
          trailing: const Icon(Icons.update),
        ),

        ListTile(
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'المطور' : 'Developer'),
          subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'Atlas AI Team' : 'Atlas AI Team'),
          trailing: const Icon(Icons.code),
        ),

        ListTile(
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الدعم' : 'Support'),
          subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'support@atlas-ai.app' : 'support@atlas-ai.app'),
          trailing: const Icon(Icons.email),
          onTap: () {
            // فتح تطبيق البريد الإلكتروني
          },
        ),

        ListTile(
          title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تقييم التطبيق' : 'Rate App'),
          subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'ساعدنا بتقييمك' : 'Help us with your rating'),
          trailing: const Icon(Icons.star),
          onTap: () {
            // فتح متجر التطبيقات للتقييم
          },
        ),
      ],
    );
  }
}
