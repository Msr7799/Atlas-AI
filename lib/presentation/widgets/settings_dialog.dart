import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'الإعدادات',
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

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'النموذج'),
                Tab(text: 'المظهر'),
                Tab(text: 'متقدم'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildModelTab(),
                  _buildThemeTab(),
                  _buildAdvancedTab(),
                ],
              ),
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<SettingsProvider>().resetToDefaults();
                    context.read<ThemeProvider>().setThemeMode(
                      ThemeMode.system,
                    );
                  },
                  child: const Text('إعادة تعيين'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelTab() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Model Selection
              Text(
                'النموذج',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: settings.selectedModel,
                decoration: const InputDecoration(
                  labelText: 'اختر النموذج',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'gemma2-9b-it',
                    child: Text('Gemma2 9B IT (Groq)'),
                  ),
                  DropdownMenuItem(
                    value: 'llama-3.1-70b-versatile',
                    child: Text('Llama 3.1 70B (Groq)'),
                  ),
                  DropdownMenuItem(
                    value: 'mixtral-8x7b-32768',
                    child: Text('Mixtral 8x7B (Groq)'),
                  ),
                  DropdownMenuItem(
                    value: 'gpt-3.5-turbo',
                    child: Text('GPT-3.5 Mini Turbo (GPTGOD)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.setModel(value);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Temperature
              Text(
                'درجة الحرارة: ${settings.temperature.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: settings.temperature,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                onChanged: settings.setTemperature,
              ),
              Text(
                'قيمة أقل = إجابات أكثر تركيزاً، قيمة أعلى = إجابات أكثر إبداعاً',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                ),
              ),

              const SizedBox(height: 24),

              // Max Tokens
              Text(
                'الحد الأقصى للرموز: ${settings.maxTokens}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: settings.maxTokens.toDouble(),
                min: 100,
                max: 4000,
                divisions: 39,
                onChanged: (value) => settings.setMaxTokens(value.toInt()),
              ),

              const SizedBox(height: 24),

              // Stream Response
              SwitchListTile(
                title: const Text('الاستجابة المتدفقة'),
                subtitle: const Text('عرض النص أثناء الكتابة'),
                value: settings.streamResponse,
                onChanged: settings.setStreamResponse,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTab() {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode
              Text(
                'وضع المظهر',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('نهاري'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('ليلي'),
                    icon: Icon(Icons.dark_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('تلقائي'),
                    icon: Icon(Icons.settings_brightness),
                  ),
                ],
                selected: {themeProvider.themeMode},
                onSelectionChanged: (Set<ThemeMode> selection) {
                  themeProvider.setThemeMode(selection.first);
                },
              ),

              const SizedBox(height: 24),

              // Font Family
              Text(
                'نوع الخط',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: themeProvider.fontFamily,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: 'Cairo',
                    child: Text('Cairo (القاهرة)'),
                  ),
                  DropdownMenuItem(
                    value: 'Uthmanic',
                    child: Text('Uthmanic (عثماني)'),
                  ),
                  DropdownMenuItem(value: 'Inter', child: Text('Inter')),
                  DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setFontFamily(value);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Font Size
              Text(
                'حجم الخط: ${themeProvider.fontSize.toInt()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: themeProvider.fontSize,
                min: 10.0,
                max: 20.0,
                divisions: 10,
                onChanged: themeProvider.setFontSize,
              ),

              const SizedBox(height: 24),

              // Accent Color
              Text(
                'اللون الأساسي',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showColorPicker(context, themeProvider),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'اضغط لاختيار اللون',
                      style: TextStyle(
                        color:
                            themeProvider.accentColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTab() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Web Search
              SwitchListTile(
                title: const Text('البحث في الويب'),
                subtitle: const Text('تفعيل Tavily API للبحث'),
                value: settings.enableWebSearch,
                onChanged: settings.setEnableWebSearch,
              ),

              const SizedBox(height: 16),

              // MCP Servers
              SwitchListTile(
                title: const Text('خوادم MCP'),
                subtitle: const Text('تفعيل Model Context Protocol'),
                value: settings.enableMcpServers,
                onChanged: settings.setEnableMcpServers,
              ),

              if (settings.enableMcpServers) ...[
                const SizedBox(height: 16),
                Text(
                  'خوادم MCP المتاحة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Memory Server
                SwitchListTile(
                  title: const Text('خادم الذاكرة'),
                  subtitle: const Text('حفظ واسترجاع المعلومات'),
                  value: settings.mcpServerStatus['memory'] ?? false,
                  onChanged: (value) =>
                      settings.setMcpServerStatus('memory', value),
                ),

                // Sequential Thinking Server
                SwitchListTile(
                  title: const Text('التفكير التسلسلي'),
                  subtitle: const Text('عرض عملية التفكير خطوة بخطوة'),
                  value:
                      settings.mcpServerStatus['sequential-thinking'] ?? false,
                  onChanged: (value) =>
                      settings.setMcpServerStatus('sequential-thinking', value),
                ),
              ],

              const SizedBox(height: 24),

              // API Status
              Text(
                'حالة الـ APIs',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildApiStatus('Groq API', true),
              _buildApiStatus('Tavily API', settings.enableWebSearch),
              _buildApiStatus('MCP Servers', settings.enableMcpServers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApiStatus(String name, bool isEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(name),
          const Spacer(),
          Text(
            isEnabled ? 'متصل' : 'غير متصل',
            style: TextStyle(
              color: isEnabled ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللون'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: themeProvider.accentColor,
            onColorChanged: themeProvider.setAccentColor,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
