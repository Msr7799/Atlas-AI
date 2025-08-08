import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/services/api_key_manager.dart';
import 'models_info_dialog.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _mcpJsonController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _mcpJsonController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mcpJsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveWidth(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
          ),
          child: Container(
            width: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              desktop: BoxConstraints(
                maxWidth: 800,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
            ).maxWidth,
            height: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              desktop: BoxConstraints(
                maxWidth: 800,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
            ).maxHeight,
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(12),
              tablet: const EdgeInsets.all(16),
              desktop: const EdgeInsets.all(20),
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(deviceType),
                const Divider(),

                // Tabs
                _buildTabs(deviceType),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildModelTab(deviceType),
                      _buildThemeTab(deviceType),
                      _buildAdvancedTab(deviceType),
                      _buildAboutTab(deviceType),
                    ],
                  ),
                ),

                // Action Buttons
                _buildActionButtons(deviceType),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(DeviceType deviceType) {
    return Row(
      children: [
        Icon(
          Icons.settings,
          color: Theme.of(context).colorScheme.primary,
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
            mobile: 6,
            tablet: 8,
            desktop: 12,
          ),
        ),
        Text(
          'الإعدادات',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 24,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.close,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTabs(DeviceType deviceType) {
    return TabBar(
      controller: _tabController,
      isScrollable: deviceType == DeviceType.mobile,
      tabs: [
        Tab(
          text: 'النموذج',
          icon: deviceType != DeviceType.mobile
              ? Icon(
                  Icons.psychology,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    tablet: 16,
                    desktop: 18,
                  ),
                )
              : null,
        ),
        Tab(
          text: 'المظهر',
          icon: deviceType != DeviceType.mobile
              ? Icon(
                  Icons.palette,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    tablet: 16,
                    desktop: 18,
                  ),
                )
              : null,
        ),
        Tab(
          text: 'متقدم',
          icon: deviceType != DeviceType.mobile
              ? Icon(
                  Icons.tune,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    tablet: 16,
                    desktop: 18,
                  ),
                )
              : null,
        ),
        Tab(
          text: 'حول',
          icon: deviceType != DeviceType.mobile
              ? Icon(
                  Icons.info,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    tablet: 16,
                    desktop: 18,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons(DeviceType deviceType) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.only(top: 8),
        tablet: const EdgeInsets.only(top: 12),
        desktop: const EdgeInsets.only(top: 16),
      ),
      child: deviceType == DeviceType.mobile
          ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.read<SettingsProvider>().resetToDefaults();
                      context.read<ThemeProvider>().setThemeMode(
                        ThemeMode.system,
                      );
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('حفظ'),
                  ),
                ),
              ],
            )
          : Row(
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
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('حفظ'),
                ),
              ],
            ),
    );
  }

  Widget _buildModelTab(DeviceType deviceType) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(12),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Model Selection
              Row(
                children: [
                  Expanded(
                    child: _buildSectionTitle(
                      'النموذج',
                      Icons.psychology,
                      deviceType,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showModelsInfoDialog(context),
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                      ),
                    ),
                    tooltip: 'معلومات النماذج المتاحة',
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
              DropdownButtonFormField<String>(
                value: settings.selectedModel,
                decoration: const InputDecoration(
                  labelText: 'اختر النموذج',
                  border: OutlineInputBorder(),
                ),
                items: _buildModelDropdownItems(),
                onChanged: (value) {
                  if (value != null) {
                    settings.setModel(value);
                  }
                },
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),

              // Temperature
              _buildSliderSection(
                title:
                    'درجة الحرارة: ${settings.temperature.toStringAsFixed(1)}',
                value: settings.temperature,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                onChanged: settings.setTemperature,
                description:
                    'قيمة أقل = إجابات أكثر تركيزاً، قيمة أعلى = إجابات أكثر إبداعاً',
                deviceType: deviceType,
              ),

              // Max Tokens
              _buildSliderSection(
                title: 'الحد الأقصى للرموز: ${settings.maxTokens}',
                value: settings.maxTokens.toDouble(),
                min: 100,
                max: 4000,
                divisions: 39,
                onChanged: (value) => settings.setMaxTokens(value.toInt()),
                deviceType: deviceType,
              ),

              // Stream Response
              SwitchListTile(
                title: const Text('الاستجابة المتدفقة'),
                subtitle: const Text('عرض النص أثناء الكتابة'),
                value: settings.streamResponse,
                onChanged: settings.setStreamResponse,
                contentPadding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.symmetric(horizontal: 0),
                  tablet: const EdgeInsets.symmetric(horizontal: 8),
                  desktop: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTab(DeviceType deviceType) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        return SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(12),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode
              _buildSectionTitle('وضع المظهر', Icons.palette, deviceType),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(
                      'نهاري',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.light_mode,
                      size: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(
                      'ليلي',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.dark_mode,
                      size: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(
                      'تلقائي',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.settings_brightness,
                      size: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                ],
                selected: {themeProvider.themeMode},
                onSelectionChanged: (Set<ThemeMode> selection) {
                  themeProvider.setThemeMode(selection.first);
                },
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),

              // Font Family
              _buildSectionTitle('نوع الخط', Icons.font_download, deviceType),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
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

              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),

              // Font Size
              _buildSliderSection(
                title: 'حجم الخط: ${themeProvider.fontSize.toInt()}',
                value: themeProvider.fontSize,
                min: 10.0,
                max: 20.0,
                divisions: 10,
                onChanged: themeProvider.setFontSize,
                deviceType: deviceType,
              ),

              // Accent Color
              _buildSectionTitle('اللون الأساسي', Icons.color_lens, deviceType),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showColorPicker(context, themeProvider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 50,
                      tablet: 55,
                      desktop: 60,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.accentColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          ),
                        ),
                        Icon(
                          Icons.palette,
                          color:
                              themeProvider.accentColor.computeLuminance() > 0.5
                              ? Colors.black.withOpacity(0.8)
                              : Colors.white.withOpacity(0.8),
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
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'اضغط لاختيار اللون المفضل',
                            style: TextStyle(
                              color:
                                  themeProvider.accentColor.computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color:
                              themeProvider.accentColor.computeLuminance() > 0.5
                              ? Colors.black.withOpacity(0.6)
                              : Colors.white.withOpacity(0.6),
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
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // إضافة مساحة في الأسفل
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTab(DeviceType deviceType) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        if (_mcpJsonController.text != settings.customMcpJson) {
          _mcpJsonController.text = settings.customMcpJson;
        }

        return SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(12),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Web Search
              SwitchListTile(
                title: const Text('البحث في الويب'),
                subtitle: const Text('تفعيل Tavily API للبحث'),
                value: settings.enableWebSearch,
                onChanged: settings.setEnableWebSearch,
                contentPadding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.symmetric(horizontal: 0),
                  tablet: const EdgeInsets.symmetric(horizontal: 8),
                  desktop: const EdgeInsets.symmetric(horizontal: 16),
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

              // MCP Servers
              SwitchListTile(
                title: const Text('خوادم MCP'),
                subtitle: const Text('تفعيل Model Context Protocol'),
                value: settings.enableMcpServers,
                onChanged: settings.setEnableMcpServers,
                contentPadding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.symmetric(horizontal: 0),
                  tablet: const EdgeInsets.symmetric(horizontal: 8),
                  desktop: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),

              if (settings.enableMcpServers) ...[
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),

                _buildSectionTitle(
                  'خوادم MCP الافتراضية',
                  Icons.dns,
                  deviceType,
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),

                // Memory Server
                _buildMcpServerTile(
                  'خادم الذاكرة',
                  'حفظ واسترجاع المعلومات',
                  'memory',
                  settings,
                  deviceType,
                ),

                // Sequential Thinking Server
                _buildMcpServerTile(
                  'التفكير التسلسلي',
                  'عرض عملية التفكير خطوة بخطوة',
                  'sequential-thinking',
                  settings,
                  deviceType,
                ),

                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),

                // Custom MCP Servers Section
                _buildCustomMcpSection(settings, deviceType),
              ],

              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),

              // API Status
              _buildSectionTitle('حالة الـ APIs', Icons.api, deviceType),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              _buildApiStatus('Groq API', true, deviceType),
              _buildApiStatus(
                'Tavily API',
                settings.enableWebSearch,
                deviceType,
              ),
              _buildApiStatus(
                'MCP Servers',
                settings.enableMcpServers,
                deviceType,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(DeviceType deviceType) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Icon
          Container(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 100,
              tablet: 120,
              desktop: 140,
            ),
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 100,
              tablet: 120,
              desktop: 140,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              child: Image.asset(
                'assets/icons/ATLAS_icon2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.smart_toy,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 50,
                      tablet: 60,
                      desktop: 70,
                    ),
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),

          // App Name
          Text(
            'Atlas AI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),

          // Version
          Text(
            'الإصدار 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),

          // Description
          Text(
            'مساعد ذكي يدعم اللغة العربية مع إمكانيات تدريب متقدمة للنماذج',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
          ),

          // Developer Info
          _buildInfoCard(
            'المطور',
            'Mohamed S AL-Romaihi',
            Icons.person,
            deviceType,
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),

          // Contact Info
          _buildInfoCard(
            'الإبلاغ عن المشاكل',
            'alromaihi2224@gmail.com',
            Icons.bug_report,
            deviceType,
            isEmail: true,
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),

          // Features
          _buildFeaturesCard(deviceType),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),

          // Copyright
          Text(
            '© 2025 Mohamed S AL-Romaihi\nجميع الحقوق محفوظة',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    DeviceType deviceType,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: ResponsiveHelper.getResponsiveIconSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
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
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    String? description,
    required DeviceType deviceType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        if (description != null) ...[
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 4,
              tablet: 6,
              desktop: 8,
            ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
          ),
        ],
        SizedBox(
          height: ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMcpServerTile(
    String title,
    String subtitle,
    String serverKey,
    SettingsProvider settings,
    DeviceType deviceType,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
      value: settings.mcpServerStatus[serverKey] ?? false,
      onChanged: (value) => settings.setMcpServerStatus(serverKey, value),
      contentPadding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 0),
        tablet: const EdgeInsets.symmetric(horizontal: 8),
        desktop: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildCustomMcpSection(
    SettingsProvider settings,
    DeviceType deviceType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'خوادم MCP مخصصة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showMcpHelpDialog(context),
              icon: Icon(
                Icons.help_outline,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
              label: Text(
                'مساعدة',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
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

        // JSON Input Field
        TextField(
          controller: _mcpJsonController,
          maxLines: ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: 6,
            tablet: 8,
            desktop: 10,
          ).toInt(),
          decoration: InputDecoration(
            labelText: 'إعدادات MCP (JSON)',
            hintText: _getMcpJsonExample(),
            border: const OutlineInputBorder(),
            helperText: 'أدخل إعدادات خوادم MCP بصيغة JSON',
            helperStyle: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 11,
                tablet: 12,
                desktop: 14,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.save,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
              onPressed: () => _saveMcpJson(context, settings),
            ),
          ),
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
          onSubmitted: (value) => _saveMcpJson(context, settings),
        ),

        SizedBox(
          height: ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
        ),

        // Display custom servers
        if (settings.customMcpServers.isNotEmpty) ...[
          Text(
            'الخوادم المخصصة المتاحة:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
          ...settings.customMcpServers.keys.map((serverName) {
            return Card(
              margin: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: const EdgeInsets.only(bottom: 8),
                tablet: const EdgeInsets.only(bottom: 12),
                desktop: const EdgeInsets.only(bottom: 16),
              ),
              child: SwitchListTile(
                title: Text(
                  serverName,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
                subtitle: Text(
                  settings.customMcpServers[serverName]['description'] ??
                      'خادم MCP مخصص',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                ),
                value: settings.mcpServerStatus[serverName] ?? false,
                onChanged: (value) =>
                    settings.setMcpServerStatus(serverName, value),
                secondary: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                  onPressed: () =>
                      _showDeleteConfirmation(context, serverName, settings),
                ),
                contentPadding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  tablet: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  desktop: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildApiStatus(String name, bool isEnabled, DeviceType deviceType) {
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(
        context,
        mobile: const EdgeInsets.only(bottom: 6),
        tablet: const EdgeInsets.only(bottom: 8),
        desktop: const EdgeInsets.only(bottom: 10),
      ),
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(10),
        tablet: const EdgeInsets.all(12),
        desktop: const EdgeInsets.all(16),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveWidth(
            context,
            mobile: 6,
            tablet: 8,
            desktop: 10,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 10,
              tablet: 12,
              desktop: 14,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            isEnabled ? 'متصل' : 'غير متصل',
            style: TextStyle(
              color: isEnabled ? Colors.green : Colors.red,
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
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    DeviceType deviceType, {
    bool isEmail = false,
  }) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveWidth(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
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
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
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
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),
          GestureDetector(
            onTap: isEmail
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الإيميل إلى الحافظة'),
                      ),
                    );
                  }
                : null,
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: isEmail
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                decoration: isEmail ? TextDecoration.underline : null,
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
    );
  }

  Widget _buildFeaturesCard(DeviceType deviceType) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveWidth(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
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
                'المميزات الرئيسية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
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
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
          _buildFeatureItem('🤖', 'دعم متعدد النماذج (Groq, GPT)', deviceType),
          _buildFeatureItem('🔧', 'تدريب وتحسين النماذج', deviceType),
          _buildFeatureItem('🌐', 'البحث في الويب المتقدم', deviceType),
          _buildFeatureItem('💾', 'حفظ وتصدير المحادثات', deviceType),
          _buildFeatureItem('🎨', 'مظاهر متعددة وقابلة للتخصيص', deviceType),
          _buildFeatureItem('🔒', 'حماية البيانات والخصوصية', deviceType),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text, DeviceType deviceType) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.only(bottom: 6),
        tablet: const EdgeInsets.only(bottom: 8),
        desktop: const EdgeInsets.only(bottom: 10),
      ),
      child: Row(
        children: [
          Text(
            icon,
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
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 10,
              tablet: 12,
              desktop: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 13,
                  tablet: 15,
                  desktop: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveBuilder(
        builder: (context, constraints, deviceType) {
          final dialogWidth = ResponsiveHelper.getResponsiveWidth(
            context,
            mobile: MediaQuery.of(context).size.width * 0.9,
            tablet: 450,
            desktop: 600,
          );

          final dialogHeight = ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: MediaQuery.of(context).size.height * 0.7,
            tablet: 500,
            desktop: 600,
          );

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(16),
                  tablet: const EdgeInsets.all(20),
                  desktop: const EdgeInsets.all(24),
                ),
                child: Column(
                  children: [
                    // العنوان
                    Row(
                      children: [
                        Icon(
                          Icons.palette,
                          color: themeProvider.accentColor,
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
                            'اختر اللون المفضل',
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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          iconSize: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),

                    // معاينة اللون الحالي
                    Container(
                      width: double.infinity,
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 50,
                        tablet: 60,
                        desktop: 70,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'اللون الحالي',
                          style: TextStyle(
                            color:
                                themeProvider.accentColor.computeLuminance() >
                                    0.5
                                ? Colors.black
                                : Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
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

                    SizedBox(
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),

                    // Color Picker - محسن للاستجابة
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: ResponsiveHelper.getResponsivePadding(
                            context,
                            mobile: const EdgeInsets.symmetric(horizontal: 8),
                            tablet: const EdgeInsets.symmetric(horizontal: 16),
                            desktop: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: ColorPicker(
                            pickerColor: themeProvider.accentColor,
                            onColorChanged: themeProvider.setAccentColor,
                            // تحسين نسبة الارتفاع حسب نوع الجهاز
                            pickerAreaHeightPercent:
                                ResponsiveHelper.getResponsiveValue<double>(
                                  context,
                                  mobile: 0.5,
                                  tablet: 0.6,
                                  desktop: 0.7,
                                ),
                            enableAlpha: false,
                            displayThumbColor: true,
                            paletteType: PaletteType.hslWithHue,
                            labelTypes: const [],
                            portraitOnly: ResponsiveHelper.isMobile(context),
                            // تحسين عرض الألوان حسب حجم الشاشة
                            colorPickerWidth:
                                ResponsiveHelper.getResponsiveWidth(
                                  context,
                                  mobile: 250,
                                  tablet: 300,
                                  desktop: 350,
                                ),
                            pickerAreaBorderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveValue<double>(
                                context,
                                mobile: 8,
                                tablet: 12,
                                desktop: 16,
                              ),
                            ),
                          ),
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

                    // الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // زر الإلغاء
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: ResponsiveHelper.getResponsivePadding(
                                context,
                                mobile: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                tablet: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                desktop: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
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
                        ),

                        SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),

                        // زر الموافقة
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // حفظ اللون
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم تغيير اللون بنجاح! ✅',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            mobile: 14,
                                            tablet: 16,
                                            desktop: 18,
                                          ),
                                    ),
                                  ),
                                  backgroundColor: themeProvider.accentColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.accentColor,
                              foregroundColor:
                                  themeProvider.accentColor.computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                              padding: ResponsiveHelper.getResponsivePadding(
                                context,
                                mobile: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                tablet: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                desktop: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'تطبيق',
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
    );
  }

  String _getMcpJsonExample() {
    return '''{
  "my-custom-server": {
    "name": "خادم مخصص",
    "description": "وصف الخادم المخصص",
    "command": "node",
    "args": ["server.js"],
    "env": {
      "PORT": "3000"
    },
    "capabilities": ["custom_function"]
  }
}''';
  }

  void _showMcpHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveBuilder(
        builder: (context, constraints, deviceType) {
          return AlertDialog(
            title: Text(
              'مساعدة خوادم MCP المخصصة',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            content: SizedBox(
              width: ResponsiveHelper.getResponsiveWidth(
                context,
                mobile: MediaQuery.of(context).size.width * 0.85,
                tablet: 450,
                desktop: 550,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كيفية إضافة خوادم MCP مخصصة:',
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
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    Text(
                      '1. أدخل إعدادات بصيغة JSON\n'
                      '2. كل خادم يجب أن يحتوي على:\n'
                      '   • command: الأمر لتشغيل الخادم\n'
                      '   • args: المعاملات المطلوبة\n'
                      '   • env (اختياري): متغيرات البيئة',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 13,
                          tablet: 15,
                          desktop: 17,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    Text(
                      'مثال:',
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
                    Container(
                      padding: ResponsiveHelper.getResponsivePadding(
                        context,
                        mobile: const EdgeInsets.all(6),
                        tablet: const EdgeInsets.all(8),
                        desktop: const EdgeInsets.all(10),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _getMcpJsonExample(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
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
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String serverName,
    SettingsProvider settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveBuilder(
        builder: (context, constraints, deviceType) {
          return AlertDialog(
            title: Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            content: Text(
              'هل تريد حذف الخادم "$serverName"؟',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
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
              TextButton(
                onPressed: () {
                  settings.removeCustomMcpServer(serverName);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حذف الخادم "$serverName"')),
                  );
                },
                child: Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.red,
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
          );
        },
      ),
    );
  }

  // بناء عناصر dropdown للنماذج
  List<DropdownMenuItem<String>> _buildModelDropdownItems() {
    final items = <DropdownMenuItem<String>>[];

    // إضافة نماذج Groq
    items.add(
      DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'نماذج Groq',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
        ),
      ),
    );

    final groqModels = ApiKeyManager.getFreeModels('groq');
    for (final model in groqModels) {
      items.add(
        DropdownMenuItem<String>(
          value: model['id'],
          child: Tooltip(
            message: _buildModelTooltip(model),
            preferBelow: false,
            child: Text(
              '${model['name']} (Groq)',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // إضافة فاصل
    items.add(
      DropdownMenuItem<String>(
        enabled: false,
        child: Divider(color: Colors.grey[400], height: 1),
      ),
    );

    // إضافة نماذج GPTGod
    items.add(
      DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'نماذج GPTGod',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
        ),
      ),
    );

    final gptgodModels = ApiKeyManager.getFreeModels('gptgod');
    for (final model in gptgodModels) {
      items.add(
        DropdownMenuItem<String>(
          value: model['id'],
          child: Tooltip(
            message: _buildModelTooltip(model),
            preferBelow: false,
            child: Text(
              '${model['name']} (GPTGod)',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return items;
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

  // عرض dialog معلومات النماذج
  void _showModelsInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ModelsInfoDialog(),
    );
  }

  void _saveMcpJson(BuildContext context, SettingsProvider settings) async {
    final success = await settings.setCustomMcpJson(_mcpJsonController.text);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'تم حفظ إعدادات MCP بنجاح' : 'خطأ في صيغة JSON',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
