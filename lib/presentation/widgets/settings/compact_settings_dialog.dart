import 'package:flutter/material.dart';
import 'settings_sections.dart';

/// حوار إعدادات مبسط ومحسن
class CompactSettingsDialog extends StatelessWidget {
  const CompactSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.settings, size: 28),
                const SizedBox(width: 12),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? 'الإعدادات' : 'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ModelSettingsSection(),
                    ThemeSettingsSection(),
                    AudioSettingsSection(),
                    AdvancedSettingsSection(),
                    AppInfoSection(),
                  ],
                ),
              ),
            ),
            
            // Footer
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تعيين' : 'Reset'),
                  onPressed: () => _showResetDialog(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حفظ' : 'Save'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم حفظ الإعدادات' : 'Settings saved')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تعيين الإعدادات' : 'Reset Settings'),
        content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'هل تريد إعادة تعيين جميع الإعدادات للقيم الافتراضية؟' : 'Do you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // إعادة تعيين الإعدادات
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم إعادة تعيين الإعدادات' : 'Settings reset')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تعيين' : 'Reset'),
          ),
        ],
      ),
    );
  }

  /// عرض الحوار
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CompactSettingsDialog(),
    );
  }
}

/// إعدادات سريعة في شريط جانبي
class QuickSettingsPanel extends StatelessWidget {
  const QuickSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Localizations.localeOf(context).languageCode == 'ar' ? 'إعدادات سريعة' : 'Quick Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ModelSettingsSection(),
                  SizedBox(height: 8),
                  ThemeSettingsSection(),
                  SizedBox(height: 8),
                  AudioSettingsSection(),
                  SizedBox(height: 8),
                  McpServersSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// زر إعدادات عائم مبسط
class FloatingSettingsButton extends StatelessWidget {
  const FloatingSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      heroTag: "settings",
      onPressed: () => CompactSettingsDialog.show(context),
      child: const Icon(Icons.settings),
    );
  }
}
