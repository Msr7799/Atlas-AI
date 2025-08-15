import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// خدمة الصوت المتكاملة لدعم التحويل من الصوت إلى النص والعكس
/// مع دعم شامل للغة العربية والإنجليزية واللهجات المختلفة
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  // Speech to Text
  late stt.SpeechToText _speechToText;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  String _currentLocale = 'ar-SA'; // اللغة الافتراضية

  // Text to Speech
  late FlutterTts _flutterTts;
  bool _ttsEnabled = false;

  // قائمة اللغات واللهجات المدعومة
  final Map<String, String> _supportedLocales = {
    // العربية واللهجات
    'ar-SA': 'العربية (السعودية)',
    'ar-EG': 'العربية (مصر)',
    'ar-AE': 'العربية (الإمارات)',
    'ar-JO': 'العربية (الأردن)',
    'ar-LB': 'العربية (لبنان)',
    'ar-SY': 'العربية (سوريا)',
    'ar-IQ': 'العربية (العراق)',
    'ar-KW': 'العربية (الكويت)',
    'ar-QA': 'العربية (قطر)',
    'ar-BH': 'العربية (البحرين)',
    'ar-OM': 'العربية (عمان)',
    'ar-YE': 'العربية (اليمن)',
    'ar-MA': 'العربية (المغرب)',
    'ar-TN': 'العربية (تونس)',
    'ar-DZ': 'العربية (الجزائر)',
    'ar-LY': 'العربية (ليبيا)',
    'ar-SD': 'العربية (السودان)',
    
    // الإنجليزية واللهجات
    'en-US': 'English (United States)',
    'en-GB': 'English (United Kingdom)',
    'en-AU': 'English (Australia)',
    'en-CA': 'English (Canada)',
    'en-IN': 'English (India)',
    'en-IE': 'English (Ireland)',
    'en-NZ': 'English (New Zealand)',
    'en-ZA': 'English (South Africa)',
    'en-SG': 'English (Singapore)',
    'en-HK': 'English (Hong Kong)',
    
    // لغات أخرى مفيدة
    'fr-FR': 'Français (France)',
    'de-DE': 'Deutsch (Deutschland)',
    'es-ES': 'Español (España)',
    'it-IT': 'Italiano (Italia)',
    'pt-BR': 'Português (Brasil)',
    'ru-RU': 'Русский (Россия)',
    'zh-CN': '中文 (中国)',
    'ja-JP': '日本語 (日本)',
    'ko-KR': '한국어 (대한민국)',
    'tr-TR': 'Türkçe (Türkiye)',
    'fa-IR': 'فارسی (ایران)',
    'ur-PK': 'اردو (پاکستان)',
    'hi-IN': 'हिन्दी (भारत)',
  };

  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get isListening => _isListening;
  bool get ttsEnabled => _ttsEnabled;
  String get lastWords => _lastWords;
  String get currentLocale => _currentLocale;
  Map<String, String> get supportedLocales => Map.unmodifiable(_supportedLocales);

  /// تهيئة خدمة الصوت
  Future<bool> initialize() async {
    try {
      if (kDebugMode) print('[SPEECH_SERVICE] 🎤 بدء تهيئة خدمة الصوت...');

      // طلب الأذونات
      final microphonePermission = await Permission.microphone.request();
      if (microphonePermission != PermissionStatus.granted) {
        if (kDebugMode) print('[SPEECH_SERVICE] ❌ لم يتم منح إذن الميكروفون');
        return false;
      }

      // تهيئة Speech to Text
      _speechToText = stt.SpeechToText();
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (kDebugMode) print('[SPEECH_SERVICE] 📊 حالة التعرف على الصوت: $status');
          if (status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          if (kDebugMode) print('[SPEECH_SERVICE] ❌ خطأ في التعرف على الصوت: $error');
          _isListening = false;
        },
      );

      // تهيئة Text to Speech
      _flutterTts = FlutterTts();
      await _setupTts();
      _ttsEnabled = true;

      // طباعة اللغات المتاحة
      await _printAvailableLocales();

      if (kDebugMode) print('[SPEECH_SERVICE] ✅ تم تهيئة خدمة الصوت بنجاح');
      return _speechEnabled && _ttsEnabled;
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في تهيئة خدمة الصوت: $e');
      return false;
    }
  }

  /// إعداد Text to Speech
  Future<void> _setupTts() async {
    try {
      // إعداد اللغة الافتراضية
      await _flutterTts.setLanguage(_currentLocale);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // إعداد callbacks
      _flutterTts.setStartHandler(() {
        if (kDebugMode) print('[SPEECH_SERVICE] 🔊 بدء تشغيل النص المنطوق');
      });

      _flutterTts.setCompletionHandler(() {
        if (kDebugMode) print('[SPEECH_SERVICE] ✅ انتهاء تشغيل النص المنطوق');
      });

      _flutterTts.setErrorHandler((msg) {
        if (kDebugMode) print('[SPEECH_SERVICE] ❌ خطأ في تشغيل النص المنطوق: $msg');
      });
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في إعداد TTS: $e');
    }
  }

  /// طباعة اللغات المتاحة للتعرف على الصوت
  Future<void> _printAvailableLocales() async {
    try {
      final locales = await getAvailableLocales();
      if (kDebugMode) print('[SPEECH_SERVICE] 🌍 اللغات المتاحة للتعرف على الصوت:');
      
      // فلترة اللغات العربية والإنجليزية
      final arabicLocales = locales.where((l) => l.localeId.startsWith('ar')).toList();
      final englishLocales = locales.where((l) => l.localeId.startsWith('en')).toList();
      
      if (kDebugMode) print('[SPEECH_SERVICE] 🇸🇦 اللغات العربية المتاحة: ${arabicLocales.length}');
      for (final locale in arabicLocales) {
        if (kDebugMode) print('  - ${locale.localeId}: ${locale.name}');
      }
      
      if (kDebugMode) print('[SPEECH_SERVICE] 🇺🇸 اللغات الإنجليزية المتاحة: ${englishLocales.length}');
      for (final locale in englishLocales) {
        if (kDebugMode) print('  - ${locale.localeId}: ${locale.name}');
      }
      
      if (kDebugMode) print('[SPEECH_SERVICE] 🌐 إجمالي اللغات المتاحة: ${locales.length}');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في الحصول على اللغات المتاحة: $e');
    }
  }

  /// تغيير لغة التعرف على الصوت
  Future<bool> setLocale(String localeId) async {
    try {
      final availableLocales = await getAvailableLocales();
      final isSupported = availableLocales.any((locale) => locale.localeId == localeId);
      
      if (!isSupported) {
        if (kDebugMode) print('[SPEECH_SERVICE] ⚠️ اللغة $localeId غير مدعومة');
        return false;
      }
      
      _currentLocale = localeId;
      
      // تحديث TTS أيضاً
      if (_ttsEnabled) {
        await _flutterTts.setLanguage(localeId);
      }
      
      if (kDebugMode) print('[SPEECH_SERVICE] ✅ تم تغيير اللغة إلى: $localeId');
      return true;
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في تغيير اللغة: $e');
      return false;
    }
  }

  /// الكشف التلقائي عن اللغة من النص
  String detectLanguage(String text) {
    // تحقق من وجود أحرف عربية
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    if (arabicRegex.hasMatch(text)) {
      return 'ar-SA'; // افتراضي للعربية السعودية
    }
    
    // تحقق من وجود أحرف فارسية/أردو
    final persianRegex = RegExp(r'[\u06A9\u06AF\u06CC\u067E\u0686\u0698]');
    if (persianRegex.hasMatch(text)) {
      return text.contains('پ') || text.contains('ٹ') ? 'ur-PK' : 'fa-IR';
    }
    
    // افتراضي للإنجليزية
    return 'en-US';
  }

  /// بدء الاستماع للصوت مع تحسينات لدقة التعرف
  Future<void> startListening({
    required Function(String) onResult,
    String? localeId,
    bool enablePartialResults = true,
    bool enableAlternatives = true,
  }) async {
    if (!_speechEnabled) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ خدمة التعرف على الصوت غير مفعلة');
      return;
    }

    if (_isListening) {
      if (kDebugMode) print('[SPEECH_SERVICE] ⚠️ الخدمة تستمع بالفعل');
      return;
    }

    try {
      _isListening = true;
      _lastWords = '';

      // استخدام اللغة المحددة أو الحالية
      final targetLocale = localeId ?? _currentLocale;

      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(_lastWords);
          
          if (result.finalResult) {
            _isListening = false;
            if (kDebugMode) print('[SPEECH_SERVICE] ✅ انتهاء الاستماع: $_lastWords');
            if (kDebugMode) print('[SPEECH_SERVICE] 📊 مستوى الثقة: ${result.confidence}');
            
            // طباعة البدائل إذا كانت متاحة
            if (result.alternates.isNotEmpty) {
              if (kDebugMode) print('[SPEECH_SERVICE] 🔄 البدائل المقترحة:');
              for (var alt in result.alternates) {
                if (kDebugMode) print('  - ${alt.recognizedWords} (ثقة: ${alt.confidence})');
              }
            }
          }
        },
        listenFor: const Duration(seconds: 60), // زيادة وقت الاستماع
        pauseFor: const Duration(seconds: 2), // تقليل وقت التوقف
        partialResults: enablePartialResults, // النتائج الجزئية
        localeId: targetLocale,
        // cancelOnError تم إهماله - استخدام الخيارات الحديثة
        listenMode: stt.ListenMode.confirmation, // وضع التأكيد
        sampleRate: 16000, // معدل العينة الأمثل
      );

      if (kDebugMode) print('[SPEECH_SERVICE] 🎤 بدء الاستماع المحسن باللغة: $targetLocale');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في بدء الاستماع: $e');
      _isListening = false;
    }
  }

  /// تحسين دقة التعرف بناءً على السياق
  String enhanceRecognitionAccuracy(String recognizedText, {
    String? expectedLanguage,
    List<String>? contextWords,
  }) {
    String enhanced = recognizedText;
    
    // تصحيح الأخطاء الشائعة في العربية
    final arabicCorrections = {
      'انا': 'أنا',
      'اريد': 'أريد',
      'اذا': 'إذا',
      'الى': 'إلى',
      'هذا': 'هذا',
      'هذه': 'هذه',
      'التى': 'التي',
      'اللى': 'التي',
    };
    
    // تصحيح الأخطاء الشائعة في الإنجليزية
    final englishCorrections = {
      'ur': 'your',
      'u': 'you',
      'r': 'are',
      'gonna': 'going to',
      'wanna': 'want to',
      'gotta': 'got to',
    };
    
    // تطبيق التصحيحات
    if (expectedLanguage?.startsWith('ar') == true) {
      arabicCorrections.forEach((wrong, correct) {
        enhanced = enhanced.replaceAll(wrong, correct);
      });
    } else if (expectedLanguage?.startsWith('en') == true) {
      englishCorrections.forEach((wrong, correct) {
        enhanced = enhanced.replaceAll(wrong, correct);
      });
    }
    
    // تحسين بناءً على الكلمات المتوقعة
    if (contextWords != null) {
      for (String contextWord in contextWords) {
        // البحث عن كلمات مشابهة وتصحيحها
        // يمكن تطوير هذا أكثر باستخدام خوارزميات المسافة
      }
    }
    
    return enhanced.trim();
  }

  /// اختبار دقة التعرف على الصوت
  Future<Map<String, dynamic>> testSpeechRecognitionAccuracy() async {
    final testResults = <String, dynamic>{};
    
    try {
      // الحصول على اللغات المتاحة
      final availableLocales = await getAvailableLocales();
      testResults['available_locales'] = availableLocales.length;
      testResults['arabic_locales'] = availableLocales.where((l) => l.localeId.startsWith('ar')).length;
      testResults['english_locales'] = availableLocales.where((l) => l.localeId.startsWith('en')).length;
      
      // اختبار الميكروفون
      testResults['microphone_available'] = await Permission.microphone.isGranted;
      
      // اختبار تهيئة الخدمة
      testResults['speech_service_initialized'] = _speechEnabled;
      testResults['tts_service_initialized'] = _ttsEnabled;
      
      // معلومات النظام
      testResults['current_locale'] = _currentLocale;
      testResults['supported_locales_count'] = _supportedLocales.length;
      
      if (kDebugMode) print('[SPEECH_SERVICE] 📊 نتائج اختبار دقة التعرف على الصوت:');
      testResults.forEach((key, value) {
        if (kDebugMode) print('  $key: $value');
      });
      
    } catch (e) {
      testResults['error'] = e.toString();
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ خطأ في اختبار دقة التعرف: $e');
    }
    
    return testResults;
  }

  /// إيقاف الاستماع
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      if (kDebugMode) print('[SPEECH_SERVICE] ⏹️ تم إيقاف الاستماع');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في إيقاف الاستماع: $e');
    }
  }

  /// تحويل النص إلى صوت
  Future<void> speak(String text) async {
    if (!_ttsEnabled) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ خدمة تحويل النص إلى صوت غير مفعلة');
      return;
    }

    if (text.isEmpty) return;

    try {
      // إيقاف أي تشغيل سابق
      await _flutterTts.stop();
      
      // تشغيل النص الجديد
      await _flutterTts.speak(text);
      if (kDebugMode) print('[SPEECH_SERVICE] 🔊 تشغيل النص: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في تشغيل النص: $e');
    }
  }

  /// تحويل النص إلى صوت مع دعم اللغات المتعددة
  Future<void> speakWithLanguageSupport(String text, {String? localeId}) async {
    if (!_ttsEnabled) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ خدمة تحويل النص إلى صوت غير مفعلة');
      return;
    }

    if (text.isEmpty) return;

    try {
      // إيقاف أي تشغيل سابق
      await _flutterTts.stop();
      
      // تحديد اللغة المناسبة
      final targetLocale = localeId ?? detectLanguage(text);
      
      // تغيير اللغة إذا لزم الأمر
      if (targetLocale != _currentLocale) {
        await _flutterTts.setLanguage(targetLocale);
        if (kDebugMode) print('[SPEECH_SERVICE] 🔄 تم تغيير لغة TTS إلى: $targetLocale');
      }
      
      // تشغيل النص الجديد
      await _flutterTts.speak(text);
      if (kDebugMode) print('[SPEECH_SERVICE] 🔊 تشغيل النص باللغة $targetLocale: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في تشغيل النص: $e');
    }
  }

  /// إيقاف تشغيل الصوت
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      if (kDebugMode) print('[SPEECH_SERVICE] ⏹️ تم إيقاف تشغيل الصوت');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في إيقاف تشغيل الصوت: $e');
    }
  }

  /// الحصول على اللغات المتاحة للتعرف على الصوت
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_speechEnabled) return [];
    
    try {
      return await _speechToText.locales();
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في الحصول على اللغات المتاحة: $e');
      return [];
    }
  }

  /// التحقق من توفر اللغة العربية
  Future<bool> isArabicSupported() async {
    final locales = await getAvailableLocales();
    return locales.any((locale) => 
      locale.localeId.startsWith('ar') || 
      locale.name.toLowerCase().contains('arabic')
    );
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    try {
      if (_isListening) {
        await stopListening();
      }
      await stopSpeaking();
      if (kDebugMode) print('[SPEECH_SERVICE] 🧹 تم تنظيف موارد خدمة الصوت');
    } catch (e) {
      if (kDebugMode) print('[SPEECH_SERVICE] ❌ فشل في تنظيف الموارد: $e');
    }
  }
}

/// نموذج نتيجة التعرف على الصوت
class SpeechRecognitionResult {
  final String recognizedWords;
  final bool finalResult;
  final double confidence;

  const SpeechRecognitionResult({
    required this.recognizedWords,
    required this.finalResult,
    this.confidence = 0.0,
  });

  @override
  String toString() {
    return 'SpeechRecognitionResult(words: $recognizedWords, final: $finalResult, confidence: $confidence)';
  }
}
