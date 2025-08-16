import '../debug_panel.dart';
import '../settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/ui_constants.dart';
import '../../providers/chat_provider.dart';
import '../../pages/api_settings_page.dart';
import '../../providers/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/chat_selection_provider.dart';
import '../../pages/advanced_model_training_page.dart';
import '../../../generated/l10n/app_localizations.dart';

/// شريط التطبيق المحسن للمحادثة
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic controllers; // _ChatControllers
  final dynamic animations; // _ChatAnimations
  final dynamic chatState; // _ChatState

  const ChatAppBar({
    super.key,
    required this.controllers,
    required this.animations,
    required this.chatState,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// دالة ذكية لحساب التباين حسب الوضع الليلي/النهاري
  List<Color> _getSmartGradientColors(Color baseColor, bool isDarkMode) {
    // حساب سطوع اللون
    final luminance = baseColor.computeLuminance();

    if (isDarkMode) {
      // في الوضع الليلي: نجعل الألوان الفاتحة أغمق والألوان الغامقة أفتح
      if (luminance > 0.5) {
        // لون فاتح - نجعله أغمق
        return [
          Color.fromRGBO(
            (baseColor.red * 0.7).round(),
            (baseColor.green * 0.7).round(),
            (baseColor.blue * 0.7).round(),
            1.0,
          ),
          Color.fromRGBO(
            (baseColor.red * 0.5).round(),
            (baseColor.green * 0.5).round(),
            (baseColor.blue * 0.5).round(),
            1.0,
          ),
        ];
      } else {
        // لون غامق - نجعله أفتح قليلاً
        return [
          baseColor,
          Color.fromRGBO(
            (baseColor.red + (255 - baseColor.red) * 0.3).round(),
            (baseColor.green + (255 - baseColor.green) * 0.3).round(),
            (baseColor.blue + (255 - baseColor.blue) * 0.3).round(),
            1.0,
          ),
        ];
      }
    } else {
      // في الوضع النهاري: نستخدم اللون كما هو مع تدرج طبيعي
      return [
        baseColor,
        Color.fromRGBO(
          (baseColor.red * 0.8).round(),
          (baseColor.green * 0.8).round(),
          (baseColor.blue * 0.8).round(),
          1.0,
        ),
      ];
    }
  }

  /// دالة لحساب لون النص المناسب حسب خلفية اللون
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// دالة لحساب لون الأيقونة مع التباين الذكي
  Color _getSmartIconColor(Color baseColor, bool isDarkMode) {
    final luminance = baseColor.computeLuminance();

    if (isDarkMode) {
      // في الوضع الليلي: إذا كان اللون غامق جداً، نفتحه
      if (luminance < 0.3) {
        return Color.fromRGBO(
          (baseColor.red + (255 - baseColor.red) * 0.6).round(),
          (baseColor.green + (255 - baseColor.green) * 0.6).round(),
          (baseColor.blue + (255 - baseColor.blue) * 0.6).round(),
          1.0,
        );
      } else {
        return baseColor;
      }
    } else {
      // في الوضع النهاري: نستخدم اللون كما هو
      return baseColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final smartIconColor = _getSmartIconColor(
          themeProvider.accentColor,
          isDarkMode,
        );

        return AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(UIConstants.darkBackground),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: UIConstants.elevation0,
          iconTheme: IconThemeData(
            color: smartIconColor, // استخدام اللون الذكي
          ),
          title: _buildTitle(context),
          actions: _buildActions(context),
        );
      },
    );
  }

  /// بناء عنوان شريط التطبيق
  Widget _buildTitle(BuildContext context) {
    return FadeTransition(
      opacity: animations.fadeAnimation,
      child: SlideTransition(
        position: animations.slideAnimation,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '',
                style: TextStyle(
                  fontSize: UIConstants.fontSize18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color.fromARGB(
                        255,
                        230,
                        225,
                        225,
                      ).withOpacity(UIConstants.opacityMediumHigh),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
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

  /// بناء إجراءات شريط التطبيق
  List<Widget> _buildActions(BuildContext context) {
    return [
      _ChatSelectionActions(controllers: controllers),
      _DebugAction(),
      const SizedBox(width: UIConstants.spacing4),
      _ThemeToggle(),
      const SizedBox(width: UIConstants.spacing12),
      _SettingsAction(),
      const SizedBox(width: UIConstants.spacing12),
      _ModelTrainingAction(),
      const SizedBox(width: UIConstants.spacing12),
      _NewChatAction(),
      const SizedBox(width: UIConstants.spacing12),
      _ApiSettingsAction(),
    ];
  }
}

/// إجراءات تحديد المحادثات
class _ChatSelectionActions extends StatelessWidget {
  final dynamic controllers;

  const _ChatSelectionActions({required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatSelectionProvider>(
      builder: (context, selectionProvider, child) {
        if (!selectionProvider.isSelectionMode) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context,
              icon: Icons.close,
              onPressed: selectionProvider.disableSelectionMode,
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'إلغاء التحديد'
                  : 'Cancel Selection',
            ),
            _buildActionButton(
              context,
              icon: selectionProvider.selectedMessageIds.isEmpty
                  ? Icons.select_all
                  : Icons.deselect,
              onPressed: () => _handleSelectAll(context, selectionProvider),
              tooltip: selectionProvider.selectedMessageIds.isEmpty
                  ? (Localizations.localeOf(context).languageCode == 'ar'
                        ? 'تحديد الكل'
                        : 'Select All')
                  : (Localizations.localeOf(context).languageCode == 'ar'
                        ? 'إلغاء تحديد الكل'
                        : 'Deselect All'),
            ),
            _buildSelectionCounter(context, selectionProvider),
            const SizedBox(width: UIConstants.spacing8),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: UIConstants.iconSize32,
        minHeight: UIConstants.iconSize32,
      ),
    );
  }

  Widget _buildSelectionCounter(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacing8,
        vertical: UIConstants.spacing4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(UIConstants.borderRadius12),
      ),
      child: Text(
        '${selectionProvider.selectedMessageIds.length}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: UIConstants.fontSize12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }

  void _handleSelectAll(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    final chatProvider = context.read<ChatProvider>();
    if (selectionProvider.selectedMessageIds.isEmpty) {
      for (final message in chatProvider.messages) {
        selectionProvider.selectMessage(message.id);
      }
    } else {
      selectionProvider.disableSelectionMode();
    }
  }
}

/// زر التشخيص
class _DebugAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return _buildSmartContrastIcon(
          context,
          icon: Icons.bug_report,
          customColor: chatProvider.debugMode
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          onPressed: () {
            chatProvider.toggleDebugMode();
            if (chatProvider.debugMode) {
              _showAdvancedDebugPanel(context);
            }
          },
          tooltip: Localizations.localeOf(context).languageCode == 'ar'
              ? 'التشخيص المتقدم'
              : 'Advanced Debug',
        );
      },
    );
  }

  void _showAdvancedDebugPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const DebugPanel(),
    );
  }
}

/// زر تبديل الثيم
class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _buildSmartContrastIcon(
          context,
          icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          onPressed: themeProvider.toggleTheme,
          tooltip: Localizations.localeOf(context).languageCode == 'ar'
              ? 'تبديل المظهر'
              : 'Toggle Theme',
        );
      },
    );
  }
}

/// زر الإعدادات
class _SettingsAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSmartContrastIcon(
      context,
      icon: Icons.settings,
      onPressed: () => _showSettingsDialog(context),
      tooltip: Localizations.localeOf(context).languageCode == 'ar'
          ? 'الإعدادات'
          : 'Settings',
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }
}

/// زر تدريب النموذج
class _ModelTrainingAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSmartContrastIcon(
      context,
      icon: Icons.model_training,
      onPressed: () => _navigateToTraining(context),
      tooltip: Localizations.localeOf(context).languageCode == 'ar'
          ? 'تدريب النموذج'
          : 'Model Training',
    );
  }

  void _navigateToTraining(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedModelTrainingPage(),
      ),
    );
  }
}

/// زر محادثة جديدة
class _NewChatAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSmartContrastIcon(
      context,
      icon: Icons.add_circle_outline,
      onPressed: () => context.read<ChatProvider>().createNewSession(),
      tooltip: Localizations.localeOf(context).languageCode == 'ar'
          ? 'محادثة جديدة'
          : 'New Chat',
    );
  }
}

/// زر إعدادات API
class _ApiSettingsAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSmartContrastIcon(
      context,
      icon: Icons.api,
      onPressed: () => _navigateToApiSettings(context),
      tooltip: Localizations.localeOf(context).languageCode == 'ar'
          ? 'إعدادات API'
          : 'API Settings',
    );
  }

  void _navigateToApiSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApiSettingsPage()),
    );
  }
}

/// دالة مساعدة لبناء أيقونة ذكية
Widget _buildSmartContrastIcon(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onPressed,
  required String tooltip,
  Color? customColor,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(UIConstants.borderRadius8),
      color: Colors.transparent,
    ),
    child: IconButton(
      icon: Icon(
        icon,
        color: customColor ?? Colors.white,
        size: UIConstants.iconSize20,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: UIConstants.iconSize32,
        minHeight: UIConstants.iconSize32,
      ),
    ),
  ).animate().fadeIn(duration: 300.ms);
}
