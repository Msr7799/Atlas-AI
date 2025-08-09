import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/speech_service.dart';

/// Widget لاختيار لغة التعرف على الصوت
class LanguageSelectorWidget extends StatefulWidget {
  final Function(String localeId, String displayName)? onLanguageChanged;
  final String? currentLocale;

  const LanguageSelectorWidget({
    super.key,
    this.onLanguageChanged,
    this.currentLocale,
  });

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  final SpeechService _speechService = SpeechService();
  String _selectedLocale = 'ar-SA';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale ?? 'ar-SA';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportedLocales = _speechService.supportedLocales;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لغة التعرف على الصوت',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          supportedLocales[_selectedLocale] ?? _selectedLocale,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // Language List
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // العربية
                    _buildLanguageSection(
                      context,
                      'العربية واللهجات',
                      Icons.flag,
                      supportedLocales.entries
                          .where((entry) => entry.key.startsWith('ar'))
                          .toList(),
                    ),
                    
                    // الإنجليزية
                    _buildLanguageSection(
                      context,
                      'English & Dialects',
                      Icons.flag_outlined,
                      supportedLocales.entries
                          .where((entry) => entry.key.startsWith('en'))
                          .toList(),
                    ),
                    
                    // لغات أخرى
                    _buildLanguageSection(
                      context,
                      'لغات أخرى',
                      Icons.public,
                      supportedLocales.entries
                          .where((entry) => 
                              !entry.key.startsWith('ar') && 
                              !entry.key.startsWith('en'))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate()
     .fadeIn(duration: 300.ms)
     .slideY(begin: 0.3, end: 0);
  }

  Widget _buildLanguageSection(
    BuildContext context,
    String title,
    IconData icon,
    List<MapEntry<String, String>> languages,
  ) {
    if (languages.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Languages
        ...languages.asMap().entries.map((entry) => _buildLanguageItem(
          context,
          entry.value.key,
          entry.value.value,
          index: entry.key,
        )),
      ],
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    String localeId,
    String displayName, {
    int index = 0,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedLocale == localeId;

    return InkWell(
      onTap: () async {
        setState(() {
          _selectedLocale = localeId;
          _isExpanded = false;
        });

        // تحديث خدمة الصوت
        final success = await _speechService.setLocale(localeId);
        if (success) {
          widget.onLanguageChanged?.call(localeId, displayName);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تغيير اللغة إلى: $displayName'),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل في تغيير اللغة إلى: $displayName'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: isSelected ? Border(
            right: BorderSide(
              color: theme.colorScheme.primary,
              width: 3,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            // Flag or indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.language,
                size: 14,
                color: isSelected 
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 12),
            
            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    localeId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.radio_button_checked,
                color: theme.colorScheme.primary,
                size: 20,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: theme.colorScheme.outline.withOpacity(0.5),
                size: 20,
              ),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms)
     .fadeIn(duration: 200.ms)
     .slideX(begin: 0.3, end: 0);
  }
}

/// Dialog لاختيار اللغة
class LanguageSelectorDialog extends StatelessWidget {
  final String? currentLocale;
  final Function(String localeId, String displayName)? onLanguageChanged;

  const LanguageSelectorDialog({
    super.key,
    this.currentLocale,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اختيار لغة التعرف على الصوت',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: LanguageSelectorWidget(
                currentLocale: currentLocale,
                onLanguageChanged: (localeId, displayName) {
                  onLanguageChanged?.call(localeId, displayName);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(duration: 300.ms)
     .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}
