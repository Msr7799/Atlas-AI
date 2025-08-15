import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


/// شاشة الترحيب المحسنة
class ChatWelcomeScreen extends StatelessWidget {
  final dynamic controllers; // _ChatControllers
  final dynamic animations; // _ChatAnimations

  const ChatWelcomeScreen({
    super.key,
    required this.controllers,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacing16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWelcomeIcon(),
            const SizedBox(height: UIConstants.spacing24),
            _buildWelcomeText(context),
            const SizedBox(height: UIConstants.spacing32),
            _buildWelcomeChips(context),
          ],
        ),
      ),
    );
  }

  /// بناء أيقونة الترحيب
  Widget _buildWelcomeIcon() {
    return Image.asset(
      UIConstants.neonChatIcon,
      width: UIConstants.iconSize64,
      height: UIConstants.iconSize64,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.code_rounded,
          size: UIConstants.iconSize64,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        );
      },
    ).animate().scale(duration: 1000.ms);
  }

  /// بناء نص الترحيب
  Widget _buildWelcomeText(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headlineSmall!,
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'هلا بلي له الخافق يهلي 🚀',
            speed: const Duration(milliseconds: 80),
          ),
          TypewriterAnimatedText(
            'مساعدك أطلس يسموني ابوالعريف باجاوب جميع أسئلتك 🤖',
            speed: const Duration(milliseconds: 80),
          ),
          TypewriterAnimatedText(
            'قول أسأل عن أي شي أيي في بالك؟ 💭',
            speed: const Duration(milliseconds: 80),
          ),
          TypewriterAnimatedText(
            'قول اللي في قلبك أنا واحد مافتن ! 🌟',
            speed: const Duration(milliseconds: 80),
          ),
        ],
        isRepeatingAnimation: true,
        pause: const Duration(seconds: 3),
      ),
    );
  }

  /// بناء رقائق الترحيب
  Widget _buildWelcomeChips(BuildContext context) {
    final chips = _getWelcomeChips();
    
    return Wrap(
      spacing: UIConstants.spacing8,
      runSpacing: UIConstants.spacing8,
      alignment: WrapAlignment.center,
      children: chips.map((chip) => _buildNeonChip(context, chip)).toList(),
    );
  }

  /// الحصول على رقائق الترحيب
  List<_WelcomeChip> _getWelcomeChips() {
    return [
      _WelcomeChip(
        icon: Icons.code_rounded,
        text: 'البرمجة',
        color: const Color(UIConstants.primaryBlue),
        prompt: 'أبيك تبرمج لي: ',
      ),
      _WelcomeChip(
        icon: Icons.analytics_rounded,
        text: 'تحليل البيانات',
        color: const Color(UIConstants.accentGreen),
        prompt: 'حلل هذي الويه: ',
      ),
      _WelcomeChip(
        icon: Icons.translate_rounded,
        text: 'الترجمة',
        color: const Color(UIConstants.warningRed),
        prompt: 'ترجم هذي: ',
      ),
      _WelcomeChip(
        icon: Icons.lightbulb_outline_rounded,
        text: 'أفكار إبداعية',
        color: const Color(UIConstants.darkRed),
        prompt: 'عطني افكارك وأتحفي في  ',
      ),
      _WelcomeChip(
        icon: Icons.school_rounded,
        text: 'التعلم',
        color: const Color(UIConstants.purple),
        prompt: 'أبيك تعلمني على  ',
      ),
    ];
  }

  /// بناء رقاقة نيون
  Widget _buildNeonChip(BuildContext context, _WelcomeChip chip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.borderRadius25),
        border: Border.all(color: chip.color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: chip.color.withOpacity(isDark ? UIConstants.opacityMediumHigh : UIConstants.opacityMediumLight),
            blurRadius: isDark ? 8 : 6,
            spreadRadius: isDark ? 1 : 0,
          ),
        ],
      ),
      child: Material(
        color: isDark 
            ? chip.color.withOpacity(UIConstants.opacityLight) 
            : chip.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(UIConstants.borderRadius25),
        child: InkWell(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius25),
          onTap: () => _onChipTap(chip.prompt),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacing12,
              vertical: UIConstants.spacing8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  chip.icon,
                  size: UIConstants.iconSize16,
                  color: chip.color,
                ),
                const SizedBox(width: 6),
                Text(
                  chip.text,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: UIConstants.fontSize12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8))
        .then()
        .shimmer(duration: 2000.ms, color: chip.color.withOpacity(UIConstants.opacityMediumHigh));
  }

  /// معالجة الضغط على الرقاقة
  void _onChipTap(String prompt) {
    controllers.messageController.text = prompt;
    controllers.textFieldFocusNode.requestFocus();
  }
}

/// نموذج بيانات رقاقة الترحيب
class _WelcomeChip {
  final IconData icon;
  final String text;
  final Color color;
  final String prompt;

  const _WelcomeChip({
    required this.icon,
    required this.text,
    required this.color,
    required this.prompt,
  });
}
