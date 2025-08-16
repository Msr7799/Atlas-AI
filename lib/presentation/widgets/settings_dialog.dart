import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../../core/services/api_key_manager.dart';
import 'settings/settings_sections.dart';
import 'settings/api_keys_section.dart';
import '../../generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// Added import for AppConfig

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _mcpJsonController;

  // Color picker variables
  Color _tempColor = Colors.blue;
  final bool _isColorPickerOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _mcpJsonController = TextEditingController();
    
    // Initialize temp color with current theme color
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _tempColor = themeProvider.accentColor;
    });
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
          child: SizedBox(
            width: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              desktop: BoxConstraints(
                maxWidth: 1200,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
            ).maxWidth,
            height: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              desktop: BoxConstraints(
                maxWidth: 1200,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
            ).maxHeight,
            child: Consumer3<ThemeProvider, SettingsProvider, LanguageProvider>(
              builder: (context, themeProvider, settingsProvider, languageProvider, child) {
                return Column(
                  children: [
                    // Header
                    _buildEnhancedHeader(context, themeProvider),
                    const Divider(height: 1),

                    // Enhanced Tabs
                    _buildEnhancedTabs(context, themeProvider),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAISettingsTab(context, settingsProvider, themeProvider),
                          _buildAppearanceTab(context, themeProvider, languageProvider),
                          _buildAdvancedOptionsTab(context, settingsProvider, themeProvider),
                          _buildAboutTab(deviceType),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.accentColor,
            themeProvider.accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات التطبيق' : 'App Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: themeProvider.fontFamily,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إغلاق' : 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTabs(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: themeProvider.accentColor,
        labelColor: themeProvider.accentColor,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          fontFamily: themeProvider.fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13,
          fontFamily: themeProvider.fontFamily,
        ),
        tabs: [
          Tab(
            icon: Icon(Icons.psychology, size: 20),
            text: Localizations.localeOf(context).languageCode == 'ar' ? 'الذكاء الاصطناعي' : 'AI',
          ),
          Tab(
            icon: Icon(Icons.palette, size: 20),
            text: Localizations.localeOf(context).languageCode == 'ar' ? 'المظهر' : 'Appearance',
          ),
          Tab(
            icon: Icon(Icons.tune, size: 20),
            text: Localizations.localeOf(context).languageCode == 'ar' ? 'خيارات متقدمة' : 'Advanced Options',
          ),
          Tab(
            icon: Icon(Icons.info_outline, size: 20),
            text: Localizations.localeOf(context).languageCode == 'ar' ? 'حول التطبيق' : 'About',
          ),
        ],
      ),
    );
  }

  Widget _buildAISettingsTab(BuildContext context, SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // استخدام الأقسام المحدثة
          ModelSettingsSection(),
          SizedBox(height: 16),
          McpServersSection(),
          SizedBox(height: 16),
          AdvancedSettingsSection(),
        ],
      ),
    );
  }




  // الحصول على اسم الخدمة للعرض
  String _getServiceDisplayName(String serviceName) {
    switch (serviceName) {
      case 'groq':
        return 'Groq';
      case 'gptgod':
        return 'GPTGod';
      case 'openrouter':
        return 'OpenRouter';
      case 'huggingface':
        return 'HuggingFace';
      case 'tavily':
        return 'Tavily';
      case 'localai':
        return 'LocalAI/Ollama';
      default:
        return serviceName;
    }
  }

  // عرض حوار إدارة مفاتيح API
  void _showApiKeysDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.key, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'إدارة مفاتيح API' : 'Manage API Keys',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const Expanded(
                child: ApiKeysSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تأكيد حذف مفتاح API
  void _confirmDeleteApiKey(BuildContext context, String serviceName, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'هل تريد حذف مفتاح ${_getServiceDisplayName(serviceName)}؟' : 'Do you want to delete the ${_getServiceDisplayName(serviceName)} key?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ApiKeyManager.clearApiKey(serviceName);
              Navigator.pop(context);
              setState(() {}); // تحديث الواجهة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم حذف مفتاح ${_getServiceDisplayName(serviceName)}' : '${_getServiceDisplayName(serviceName)} key deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  // تأكيد مسح جميع مفاتيح API
  void _confirmClearAllApiKeys(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تحذير' : 'Warning'),
        content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'هل تريد حذف جميع مفاتيح API؟ هذا الإجراء لا يمكن التراجع عنه.' : 'Do you want to delete all API keys? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ApiKeyManager.clearAllApiKeys();
              Navigator.pop(context);
              setState(() {}); // تحديث الواجهة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم حذف جميع مفاتيح API' : 'All API keys deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حذف الكل' : 'Delete All'),
          ),
        ],
      ),
    );
  }

  void _showKeyRequiredDialog(BuildContext context, String serviceName, String model, 
      SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Localizations.localeOf(context).languageCode == 'ar' ? 'مفتاح API مطلوب' : 'API Key Required',
          style: TextStyle(fontFamily: themeProvider.fontFamily),
        ),
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar' ? 'هذا النموذج يتطلب مفتاح API لـ $serviceName. يرجى إضافة المفتاح في صفحة إعدادات API أولاً.' : 'This model requires an API key for $serviceName. Please add the key in API settings first.',
          style: TextStyle(fontFamily: themeProvider.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/apiSettings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات API' : 'API Settings',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab(BuildContext context, ThemeProvider themeProvider, LanguageProvider languageProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Mode
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? ' وضع المظهر' : ' Theme Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: Text('🌞', style: TextStyle(fontFamily: themeProvider.fontFamily)),
                          value: ThemeMode.light,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) => themeProvider.setThemeMode(value!),
                          activeColor: themeProvider.accentColor,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: Text('🌙', style: TextStyle(fontFamily: themeProvider.fontFamily)),
                          value: ThemeMode.dark,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) => themeProvider.setThemeMode(value!),
                          activeColor: themeProvider.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? '🌐 اللغة' : '🌐 Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<Locale>(
                          title: Text(
                            Localizations.localeOf(context).languageCode == 'ar' ? 'العربية' : 'Arabic',
                            style: TextStyle(fontFamily: themeProvider.fontFamily),
                          ),
                          value: const Locale('ar'),
                          groupValue: languageProvider.currentLocale,
                          onChanged: (value) async {
                            if (value != null) {
                              await languageProvider.changeLanguage(value);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      Localizations.localeOf(context).languageCode == 'ar' ? 'تم تغيير اللغة إلى العربية' : 'Language changed to Arabic',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    backgroundColor: themeProvider.accentColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          activeColor: themeProvider.accentColor,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<Locale>(
                          title: Text(
                            Localizations.localeOf(context).languageCode == 'ar' ? 'الإنجليزية' : 'English',
                            style: TextStyle(fontFamily: themeProvider.fontFamily),
                          ),
                          value: const Locale('en'),
                          groupValue: languageProvider.currentLocale,
                          onChanged: (value) async {
                            if (value != null) {
                              await languageProvider.changeLanguage(value);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Language changed to English',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    backgroundColor: themeProvider.accentColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          activeColor: themeProvider.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: themeProvider.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            languageProvider.currentLocale.languageCode == 'ar' 
                              ? 'قد تحتاج لإعادة تشغيل التطبيق لتطبيق تغييرات اللغة بالكامل'
                              : 'You may need to restart the app to fully apply language changes',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.accentColor,
                              fontFamily: themeProvider.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color Picker
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? '🎨 لون التطبيق الأساسي' : '🎨 Primary App Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: themeProvider.accentColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showColorPicker(context, themeProvider),
                          icon: const Icon(Icons.palette),
                          label: Text(
                            'اختيار لون جديد',
                            style: TextStyle(fontFamily: themeProvider.fontFamily),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اللون الحالي: ${_colorToHex(themeProvider.accentColor)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Font Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔤 الخط المستخدم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: themeProvider.fontFamily,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ThemeProvider.availableFonts.map((font) => DropdownMenuItem(
                      value: font,
                      child: Text(
                        font == 'Amiri' ? 'Amiri (كلاسيكي)' :
                        font == 'Scheherazade New' ? 'Scheherazade New (حديث)' : font,
                        style: TextStyle(fontFamily: font),
                      ),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) themeProvider.setFontFamily(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Font Size
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📏 حجم الخط',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'صغير',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: themeProvider.fontFamily,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: themeProvider.fontSize,
                          min: 8.0,
                          max: 21.0,
                          divisions: 8,
                          activeColor: themeProvider.accentColor,
                          onChanged: (value) => themeProvider.setFontSize(value),
                        ),
                      ),
                      Text(
                        'كبير',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: themeProvider.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'نموذج للنص بالحجم المحدد (${themeProvider.fontSize.toInt()})',
                        style: TextStyle(
                          fontSize: themeProvider.fontSize,
                          fontFamily: themeProvider.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Custom Background Section - Responsive
          Card(
            child: Padding(
              padding: ResponsiveHelper.getResponsivePadding(
                context,
                mobile: const EdgeInsets.all(12),
                tablet: const EdgeInsets.all(16),
                desktop: const EdgeInsets.all(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🖼️ الخلفية المخصصة',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  )),
                  
                  // Current background preview - Responsive
                  if (themeProvider.hasCustomBackground) ...[
                    Container(
                      width: double.infinity,
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 100,
                        tablet: 120,
                        desktop: 150,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 8,
                            tablet: 12,
                            desktop: 16,
                          ),
                        ),
                        image: DecorationImage(
                          image: FileImage(themeProvider.getCustomBackgroundFile()!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveWidth(
                              context,
                              mobile: 8,
                              tablet: 12,
                              desktop: 16,
                            ),
                          ),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            '✨ الخلفية الحالية ✨',
                            style: TextStyle(
                              fontFamily: themeProvider.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    )),
                  ],
                  
                  // Background control buttons - Responsive Layout
                  ResponsiveHelper.buildResponsiveLayout(
                    context,
                    mobile: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final success = await themeProvider.pickCustomBackground();
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ تم تطبيق الخلفية المخصصة بنجاح',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ فشل في اختيار الصورة',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.image, size: ResponsiveHelper.getResponsiveIconSize(context, mobile: 18)),
                            label: Text(
                              themeProvider.hasCustomBackground ? 'تغيير الخلفية' : 'اختيار خلفية',
                              style: TextStyle(
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: themeProvider.hasCustomBackground ? () {
                              themeProvider.removeCustomBackground();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🔄 تم العودة للوضع العادي (ليلي/نهاري)',
                                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } : null,
                            icon: Icon(
                              themeProvider.hasCustomBackground ? Icons.refresh : Icons.block,
                              color: themeProvider.hasCustomBackground ? Colors.blue : Colors.grey,
                              size: ResponsiveHelper.getResponsiveIconSize(context, mobile: 18),
                            ),
                            label: Text(
                              themeProvider.hasCustomBackground ? 'بدون خلفية' : 'استخدام الثيم',
                              style: TextStyle(
                                color: themeProvider.hasCustomBackground ? Colors.blue : Colors.grey,
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
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
                            onPressed: () async {
                              final success = await themeProvider.pickCustomBackground();
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ تم تطبيق الخلفية المخصصة بنجاح',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ فشل في اختيار الصورة',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.image, size: ResponsiveHelper.getResponsiveIconSize(context, tablet: 20)),
                            label: Text(
                              themeProvider.hasCustomBackground ? 'تغيير الخلفية' : 'اختيار خلفية',
                              style: TextStyle(
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13, tablet: 14),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: themeProvider.hasCustomBackground ? () {
                              themeProvider.removeCustomBackground();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🔄 تم العودة للوضع العادي (ليلي/نهاري)',
                                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } : null,
                            icon: Icon(
                              themeProvider.hasCustomBackground ? Icons.refresh : Icons.block,
                              color: themeProvider.hasCustomBackground ? Colors.blue : Colors.grey,
                              size: ResponsiveHelper.getResponsiveIconSize(context, tablet: 20),
                            ),
                            label: Text(
                              themeProvider.hasCustomBackground ? 'بدون خلفية' : 'استخدام الثيم',
                              style: TextStyle(
                                color: themeProvider.hasCustomBackground ? Colors.blue : Colors.grey,
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13, tablet: 14),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
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
                            onPressed: () async {
                              final success = await themeProvider.pickCustomBackground();
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ تم تطبيق الخلفية المخصصة بنجاح',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ فشل في اختيار الصورة',
                                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.image, size: ResponsiveHelper.getResponsiveIconSize(context, desktop: 22)),
                            label: Text(
                              themeProvider.hasCustomBackground ? 'تغيير الخلفية' : 'اختيار خلفية',
                              style: TextStyle(
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13, desktop: 15),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: themeProvider.hasCustomBackground ? () {
                              themeProvider.removeCustomBackground();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🔄 تم العودة للوضع العادي (ليلي/نهاري)',
                                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } : null,
                            icon: Icon(
                              themeProvider.hasCustomBackground ? Icons.refresh : Icons.block,
                              color: themeProvider.hasCustomBackground ? Colors.blue : Colors.grey,
                              size: ResponsiveHelper.getResponsiveIconSize(context, desktop: 22),
                            ),
                            label: Text(
                              themeProvider.hasCustomBackground ? 'بدون خلفية' : 'استخدام الثيم',
                              style: TextStyle(
                                color: themeProvider.hasCustomBackground ? Colors.blue : Colors.grey,
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13, desktop: 15),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (themeProvider.hasCustomBackground) ...[
                    SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    )),
                    Container(
                      padding: ResponsiveHelper.getResponsivePadding(
                        context,
                        mobile: const EdgeInsets.all(10),
                        tablet: const EdgeInsets.all(12),
                        desktop: const EdgeInsets.all(14),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline, 
                            color: Colors.orange, 
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 6,
                            tablet: 8,
                            desktop: 10,
                          )),
                          Expanded(
                            child: Text(
                              'الخلفية المخصصة تلغي وضع الليل والنهار. استخدم زر "بدون خلفية" للعودة للوضع العادي.',
                              style: TextStyle(
                                fontFamily: themeProvider.fontFamily,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 11,
                                  tablet: 12,
                                  desktop: 13,
                                ),
                                color: Colors.orange,
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
        ],
      ),
    );
  }

  // Color Picker Helper Methods
  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    _tempColor = themeProvider.accentColor;

    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'اختيار اللون الأساسي',
          style: TextStyle(fontFamily: themeProvider.fontFamily),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _tempColor,
            onColorChanged: (color) => _tempColor = color,
            colorPickerWidth: 300,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsl,
            labelTypes: const [],
            pickerAreaBorderRadius: BorderRadius.circular(8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {

              Navigator.of(context).pop();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              themeProvider.setAccentColor(_tempColor);

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _tempColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'تطبيق',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Widget _buildAdvancedOptionsTab(BuildContext context, SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animation Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎬 إعدادات الحركة والانيميشن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.animation),
                    title: Text(
                      'إعدادات الحركة',
                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                    ),
                    subtitle: Text(
                      'قريباً - سيتم إضافة المزيد من إعدادات الحركة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Performance Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ إعدادات الأداء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      'البحث على الويب',
                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                    ),
                    subtitle: Text(
                      'تفعيل البحث على الإنترنت للحصول على معلومات محدثة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                    value: settingsProvider.enableWebSearch,
                    activeColor: themeProvider.accentColor,
                    onChanged: (value) => settingsProvider.setEnableWebSearch(value),
                  ),
                  SwitchListTile(
                    title: Text(
                      'الاستجابة المباشرة',
                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                    ),
                    subtitle: Text(
                      'إظهار الاستجابة أثناء الكتابة (أسرع)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                    value: settingsProvider.streamResponse,
                    activeColor: themeProvider.accentColor,
                    onChanged: (value) => settingsProvider.setStreamResponse(value),
                  ),
                  SwitchListTile(
                    title: Text(
                      'المعالجة التلقائية للنص',
                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                    ),
                    subtitle: Text(
                      'تحسين تنسيق النص تلقائياً (Markdown، قوائم، أكواد)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                    value: settingsProvider.enableAutoTextFormatting,
                    activeColor: themeProvider.accentColor,
                    onChanged: (value) => settingsProvider.setEnableAutoTextFormatting(value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Developer Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔧 خيارات المطور',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      'خوادم MCP',
                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                    ),
                    subtitle: Text(
                      'تفعيل خوادم Model Context Protocol',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                    value: settingsProvider.enableMcpServers,
                    activeColor: themeProvider.accentColor,
                    onChanged: (value) => settingsProvider.setEnableMcpServers(value),
                  ),
                  if (settingsProvider.enableMcpServers) ...[
                    const SizedBox(height: 12),

                    // عرض خوادم MCP المتاحة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خوادم MCP المتاحة:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: themeProvider.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...settingsProvider.getAvailableMcpServers().map((server) {
                            final isEnabled = settingsProvider.mcpServerStatus[server] ?? false;
                            return Row(
                              children: [
                                Icon(
                                  isEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isEnabled ? Colors.green : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  server,
                                  style: TextStyle(fontFamily: themeProvider.fontFamily),
                                ),
                                const Spacer(),
                                Switch(
                                  value: isEnabled,
                                  onChanged: (value) => settingsProvider.setMcpServerStatus(server, value),
                                  activeColor: themeProvider.accentColor,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDebugInfo(context, themeProvider),
                            icon: const Icon(Icons.bug_report),
                            label: Text(
                              'معلومات التشخيص',
                              style: TextStyle(fontFamily: themeProvider.fontFamily),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.accentColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showMcpConfigDialog(context, themeProvider),
                          icon: const Icon(Icons.settings),
                          label: Text(
                            Localizations.localeOf(context).languageCode == 'ar' ? 'العربية' : 'Arabic',
                            style: TextStyle(fontFamily: themeProvider.fontFamily),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API Keys Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔑 إدارة مفاتيح API',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // عرض حالة المفاتيح
                  FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: ApiKeyManager.getKeysStatus(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final keysStatus = snapshot.data!;
                      return Column(
                        children: [
                          ...keysStatus.entries.map((entry) {
                            final serviceName = entry.key;
                            final status = entry.value;
                            final hasKey = status['hasKey'] as bool;
                            final isValid = status['isValid'] as bool;

                            return ListTile(
                              leading: Icon(
                                hasKey ? (isValid ? Icons.check_circle : Icons.error) : Icons.key_off,
                                color: hasKey ? (isValid ? Colors.green : Colors.red) : Colors.grey,
                              ),
                              title: Text(
                                _getServiceDisplayName(serviceName),
                                style: TextStyle(fontFamily: themeProvider.fontFamily),
                              ),
                              subtitle: Text(
                                hasKey ? (isValid ? 'مفتاح صالح' : 'مفتاح غير صالح') : 'لا يوجد مفتاح',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasKey ? (isValid ? Colors.green : Colors.red) : Colors.grey,
                                  fontFamily: themeProvider.fontFamily,
                                ),
                              ),
                              trailing: hasKey ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteApiKey(context, serviceName, themeProvider),
                              ) : null,
                            );
                          }),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showApiKeysDialog(context),
                                  icon: const Icon(Icons.edit),
                                  label: Text(
                                    'تحرير مفاتيح API',
                                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeProvider.accentColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _confirmClearAllApiKeys(context, themeProvider),
                                icon: const Icon(Icons.clear_all),
                                label: Text(
                                  'مسح الكل',
                                  style: TextStyle(fontFamily: themeProvider.fontFamily),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reset Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔄 إعادة تعيين',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: themeProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showResetDialog(context, settingsProvider, themeProvider),
                    icon: const Icon(Icons.restore),
                    label: Text(
                      'إعادة تعيين جميع الإعدادات',
                      style: TextStyle(fontFamily: themeProvider.fontFamily),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'معلومات التشخيص',
          style: TextStyle(fontFamily: themeProvider.fontFamily),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Flutter Version: ${DateTime.now().toString()}',
                   style: TextStyle(fontFamily: themeProvider.fontFamily)),
              Text('Device: Mobile/Desktop',
                   style: TextStyle(fontFamily: themeProvider.fontFamily)),
              Text('Theme: ${themeProvider.themeMode.name}',
                   style: TextStyle(fontFamily: themeProvider.fontFamily)),
              Text('Font: ${themeProvider.fontFamily}',
                   style: TextStyle(fontFamily: themeProvider.fontFamily)),
              Text('Color: ${_colorToHex(themeProvider.accentColor)}',
                   style: TextStyle(fontFamily: themeProvider.fontFamily)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إغلاق',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد إعادة التعيين',
          style: TextStyle(fontFamily: themeProvider.fontFamily),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontFamily: themeProvider.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset settings manually
              settingsProvider.setModel('llama-3.1-8b-instant');
              settingsProvider.setTemperature(1.0);
              settingsProvider.setMaxTokens(1024);
              
              themeProvider.setThemeMode(ThemeMode.system);
              themeProvider.setFontFamily('Amiri');
              themeProvider.setFontSize(14.0);
              themeProvider.setAccentColor(const Color(0xFFC0E8C1));
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إعادة تعيين الإعدادات بنجاح',
                    style: TextStyle(fontFamily: themeProvider.fontFamily),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'إعادة تعيين',
              style: TextStyle(fontFamily: themeProvider.fontFamily),
            ),
          ),
        ],
      ),
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
                    color: Theme.of(context).colorScheme.onPrimary,
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
            '© 2025 Atlas AI\nجميع الحقوق محفوظة',
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



  Widget _buildInfoCard(String title, String content, IconData icon, DeviceType deviceType, {bool isEmail = false}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: ResponsiveHelper.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(12),
          tablet: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              color: Theme.of(context).colorScheme.primary,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),
                  if (isEmail)
                    GestureDetector(
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: content,
                          query: 'subject=Atlas AI - Report Issue',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      child: Text(
                        content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }

  Widget _buildFeaturesCard(DeviceType deviceType) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: ResponsiveHelper.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(12),
          tablet: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ المميزات الرئيسية',
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
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            _buildFeatureItem('🤖', 'دعم نماذج AI متعددة (GPT, Llama, Mixtral)', deviceType),
            _buildFeatureItem('🌙', 'وضع ليلي ونهاري', deviceType),
            _buildFeatureItem('🎨', 'تخصيص الألوان والخطوط', deviceType),
            _buildFeatureItem('💾', 'حفظ المحادثات تلقائياً', deviceType),
            _buildFeatureItem('⚡', 'أداء سريع ومحسّن', deviceType),
            _buildFeatureItem('🔒', 'حماية وأمان البيانات', deviceType),
            _buildFeatureItem('🎯', 'تدريب النماذج المحلية', deviceType),
            _buildFeatureItem('🌍', 'دعم متعدد اللغات', deviceType),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text, DeviceType deviceType) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getResponsiveHeight(
          context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
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
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }

  // عرض حوار إعدادات MCP
  void _showMcpConfigDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.hub, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    'إعدادات خوادم MCP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // إعدادات عامة
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الإعدادات العامة',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  SwitchListTile(
                                    title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تفعيل خوادم MCP' : 'Enable MCP Servers'),
                                    value: settingsProvider.enableMcpServers,
                                    onChanged: settingsProvider.setEnableMcpServers,
                                  ),
                                  ListTile(
                                    title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مهلة الاتصال' : 'Connection Timeout'),
                                    subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? '10 ثوان' : '10 seconds'),
                                    trailing: const Icon(Icons.timer),
                                  ),
                                  ListTile(
                                    title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة المحاولة' : 'Retry Attempts'),
                                    subtitle: Text(Localizations.localeOf(context).languageCode == 'ar' ? '3 محاولات' : '3 attempts'),
                                    trailing: const Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // خوادم مخصصة
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'خوادم مخصصة',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        icon: const Icon(Icons.add),
                                        label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خادم' : 'Add Server'),
                                        onPressed: () => _showAddCustomMcpServerDialog(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (settingsProvider.customMcpServers.isEmpty)
                                    const Text(
                                      'لا توجد خوادم مخصصة. يمكنك إضافة خوادم MCP مخصصة.',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  else
                                    ...settingsProvider.customMcpServers.entries.map((entry) {
                                      return ListTile(
                                        leading: const Icon(Icons.extension),
                                        title: Text(entry.key),
                                        subtitle: Text(entry.value['command'] ?? 'غير محدد'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => settingsProvider.removeCustomMcpServer(entry.key),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض حوار إضافة خادم MCP مخصص
  void _showAddCustomMcpServerDialog(BuildContext context) {
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
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && commandController.text.isNotEmpty) {
                final args = argsController.text.split(',').map((e) => e.trim()).toList();
                Provider.of<SettingsProvider>(context, listen: false).addCustomMcpServer(
                  nameController.text,
                  commandController.text,
                  args,
                  {},
                );
                Navigator.pop(context);
                Navigator.pop(context); // إغلاق حوار الإعدادات أيضاً
              }
            },
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }
}
