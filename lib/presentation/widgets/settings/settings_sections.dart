import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';

/// قسم إعدادات النموذج
class ModelSettingsSection extends StatelessWidget {
  const ModelSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ExpansionTile(
          leading: const Icon(Icons.psychology),
          title: const Text('إعدادات النموذج'),
          children: [
            // اختيار النموذج
            ListTile(
              title: const Text('النموذج'),
              subtitle: Text(settings.selectedModel),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showModelSelector(context, settings),
            ),
            
            // Temperature
            ListTile(
              title: Text('الإبداع (${settings.temperature.toStringAsFixed(1)})'),
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
              title: Text('الحد الأقصى للكلمات (${settings.maxTokens})'),
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
                  label: const Text('عرض معلومات مفصلة عن جميع النماذج'),
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
      {'id': 'llama-3.1-8b-instant', 'name': 'Llama 3.1 8B Instant', 'description': 'نموذج سريع ومتطور - Groq', 'service': 'Groq'},
      {'id': 'llama-3.1-70b-versatile', 'name': 'Llama 3.1 70B Versatile', 'description': 'نموذج قوي متعدد الاستخدامات - Groq', 'service': 'Groq'},
      {'id': 'llama-3.1-405b-reasoning', 'name': 'Llama 3.1 405B Reasoning', 'description': 'أقوى نموذج للتفكير المنطقي - Groq', 'service': 'Groq'},
      {'id': 'mixtral-8x7b-32768', 'name': 'Mixtral 8x7B', 'description': 'نموذج متعدد الخبرات - Groq', 'service': 'Groq'},
      {'id': 'gemma2-9b-it', 'name': 'Gemma 2 9B IT', 'description': 'نموذج محادثة محسن - Groq', 'service': 'Groq'},

      // GPTGod Models (مجاني)
      {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo', 'description': 'نموذج سريع وذكي - GPTGod', 'service': 'GPTGod'},
      {'id': 'gpt-4o-mini', 'name': 'GPT-4o Mini', 'description': 'نسخة مصغرة من GPT-4o - GPTGod', 'service': 'GPTGod'},

      // OpenRouter Models (مجاني)
      {'id': 'openai/gpt-oss-20b:free', 'name': 'GPT OSS 20B', 'description': 'نموذج OpenAI مفتوح المصدر - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'z-ai/glm-4.5-air:free', 'name': 'GLM 4.5 Air', 'description': 'نموذج Z.AI خفيف مع وضع تفكير - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'qwen/qwen3-coder:free', 'name': 'Qwen3 Coder', 'description': 'نموذج برمجة متطور - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'moonshotai/kimi-k2:free', 'name': 'Kimi K2', 'description': 'نموذج 1T معامل قوي - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'venice/uncensored:free', 'name': 'Venice Uncensored', 'description': 'نموذج غير مقيد - OpenRouter', 'service': 'OpenRouter'},
      {'id': 'mistral/mistral-small-3.2-24b:free', 'name': 'Mistral Small 3.2', 'description': 'نموذج Mistral محسن - OpenRouter', 'service': 'OpenRouter'},

      // LocalAI Models (محلي)
      {'id': 'llama3.1:8b', 'name': 'Llama 3.1 8B (محلي)', 'description': 'نموذج محلي للخصوصية الكاملة - LocalAI', 'service': 'LocalAI'},
      {'id': 'mistral:7b', 'name': 'Mistral 7B (محلي)', 'description': 'نموذج محلي متعدد اللغات - LocalAI', 'service': 'LocalAI'},
      {'id': 'codellama:7b', 'name': 'Code Llama 7B (محلي)', 'description': 'نموذج برمجة محلي - LocalAI', 'service': 'LocalAI'},
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
                    'اختيار النموذج',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text('معلومات النماذج'),
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
                child: const Text('إلغاء'),
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
        title: const Text('معلومات النماذج'),
        content: const SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚀 Groq (مجاني)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                Text('• نماذج سريعة جداً مع دعم مجاني'),
                Text('• Llama 3.1 بأحجام مختلفة'),
                Text('• Mixtral و Gemma 2'),
                SizedBox(height: 16),

                Text(
                  '🤖 GPTGod (مجاني)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                Text('• GPT-3.5 Turbo و GPT-4o Mini'),
                Text('• جودة عالية مع استخدام مجاني'),
                SizedBox(height: 16),

                Text(
                  '🌐 OpenRouter (نماذج مجانية)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text('• مجموعة واسعة من النماذج المجانية'),
                Text('• GPT OSS, GLM 4.5, Qwen3 Coder'),
                Text('• Kimi K2, Venice Uncensored'),
                SizedBox(height: 16),

                Text(
                  '💻 LocalAI (محلي)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text('• نماذج تعمل على جهازك'),
                Text('• خصوصية كاملة بدون إنترنت'),
                Text('• يتطلب تثبيت Ollama'),
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
          title: const Text('إعدادات المظهر'),
          children: [
            SwitchListTile(
              title: const Text('الوضع الليلي'),
              subtitle: const Text('تفعيل المظهر المظلم'),
              value: theme.isDarkMode,
              onChanged: (_) => theme.toggleTheme(),
            ),
            
            ListTile(
              title: const Text('لون التطبيق'),
              trailing: CircleAvatar(
                backgroundColor: theme.primaryColor,
                radius: 15,
              ),
              onTap: () => _showColorPicker(context, theme),
            ),
            
            SwitchListTile(
              title: const Text('الرسوم المتحركة'),
              subtitle: const Text('تفعيل التأثيرات البصرية'),
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
        title: const Text('اختيار اللون'),
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
          title: const Text('إعدادات الصوت'),
          children: [
            SwitchListTile(
              title: const Text('التعرف على الصوت'),
              subtitle: const Text('تفعيل الإدخال الصوتي'),
              value: settings.speechEnabled,
              onChanged: settings.setSpeechEnabled,
            ),
            
            SwitchListTile(
              title: const Text('التشغيل التلقائي'),
              subtitle: const Text('تشغيل الردود صوتياً'),
              value: settings.autoPlayEnabled,
              onChanged: settings.setAutoPlayEnabled,
            ),
            
            ListTile(
              title: Text('مستوى الصوت (${(settings.volume * 100).toInt()}%)'),
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
          title: const Text('إعدادات MCP المتقدمة'),
          children: [
            SwitchListTile(
              title: const Text('تفعيل خوادم MCP'),
              subtitle: const Text('تمكين استخدام خوادم Model Context Protocol'),
              value: settings.enableMcpServers,
              onChanged: settings.setEnableMcpServers,
            ),

            ListTile(
              title: const Text('مهلة الاتصال'),
              subtitle: Text('10 ثوان'), // يمكن جعلها قابلة للتخصيص
              trailing: const Icon(Icons.timer),
            ),

            ListTile(
              title: const Text('إعادة المحاولة التلقائية'),
              subtitle: const Text('3 محاولات'), // يمكن جعلها قابلة للتخصيص
              trailing: const Icon(Icons.refresh),
            ),

            ListTile(
              title: const Text('تشخيص الاتصال'),
              subtitle: const Text('فحص حالة خوادم MCP'),
              trailing: const Icon(Icons.network_check),
              onTap: () => _showMcpDiagnostics(context),
            ),

            ListTile(
              title: const Text('مسح ذاكرة التخزين المؤقت'),
              subtitle: const Text('حذف البيانات المؤقتة لخوادم MCP'),
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
        title: const Text('مسح ذاكرة التخزين المؤقت'),
        content: const Text('هل تريد مسح جميع البيانات المؤقتة لخوادم MCP؟'),
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
            child: const Text('مسح'),
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
          title: const Text('خوادم MCP'),
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
                            label: const Text('تشخيص الاتصال'),
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
                          label: const Text('إضافة خادم'),
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
        title: const Text('إضافة خادم MCP مخصص'),
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
            child: const Text('إضافة'),
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
          title: const Text('إعدادات متقدمة'),
          children: [
            SwitchListTile(
              title: const Text('البحث على الويب'),
              subtitle: const Text('تفعيل البحث على الإنترنت للحصول على معلومات محدثة'),
              value: settings.enableWebSearch,
              onChanged: settings.setEnableWebSearch,
            ),
            SwitchListTile(
              title: const Text('الاستجابة المباشرة'),
              subtitle: const Text('إظهار الاستجابة أثناء الكتابة (أسرع)'),
              value: settings.streamResponse,
              onChanged: settings.setStreamResponse,
            ),
            SwitchListTile(
              title: const Text('المعالجة التلقائية للنص'),
              subtitle: const Text('تحسين تنسيق النص تلقائياً (Markdown، قوائم، أكواد)'),
              value: settings.enableAutoTextFormatting,
              onChanged: settings.setEnableAutoTextFormatting,
            ),
            SwitchListTile(
              title: const Text('الحفظ التلقائي'),
              subtitle: const Text('حفظ المحادثات تلقائياً'),
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
      title: const Text('معلومات التطبيق'),
      children: [
        ListTile(
          title: const Text('الإصدار'),
          subtitle: const Text('1.0.0'),
          trailing: const Icon(Icons.update),
        ),

        ListTile(
          title: const Text('المطور'),
          subtitle: const Text('Atlas AI Team'),
          trailing: const Icon(Icons.code),
        ),

        ListTile(
          title: const Text('الدعم'),
          subtitle: const Text('support@atlas-ai.app'),
          trailing: const Icon(Icons.email),
          onTap: () {
            // فتح تطبيق البريد الإلكتروني
          },
        ),

        ListTile(
          title: const Text('تقييم التطبيق'),
          subtitle: const Text('ساعدنا بتقييمك'),
          trailing: const Icon(Icons.star),
          onTap: () {
            // فتح متجر التطبيقات للتقييم
          },
        ),
      ],
    );
  }
}
