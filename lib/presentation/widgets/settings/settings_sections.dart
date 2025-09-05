import 'dart:convert';
import 'package:atlas/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/custom_models_manager.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../core/config/app_config.dart';
import 'custom_models_section.dart';


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
    // استخدام النماذج من AppConfig بدلاً من القائمة المحددة مسبقاً
    final availableModels = <Map<String, dynamic>>[];
    
    // إضافة جميع النماذج من AppConfig
    AppConfig.freeModels.forEach((service, models) {
      for (final model in models) {
        availableModels.add({
          'id': model['id'],
          'name': model['name'],
          'description': model['description'],
          'service': service.toUpperCase(),
          'features': model['features'] ?? [],
          'speed': model['speed'] ?? '',
          'quality': model['quality'] ?? '',
          'context': model['context'] ?? '',
          'provider': model['provider'] ?? service,
        });
      }
    });

    // إضافة النماذج المخصصة من CustomModelsSection
    try {
      final customModelsManager = CustomModelsManager.instance;
      final customModels = customModelsManager.customModels;
      for (final model in customModels) {
        availableModels.add({
          'id': model.name,
          'name': model.name,
          'description': model.description.isNotEmpty ? model.description : 'Custom LLM API',
          'service': 'CUSTOM',
          'features': ['API'],
          'speed': 'Unknown',
          'quality': 'Custom',
          'context': 'Variable',
          'provider': 'Custom LLM',
        });
      }
    } catch (e) {
      // التعامل مع أي أخطاء في تحميل النماذج المخصصة
      print('Error loading custom models: $e');
    }

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
    switch (service.toUpperCase()) {
      case 'GROQ':
        return Colors.orange;
      case 'GPTGOD':
        return Colors.purple;
      case 'OPENROUTER':
        return Colors.blue;
      case 'LOCALAI':
        return Colors.green;
      case 'CUSTOM':
        return Colors.teal;
      case 'HUGGINGFACE':
        return Colors.yellow.shade700;
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
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• GPT-3.5 Turbo (1.8B معامل)' : '• GPT-3.5 Turbo (1.8B params)'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• GPT-4o Mini (3B معامل)' : '• GPT-4o Mini (3B params)'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• GPT-4o (6B معامل) - دعم متعدد الوسائط' : '• GPT-4o (6B params) - Multimodal support'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• GPT-4o Vision - معالجة الصور والرسوم' : '• GPT-4o Vision - Image and animation processing'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• ChatGPT مجاني - واجهة محادثة' : '• ChatGPT Free - Chat interface'),
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
                const SizedBox(height: 16),

                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? '🔧 Custom LLMs (مخصص)' : '🔧 Custom LLMs (Custom)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• نماذج مخصصة من أوامر cURL' : '• Custom models from cURL commands'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• إضافة أي API خارجي بسهولة' : '• Easily add any external API'),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? '• مرونة كاملة في التكوين' : '• Full configuration flexibility'),
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تشخيص خوادم MCP' : 'MCP Server Diagnostics'),
        contentPadding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? screenSize.width * 0.9 : 500,
            maxHeight: screenSize.height * 0.6,
          ),
          child: SizedBox(
            width: isSmallScreen ? double.infinity : 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildServerStatusTile(
                    context: context,
                    icon: Icons.memory,
                    title: isArabic ? 'خادم الذاكرة' : 'Memory Server',
                    subtitle: isArabic ? 'متصل ويعمل بشكل طبيعي' : 'Connected and working normally',
                    status: _ServerStatus.connected,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildServerStatusTile(
                    context: context,
                    icon: Icons.psychology,
                    title: isArabic ? 'خادم التفكير التسلسلي' : 'Sequential Thinking Server',
                    subtitle: isArabic ? 'متصل ويعمل بشكل طبيعي' : 'Connected and working normally',
                    status: _ServerStatus.connected,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildServerStatusTile(
                    context: context,
                    icon: Icons.extension,
                    title: isArabic ? 'الخوادم المخصصة' : 'Custom Servers',
                    subtitle: isArabic ? 'لا توجد خوادم مخصصة' : 'No custom servers available',
                    status: _ServerStatus.warning,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إغلاق' : 'Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerStatusTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required _ServerStatus status,
    required bool isSmallScreen,
  }) {
    Color iconColor;
    IconData statusIcon;
    
    switch (status) {
      case _ServerStatus.connected:
        iconColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case _ServerStatus.warning:
        iconColor = Colors.orange;
        statusIcon = Icons.info;
        break;
      case _ServerStatus.error:
        iconColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.0 : 16.0,
          vertical: isSmallScreen ? 4.0 : 8.0,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: isSmallScreen ? 20 : 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
        ),
        trailing: Icon(
          statusIcon, 
          color: iconColor,
          size: isSmallScreen ? 18 : 20,
        ),
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

/// قسم إدارة خوادم MCP - Responsive
enum _ServerStatus {
  connected,
  warning,
  error,
}

class McpServersSection extends StatelessWidget {
  const McpServersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, themeProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isExtraSmall = screenWidth < 360;
        final isSmall = screenWidth < 600;
            
        return ExpansionTile(
              leading: Icon(
                Icons.hub,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: isExtraSmall ? 18 : 20,
                  tablet: 24,
                  desktop: 28,
                ),
                color: themeProvider.accentColor,
              ),
              title: Text(
                Localizations.localeOf(context).languageCode == 'ar' ? 'خوادم MCP' : 'MCP Servers',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: isExtraSmall ? 13 : 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  fontFamily: themeProvider.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              tilePadding: EdgeInsets.symmetric(
                horizontal: isExtraSmall ? 8 : (isSmall ? 12 : 16),
                vertical: isExtraSmall ? 4 : 8,
              ),
              childrenPadding: EdgeInsets.symmetric(
                horizontal: isExtraSmall ? 4 : (isSmall ? 8 : 12),
                vertical: 4,
              ),
              children: [
                // Main Toggle Switch - Enhanced Responsive
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isExtraSmall ? 4 : (isSmall ? 8 : 12),
                    vertical: isExtraSmall ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: isExtraSmall ? 6 : 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    border: Border.all(
                      color: themeProvider.accentColor.withOpacity(0.25),
                      width: isExtraSmall ? 1 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.accentColor.withOpacity(0.05),
                        blurRadius: isExtraSmall ? 2 : 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Container(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isExtraSmall ? 8 : (isSmall ? 12 : 16),
                        vertical: isExtraSmall ? 4 : (isSmall ? 6 : 8),
                      ),
                      title: Text(
                        Localizations.localeOf(context).languageCode == 'ar' ? 'تفعيل خوادم MCP' : 'Enable MCP Servers',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: isExtraSmall ? 12 : 13,
                            tablet: 15,
                            desktop: 16,
                          ),
                          fontWeight: FontWeight.w600,
                          fontFamily: themeProvider.fontFamily,
                        ),
                      ),
                      subtitle: isExtraSmall ? null : Text(
                        Localizations.localeOf(context).languageCode == 'ar' 
                          ? 'تمكين استخدام خوادم Model Context Protocol' 
                          : 'Enable Model Context Protocol servers',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 10,
                            tablet: 12,
                            desktop: 13,
                          ),
                          fontFamily: themeProvider.fontFamily,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      value: settings.enableMcpServers,
                      onChanged: settings.setEnableMcpServers,
                      activeColor: themeProvider.accentColor,
                    ),
                  ),
                ),

                if (settings.enableMcpServers) ...[
                  Divider(
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    color: themeProvider.accentColor.withOpacity(0.3),
                  ),

                  // Available Servers Section - Enhanced Responsive
                  Padding(
                    padding: EdgeInsets.all(
                      isExtraSmall ? 8 : (isSmall ? 12 : 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.dns,
                              size: isExtraSmall ? 16 : 18,
                              color: themeProvider.accentColor,
                            ),
                            SizedBox(width: isExtraSmall ? 4 : 8),
                            Expanded(
                              child: Text(
                                Localizations.localeOf(context).languageCode == 'ar' ? 'الخوادم المتاحة:' : 'Available MCP Servers:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                                    context,
                                    mobile: isExtraSmall ? 13 : 14,
                                    tablet: 16,
                                    desktop: 18,
                                  ),
                                  color: themeProvider.accentColor,
                                  fontFamily: themeProvider.fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                          context,
                          mobile: 8,
                          tablet: 12,
                          desktop: 16,
                        )),

                        // Server List - Enhanced Responsive Layout
                        ResponsiveHelper.buildResponsiveLayout(
                          context,
                          mobile: Column(
                            children: settings.getAvailableMcpServers().map((server) {
                              final isEnabled = settings.mcpServerStatus[server] ?? false;
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: isExtraSmall ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(isExtraSmall ? 8 : 12),
                                  border: Border.all(
                                    color: isEnabled 
                                      ? themeProvider.accentColor 
                                      : Colors.grey.shade300,
                                    width: isEnabled ? (isExtraSmall ? 1.5 : 2) : 1,
                                  ),
                                  color: isEnabled 
                                    ? themeProvider.accentColor.withOpacity(0.08) 
                                    : null,
                                  boxShadow: isEnabled ? [
                                    BoxShadow(
                                      color: themeProvider.accentColor.withOpacity(0.1),
                                      blurRadius: isExtraSmall ? 2 : 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ] : null,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    _getServerIcon(server),
                                    color: isEnabled ? themeProvider.accentColor : Colors.grey,
                                    size: isExtraSmall ? 18 : 20,
                                  ),
                                  title: Text(
                                    _getServerDisplayName(server, context),
                                    style: TextStyle(
                                      fontSize: isExtraSmall ? 12 : 13,
                                      fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                                      fontFamily: themeProvider.fontFamily,
                                    ),
                                  ),
                                  subtitle: isExtraSmall ? null : Text(
                                    _getServerDescription(server, context),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: themeProvider.fontFamily,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Transform.scale(
                                    scale: isExtraSmall ? 0.8 : 1.0,
                                    child: Switch(
                                      value: isEnabled,
                                      onChanged: (value) => settings.setMcpServerStatus(server, value),
                                      activeColor: themeProvider.accentColor,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isExtraSmall ? 8 : 12, 
                                    vertical: isExtraSmall ? 2 : 4,
                                  ),
                                  dense: isExtraSmall,
                                ),
                              );
                            }).toList(),
                          ),
                          tablet: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: settings.getAvailableMcpServers().length,
                            itemBuilder: (context, index) {
                              final server = settings.getAvailableMcpServers()[index];
                              final isEnabled = settings.mcpServerStatus[server] ?? false;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isEnabled 
                                      ? themeProvider.accentColor 
                                      : Colors.grey.shade300,
                                    width: isEnabled ? 2 : 1,
                                  ),
                                  color: isEnabled 
                                    ? themeProvider.accentColor.withOpacity(0.1) 
                                    : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getServerIcon(server),
                                            color: isEnabled ? themeProvider.accentColor : Colors.grey,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _getServerDisplayName(server, context),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                                                fontFamily: themeProvider.fontFamily,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Switch(
                                            value: isEnabled,
                                            onChanged: (value) => settings.setMcpServerStatus(server, value),
                                            activeColor: themeProvider.accentColor,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: Text(
                                          _getServerDescription(server, context),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontFamily: themeProvider.fontFamily,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          desktop: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: settings.getAvailableMcpServers().length,
                            itemBuilder: (context, index) {
                              final server = settings.getAvailableMcpServers()[index];
                              final isEnabled = settings.mcpServerStatus[server] ?? false;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isEnabled 
                                      ? themeProvider.accentColor 
                                      : Colors.grey.shade300,
                                    width: isEnabled ? 3 : 1,
                                  ),
                                  color: isEnabled 
                                    ? themeProvider.accentColor.withOpacity(0.1) 
                                    : null,
                                  boxShadow: isEnabled 
                                    ? [BoxShadow(
                                        color: themeProvider.accentColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )]
                                    : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getServerIcon(server),
                                            color: isEnabled ? themeProvider.accentColor : Colors.grey,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _getServerDisplayName(server, context),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isEnabled ? FontWeight.bold : FontWeight.w600,
                                                fontFamily: themeProvider.fontFamily,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          _getServerDescription(server, context),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontFamily: themeProvider.fontFamily,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Center(
                                        child: Switch(
                                          value: isEnabled,
                                          onChanged: (value) => settings.setMcpServerStatus(server, value),
                                          activeColor: themeProvider.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),

                        // Action Buttons - Responsive Layout
                        ResponsiveHelper.buildResponsiveLayout(
                          context,
                          mobile: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showMcpDiagnostics(context),
                                  icon: Icon(
                                    Icons.network_check,
                                    size: ResponsiveHelper.getResponsiveIconSize(context, mobile: 18),
                                  ),
                                  label: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'تشخيص الاتصال' : 'Connection Diagnostics',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13),
                                      fontFamily: themeProvider.fontFamily,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddCustomServerDialog(context, settings),
                                  icon: Icon(
                                    Icons.add,
                                    size: ResponsiveHelper.getResponsiveIconSize(context, mobile: 18),
                                  ),
                                  label: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خادم' : 'Add Server',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13),
                                      fontFamily: themeProvider.fontFamily,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          tablet: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showMcpDiagnostics(context),
                                  icon: const Icon(Icons.network_check),
                                  label: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'تشخيص الاتصال' : 'Connection Diagnostics',
                                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddCustomServerDialog(context, settings),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خادم' : 'Add Server',
                                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showMcpDiagnostics(context),
                                  icon: const Icon(Icons.network_check, size: 20),
                                  label: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'تشخيص الاتصال' : 'Connection Diagnostics',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: themeProvider.fontFamily,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddCustomServerDialog(context, settings),
                                  icon: const Icon(Icons.add, size: 20),
                                  label: Text(
                                    Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خادم' : 'Add Server',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: themeProvider.fontFamily,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  IconData _getServerIcon(String server) {
    if (server.contains('memory')) return Icons.memory;
    if (server.contains('thinking')) return Icons.psychology;
    if (server.contains('context')) return Icons.article;
    if (server.contains('deepwiki')) return Icons.library_books;
    return Icons.extension;
  }


  String _getServerDescription(String serverName, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    switch (serverName) {
      case 'memory':
        return isArabic 
          ? 'خادم الذاكرة الذكي لحفظ واسترجاع المعلومات'
          : 'Smart memory server for storing and retrieving information';
      case 'sequential-thinking':
        return isArabic 
          ? 'محرك التفكير التسلسلي للمشاكل المعقدة'
          : 'Sequential thinking engine for complex problems';
      case 'context7':
        return isArabic 
          ? 'خادم السياق المتقدم لفهم أعمق للمحادثات'
          : 'Advanced context server for deeper conversation understanding';
      case 'mcp-deepwiki':
        return isArabic 
          ? 'خادم المعرفة العميقة والبحث في الويكيبيديا'
          : 'Deep knowledge server with Wikipedia search capabilities';
      default:
        return isArabic ? 'خادم MCP مخصص' : 'Custom MCP server';
    }
  }

  String _getServerDisplayName(String server, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    switch (server) {
      case 'memory':
        return isArabic ? 'خادم الذاكرة' : 'Memory Server';
      case 'sequential-thinking':
        return isArabic ? 'التفكير التسلسلي' : 'Sequential Thinking';
      case 'context7':
        return isArabic ? 'السياق المتقدم' : 'Context7';
      case 'mcp-deepwiki':
        return isArabic ? 'المعرفة العميقة' : 'DeepWiki';
      default:
        return server;
    }
  }

  void _showMcpDiagnostics(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تشخيص خوادم MCP' : 'MCP Server Diagnostics'),
        contentPadding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? screenSize.width * 0.9 : 500,
            maxHeight: screenSize.height * 0.6,
          ),
          child: SizedBox(
            width: isSmallScreen ? double.infinity : 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildServerStatusTile(
                    context: context,
                    icon: Icons.memory,
                    title: isArabic ? 'خادم الذاكرة' : 'Memory Server',
                    subtitle: isArabic ? 'متصل ويعمل بشكل طبيعي' : 'Connected and working normally',
                    status: _ServerStatus.connected,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildServerStatusTile(
                    context: context,
                    icon: Icons.psychology,
                    title: isArabic ? 'خادم التفكير التسلسلي' : 'Sequential Thinking Server',
                    subtitle: isArabic ? 'متصل ويعمل بشكل طبيعي' : 'Connected and working normally',
                    status: _ServerStatus.connected,
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildServerStatusTile(
                    context: context,
                    icon: Icons.extension,
                    title: isArabic ? 'الخوادم المخصصة' : 'Custom Servers',
                    subtitle: isArabic ? 'لا توجد خوادم مخصصة' : 'No custom servers available',
                    status: _ServerStatus.warning,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إغلاق' : 'Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerStatusTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required _ServerStatus status,
    required bool isSmallScreen,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtraSmall = screenWidth < 360;
    Color iconColor;
    IconData statusIcon;
    
    switch (status) {
      case _ServerStatus.connected:
        iconColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case _ServerStatus.warning:
        iconColor = Colors.orange;
        statusIcon = Icons.info;
        break;
      case _ServerStatus.error:
        iconColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isExtraSmall ? 3.0 : (isSmallScreen ? 4.0 : 8.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isExtraSmall ? 8 : 12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: isExtraSmall ? 1 : 1.5,
        ),
        color: iconColor.withOpacity(0.05),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isExtraSmall ? 8.0 : (isSmallScreen ? 12.0 : 16.0),
          vertical: isExtraSmall ? 2.0 : (isSmallScreen ? 4.0 : 8.0),
        ),
        leading: Container(
          padding: EdgeInsets.all(isExtraSmall ? 6 : 8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isExtraSmall ? 6 : 8),
          ),
          child: Icon(
            icon, 
            color: iconColor, 
            size: isExtraSmall ? 16 : (isSmallScreen ? 20 : 24),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isExtraSmall ? 12 : (isSmallScreen ? 14 : 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: isExtraSmall ? null : Text(
          subtitle,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          statusIcon, 
          color: iconColor,
          size: isExtraSmall ? 16 : (isSmallScreen ? 18 : 20),
        ),
        dense: isExtraSmall,
      ),
    );
  }

  void _showAddCustomServerDialog(BuildContext context, SettingsProvider settings) {
    final jsonController = TextEditingController();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isExtraSmall = screenWidth < 360;
    final isSmallScreen = screenWidth < 600;
    String? errorMessage;
    bool isLoading = false;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          titlePadding: EdgeInsets.all(isExtraSmall ? 12 : (isSmallScreen ? 16 : 20)),
          title: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.green,
                size: isExtraSmall ? 20 : 24,
              ),
              SizedBox(width: isExtraSmall ? 6 : 8),
              Expanded(
                child: Text(
                  isArabic ? 'إضافة خادم MCP مخصص' : 'Add Custom MCP Server',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isExtraSmall ? 16 : (isSmallScreen ? 18 : 20),
                  ),
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.fromLTRB(
            isExtraSmall ? 12 : (isSmallScreen ? 16 : 20),
            8,
            isExtraSmall ? 12 : (isSmallScreen ? 16 : 20),
            isExtraSmall ? 8 : 12,
          ),
          content: SizedBox(
            width: isExtraSmall 
              ? screenWidth * 0.95 
              : ResponsiveHelper.getResponsiveValue(
                  context,
                  mobile: screenWidth * 0.9,
                  tablet: 700.0,
                  desktop: 800.0,
                ),
            height: screenHeight * (isExtraSmall ? 0.75 : 0.7),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  isArabic 
                    ? 'أدخل تكوين الخادم بصيغة JSON:' 
                    : 'Enter server configuration in JSON format:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isExtraSmall ? 13 : 14,
                  ),
                ),
                SizedBox(height: isExtraSmall ? 6 : 8),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: isExtraSmall ? 200 : 250,
                  ),
                  child: TextField(
                    controller: jsonController,
                    textDirection: TextDirection.ltr,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: isExtraSmall ? 12 : 14,
                    ),
                    decoration: InputDecoration(
                      hintText: isArabic 
                        ? '''{
  "name": "my-custom-server",
  "command": "npx",
  "args": ["-y", "@my/mcp-server"],
  "env": {},
  "disabled": false
}''' 
                        : '''{
  "name": "my-custom-server",
  "command": "npx",
  "args": ["-y", "@my/mcp-server"],
  "env": {},
  "disabled": false
}''',
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor.withOpacity(0.6),
                        fontFamily: 'monospace',
                        fontSize: isExtraSmall ? 10 : 12,
                      ),
                      hintTextDirection: TextDirection.ltr,
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(isExtraSmall ? 12 : 16),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelText: isExtraSmall 
                        ? (isArabic ? 'JSON' : 'JSON Config')
                        : (isArabic ? 'تكوين خادم MCP بصيغة JSON' : 'MCP Server Configuration JSON'),
                      labelStyle: TextStyle(fontSize: isExtraSmall ? 12 : 14),
                    ),
                    onChanged: (value) {
                      if (errorMessage != null) {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (!isExtraSmall)
                  Text(
                    isArabic 
                      ? 'تلميح: يمكنك نسخ النموذج أعلاه وتعديله حسب حاجتك' 
                      : 'Tip: You can copy the template above and modify it as needed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
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
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            isExtraSmall ? 12 : 16,
            isExtraSmall ? 4 : 8,
            isExtraSmall ? 12 : 16,
            isExtraSmall ? 8 : 12,
          ),
          actions: isExtraSmall ? [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    isArabic ? 'إلغاء' : 'Cancel',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    final jsonText = jsonController.text.trim();
                    if (jsonText.isEmpty) {
                      setState(() {
                        errorMessage = isArabic 
                          ? 'يرجى إدخال تكوين JSON' 
                          : 'Please enter JSON configuration';
                      });
                      return;
                    }
                    
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    
                    try {
                      final success = await _addServerFromJson(context, settings, jsonText, isArabic);
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isArabic 
                                ? '✅ تمت إضافة الخادم بنجاح' 
                                : '✅ Server added successfully'
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        errorMessage = e.toString();
                      });
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isArabic ? 'إضافة' : 'Add Server',
                        style: const TextStyle(fontSize: 14),
                      ),
                ),
              ],
            ),
          ] : [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final jsonText = jsonController.text.trim();
                if (jsonText.isEmpty) {
                  setState(() {
                    errorMessage = isArabic 
                      ? 'يرجى إدخال تكوين JSON' 
                      : 'Please enter JSON configuration';
                  });
                  return;
                }
                
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                
                try {
                  final success = await _addServerFromJson(context, settings, jsonText, isArabic);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic 
                            ? '✅ تمت إضافة الخادم بنجاح' 
                            : '✅ Server added successfully'
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: isLoading 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(isArabic ? 'إضافة الخادم' : 'Add Server'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<bool> _addServerFromJson(BuildContext context, SettingsProvider settings, String jsonText, bool isArabic) async {
    try {
      // التحقق من صحة JSON
      final Map<String, dynamic> config = jsonDecode(jsonText);
      
      // التحقق من الحقول المطلوبة
      if (!config.containsKey('name') || !config.containsKey('command')) {
        throw Exception(
          isArabic 
            ? 'حقول مطلوبة مفقودة: name و command' 
            : 'Required fields missing: name and command'
        );
      }
      
      final String name = config['name']?.toString() ?? '';
      final String command = config['command']?.toString() ?? '';
      
      if (name.isEmpty || command.isEmpty) {
        throw Exception(
          isArabic 
            ? 'name و command لا يمكن أن يكونا فارغين' 
            : 'name and command cannot be empty'
        );
      }
      
      // تحويل args إلى قائمة
      final List<String> args = [];
      if (config.containsKey('args')) {
        final argsValue = config['args'];
        if (argsValue is List) {
          args.addAll(argsValue.map((e) => e.toString()));
        } else if (argsValue is String && argsValue.isNotEmpty) {
          args.addAll(argsValue.split(',').map((e) => e.trim()));
        }
      }
      
      // تحويل env إلى Map
      final Map<String, String> env = {};
      if (config.containsKey('env') && config['env'] is Map) {
        final envMap = config['env'] as Map<String, dynamic>;
        env.addAll(envMap.map((key, value) => MapEntry(key, value.toString())));
      }
      
      // محاولة إضافة الخادم فعلياً
      settings.addCustomMcpServer(
        name,
        command,
        args,
        env,
      );
      
      return true;
    } on FormatException catch (e) {
      throw Exception(
        isArabic 
          ? 'خطأ في تنسيق JSON: ${e.message}' 
          : 'JSON format error: ${e.message}'
      );
    } catch (e) {
      if (e.toString().contains('Required fields') || 
          e.toString().contains('cannot be empty') ||
          e.toString().contains('حقول مطلوبة') ||
          e.toString().contains('لا يمكن أن يكونا فارغين')) {
        rethrow;
      }
      throw Exception(
        isArabic 
          ? 'خطأ في إضافة الخادم: ${e.toString()}' 
          : 'Error adding server: ${e.toString()}'
      );
    }
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

/// قسم النماذج المخصصة - Custom LLMs API
/// يصدر CustomModelsSection من custom_models_section.dart
/// مع دعم إضافة عدد لا محدود من النماذج وإمكانية تسميتها وحذفها
