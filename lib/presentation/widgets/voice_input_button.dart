import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/speech_service.dart';

/// زر إدخال الصوت مع تأثيرات بصرية متقدمة
class VoiceInputButton extends StatefulWidget {
  final Function(String) onSpeechResult;
  final VoidCallback? onStartListening;
  final VoidCallback? onStopListening;
  final bool enabled;
  final Color? primaryColor;
  final Color? accentColor;

  const VoiceInputButton({
    super.key,
    required this.onSpeechResult,
    this.onStartListening,
    this.onStopListening,
    this.enabled = true,
    this.primaryColor,
    this.accentColor,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  
  bool _isListening = false;
  bool _isInitialized = false;
  String _currentText = '';
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeechService();
  }

  void _initializeAnimations() {
    // Animation للنبضة
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animation للموجات
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeSpeechService() async {
    try {
      final initialized = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = initialized;
        });
      }
      
      if (!initialized) {
        _showErrorSnackBar('فشل في تهيئة خدمة الصوت. تأكد من منح الأذونات المطلوبة.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ في تهيئة خدمة الصوت: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized || !widget.enabled) return;

    try {
      if (_isListening) {
        await _stopListening();
      } else {
        await _startListening();
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في التحكم بالصوت: $e');
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _currentText = '';
    });

    // بدء الانيميشن
    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    // استدعاء callback
    widget.onStartListening?.call();

    // بدء الاستماع
    await _speechService.startListening(
      onResult: (result) {
        setState(() {
          _currentText = result;
        });
        
        // إذا كانت النتيجة نهائية، أرسلها وأوقف الاستماع
        if (result.isNotEmpty && !_speechService.isListening) {
          widget.onSpeechResult(result);
          _stopListening();
        }
      },
    );
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
    });

    // إيقاف الانيميشن
    _pulseController.stop();
    _waveController.stop();

    // إيقاف الاستماع
    await _speechService.stopListening();

    // استدعاء callback
    widget.onStopListening?.call();

    // إرسال النتيجة النهائية إذا وجدت
    if (_currentText.isNotEmpty) {
      widget.onSpeechResult(_currentText);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final accentColor = widget.accentColor ?? theme.colorScheme.secondary;

    return GestureDetector(
      onTap: _toggleListening,
      onLongPress: _toggleListening,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الموجات الخارجية (تظهر أثناء الاستماع)
            if (_isListening) ...[
              _buildWaveCircle(radius: 35, opacity: 0.1),
              _buildWaveCircle(radius: 45, opacity: 0.08, delay: 200),
              _buildWaveCircle(radius: 55, opacity: 0.06, delay: 400),
            ],

            // الزر الأساسي
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isListening
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : _isInitialized
                                ? [primaryColor, accentColor]
                                : [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),

            // مؤشر النشاط
            if (_isListening)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 1000.ms, color: Colors.red.shade300),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveCircle({
    required double radius,
    required double opacity,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          width: radius * 2 * _waveAnimation.value,
          height: radius * 2 * _waveAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (widget.primaryColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(opacity * (1 - _waveAnimation.value)),
              width: 2,
            ),
          ),
        );
      },
    ).animate(delay: delay.ms);
  }
}

/// Widget لعرض النص المُتعرف عليه أثناء التسجيل
class VoiceInputDisplay extends StatelessWidget {
  final String text;
  final bool isListening;

  const VoiceInputDisplay({
    super.key,
    required this.text,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    if (!isListening && text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.mic,
            color: isListening ? Colors.red : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.isEmpty ? 'جاري الاستماع...' : text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
                color: text.isEmpty 
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (isListening)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    ).animate()
     .fadeIn(duration: 300.ms)
     .slideY(begin: 0.3, end: 0);
  }
}
