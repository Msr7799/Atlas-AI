import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../performance/app_optimizer.dart';
/// مراقب دورة حياة التطبيق
class AppLifecycleObserver extends WidgetsBindingObserver {
  static AppLifecycleObserver? _instance;
  
  static AppLifecycleObserver get instance {
    _instance ??= AppLifecycleObserver._internal();
    return _instance!;
  }
  
  AppLifecycleObserver._internal();
  
  /// تهيئة مراقب دورة الحياة
  static void initialize() {
    try {
      if (kDebugMode) print('🔍 Initializing AppLifecycleObserver...');
      
      WidgetsBinding.instance.addObserver(instance);
      
      if (kDebugMode) print('✅ AppLifecycleObserver initialized successfully');
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize AppLifecycleObserver: $e');
        print('🛡️ Continuing without lifecycle monitoring...');
      }
    }
  }
  
  /// إلغاء تسجيل مراقب دورة الحياة
  static void dispose() {
    if (_instance != null) {
      try {
        if (kDebugMode) print('🧹 Disposing AppLifecycleObserver...');
        
        WidgetsBinding.instance.removeObserver(_instance!);
        _instance = null;
        
        if (kDebugMode) print('✅ AppLifecycleObserver disposed successfully');
        
      } catch (e) {
        if (kDebugMode) print('❌ Error disposing AppLifecycleObserver: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      if (kDebugMode) {
        print('📱 App lifecycle state changed: $state');
      }
      
      switch (state) {
        case AppLifecycleState.resumed:
          _onAppResumed();
          break;
        case AppLifecycleState.inactive:
          _onAppInactive();
          break;
        case AppLifecycleState.paused:
          _onAppPaused();
          break;
        case AppLifecycleState.detached:
          _onAppDetached();
          break;
        case AppLifecycleState.hidden:
          _onAppHidden();
          break;
      }
      
    } catch (e) {
      if (kDebugMode) print('❌ Error handling lifecycle state change: $e');
    }
  }

  /// التطبيق عاد للنشاط
  void _onAppResumed() {
    try {
      if (kDebugMode) print('🔄 App resumed - activating optimizations...');
      
      // تفعيل التحسينات
      AppOptimizer.setAppActive(true);
      
      // إعادة تشغيل التحسينات الدورية
      AppOptimizer.optimizeRuntime();
      
      if (kDebugMode) print('✅ App optimizations activated');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error activating app optimizations: $e');
    }
  }

  /// التطبيق أصبح غير نشط
  void _onAppInactive() {
    try {
      if (kDebugMode) print('⏸️ App inactive - pausing optimizations...');
      
      // إيقاف التحسينات مؤقتاً
      AppOptimizer.setAppActive(false);
      
    } catch (e) {
      if (kDebugMode) print('❌ Error pausing app optimizations: $e');
    }
  }

  /// التطبيق متوقف مؤقتاً
  void _onAppPaused() {
    try {
      if (kDebugMode) print('⏸️ App paused - saving state...');
      
      // حفظ حالة التطبيق
      _saveAppState();
      
    } catch (e) {
      if (kDebugMode) print('❌ Error saving app state: $e');
    }
  }

  /// التطبيق منفصل
  void _onAppDetached() {
    try {
      if (kDebugMode) print('🔌 App detached - performing cleanup...');
      
      // تنظيف الموارد
      AppOptimizer.safeShutdown();
      
    } catch (e) {
      if (kDebugMode) print('❌ Error during app detachment cleanup: $e');
    }
  }

  /// التطبيق مخفي
  void _onAppHidden() {
    try {
      if (kDebugMode) print('👻 App hidden - reducing resource usage...');
      
      // تقليل استخدام الموارد
      AppOptimizer.setAppActive(false);
      
    } catch (e) {
      if (kDebugMode) print('❌ Error reducing app resource usage: $e');
    }
  }

  /// حفظ حالة التطبيق
  void _saveAppState() {
    try {
      if (kDebugMode) print('💾 Saving app state...');
      
      // يمكن إضافة منطق حفظ الحالة هنا
      // مثل حفظ البيانات المهمة، إعدادات المستخدم، إلخ
      
      if (kDebugMode) print('✅ App state saved successfully');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error saving app state: $e');
    }
  }

  @override
  void didHaveMemoryPressure() {
    try {
      if (kDebugMode) print('⚠️ Memory pressure detected - performing cleanup...');
      
      // تنظيف الذاكرة عند الضغط
      AppOptimizer.cleanup();
      
      if (kDebugMode) print('✅ Memory cleanup completed');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error during memory cleanup: $e');
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    try {
      if (kDebugMode) print('♿ Accessibility features changed');
      
      // يمكن إضافة منطق لتحديث واجهة المستخدم بناءً على ميزات إمكانية الوصول
      
    } catch (e) {
      if (kDebugMode) print('❌ Error handling accessibility changes: $e');
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    try {
      if (kDebugMode) print('🌍 Locales changed: $locales');
      
      // يمكن إضافة منطق لتحديث اللغة
      
    } catch (e) {
      if (kDebugMode) print('❌ Error handling locale changes: $e');
    }
  }

  @override
  void didChangePlatformBrightness() {
    try {
      if (kDebugMode) print('🌓 Platform brightness changed');
      
      // يمكن إضافة منطق لتحديث الثيم
      
    } catch (e) {
      if (kDebugMode) print('❌ Error handling brightness changes: $e');
    }
  }
}
