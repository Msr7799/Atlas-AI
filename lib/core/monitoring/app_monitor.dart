import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// مراقب التطبيق الشامل - يجمع جميع وظائف المراقبة
class AppMonitor {
  static AppMonitor? _instance;
  
  // === Singleton ===
  static AppMonitor get instance {
    _instance ??= AppMonitor._internal();
    return _instance!;
  }
  
  AppMonitor._internal();

  // === متغيرات دورة الحياة ===
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  Timer? _inactivityTimer;
  Timer? _memoryCheckTimer;
  bool _isInitialized = false;
  _AppLifecycleObserver? _observer;
  
  // === متغيرات الذاكرة ===
  int _peakMemoryUsage = 0;
  int _currentMemoryUsage = 0;
  
  // === متغيرات الأداء ===
  final Map<String, List<Duration>> _frameTimes = {};
  final Map<String, int> _frameCounts = {};
  
  // === متغيرات callbacks ===
  final List<VoidCallback> _pauseCallbacks = [];
  final List<VoidCallback> _resumeCallbacks = [];
  final List<VoidCallback> _detachedCallbacks = [];

  /// تهيئة مراقب التطبيق
  static void initialize() {
    try {
      if (kDebugMode) print('🔍 Initializing AppMonitor...');
      
      // إنشاء observer منفصل
      instance._observer = _AppLifecycleObserver();
      WidgetsBinding.instance.addObserver(instance._observer!);
      
      // بدء مراقبة الذاكرة كل 30 ثانية
      instance._memoryCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        instance._updateMemoryUsage();
      });
      
      instance._isInitialized = true;
      
      if (kDebugMode) print('✅ AppMonitor initialized successfully');
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize AppMonitor: $e');
        print('🛡️ Continuing without monitoring...');
      }
    }
  }

  /// إلغاء تسجيل مراقب التطبيق
  static void dispose() {
    if (_instance != null) {
      try {
        if (kDebugMode) print('🧹 Disposing AppMonitor...');
        
        _instance!._cleanup();
        _instance = null;
        
        if (kDebugMode) print('✅ AppMonitor disposed successfully');
        
      } catch (e) {
        if (kDebugMode) print('❌ Error disposing AppMonitor: $e');
      }
    }
  }

  /// تنظيف الموارد
  void _cleanup() {
    _cancelInactivityTimer();
    _memoryCheckTimer?.cancel();
    
    // إزالة observer
    if (_observer != null) {
      WidgetsBinding.instance.removeObserver(_observer!);
      _observer = null;
    }
    
    _pauseCallbacks.clear();
    _resumeCallbacks.clear();
    _detachedCallbacks.clear();
    
    _isInitialized = false;
  }

  // === دوال دورة الحياة ===

  /// إضافة callback لحالة التوقف المؤقت
  void addPauseCallback(VoidCallback callback) {
    _pauseCallbacks.add(callback);
  }

  /// إضافة callback لحالة الاستئناف
  void addResumeCallback(VoidCallback callback) {
    _resumeCallbacks.add(callback);
  }

  /// إضافة callback لحالة الانفصال
  void addDetachedCallback(VoidCallback callback) {
    _detachedCallbacks.add(callback);
  }

  /// معالجة تغيير حالة التطبيق
  void _handleAppLifecycleStateChanged(AppLifecycleState state) {
    final previousState = _currentState;
    _currentState = state;
    
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
    
    if (kDebugMode) {
      print('[APP_LIFECYCLE] تغيير الحالة: $previousState → $state');
    }
  }

  /// معالجة حالة الاستئناف
  void _onAppResumed() {
    _cancelInactivityTimer();
    
    // تنفيذ callbacks
    for (final callback in _resumeCallbacks) {
      try {
        callback();
      } catch (e) {
        if (kDebugMode) print('❌ Error in resume callback: $e');
      }
    }
    
    if (kDebugMode) print('📱 التطبيق نشط مرة أخرى');
  }

  /// معالجة حالة عدم النشاط
  void _onAppInactive() {
    if (kDebugMode) print('⏸️ التطبيق غير نشط');
  }

  /// معالجة حالة التوقف المؤقت
  void _onAppPaused() {
    _startInactivityTimer();
    
    // تنفيذ callbacks
    for (final callback in _pauseCallbacks) {
      try {
        callback();
      } catch (e) {
        if (kDebugMode) print('❌ Error in pause callback: $e');
      }
    }
    
    if (kDebugMode) print('⏸️ التطبيق متوقف مؤقتاً');
  }

  /// معالجة حالة الانفصال
  void _onAppDetached() {
    // تنفيذ callbacks
    for (final callback in _detachedCallbacks) {
      try {
        callback();
      } catch (e) {
        if (kDebugMode) print('❌ Error in detached callback: $e');
      }
    }
    
    if (kDebugMode) print('🔌 التطبيق منفصل');
  }

  /// معالجة حالة الإخفاء
  void _onAppHidden() {
    if (kDebugMode) print('🙈 التطبيق مخفي');
  }

  /// بدء timer عدم النشاط
  void _startInactivityTimer() {
    _cancelInactivityTimer();
    
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      if (kDebugMode) print('⏰ التطبيق غير نشط لمدة 5 دقائق');
      // يمكن إضافة منطق إضافي هنا
    });
  }

  /// إلغاء timer عدم النشاط
  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  // === دوال مراقبة الذاكرة ===

  /// تحديث استخدام الذاكرة
  void _updateMemoryUsage() {
    try {
      // في Flutter، لا يمكن الوصول مباشرة لاستخدام الذاكرة
      // يمكن استخدام معلومات من النظام الأساسي
      if (kDebugMode) {
        print('💾 Memory monitoring active');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error updating memory usage: $e');
    }
  }

  /// الحصول على استخدام الذاكرة الحالي
  int get currentMemoryUsage => _currentMemoryUsage;

  /// الحصول على استخدام الذاكرة الأقصى
  int get peakMemoryUsage => _peakMemoryUsage;

  /// تحديث استخدام الذاكرة
  void updateMemoryUsage() {
    try {
      // يمكن إضافة منطق مراقبة الذاكرة هنا
      if (kDebugMode) {
        print('💾 Memory usage updated');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error updating memory usage: $e');
    }
  }

  // === دوال مراقبة أداء الواجهة ===

  /// تسجيل frame
  void recordFrame(String widgetName) {
    if (_frameTimes.containsKey(widgetName)) {
      _frameTimes[widgetName]!.add(Duration.zero); // يمكن تحسين هذا
    } else {
      _frameTimes[widgetName] = [Duration.zero];
    }
    
    _frameCounts[widgetName] = (_frameCounts[widgetName] ?? 0) + 1;
    
    // الحفاظ على حجم معقول
    if (_frameTimes[widgetName]!.length > 100) {
      _frameTimes[widgetName]!.removeAt(0);
    }
  }

  /// الحصول على إحصائيات الأداء
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final widgetName in _frameCounts.keys) {
      final count = _frameCounts[widgetName] ?? 0;
      final times = _frameTimes[widgetName] ?? [];
      
      stats[widgetName] = {
        'frameCount': count,
        'averageFrameTime': times.isNotEmpty ? times.length : 0,
      };
    }
    
    return stats;
  }

  // === دوال الحالة ===

  /// الحصول على الحالة الحالية
  AppLifecycleState get currentState => _currentState;

  /// التحقق من أن التطبيق نشط
  bool get isActive => _currentState == AppLifecycleState.resumed;

  /// التحقق من أن التطبيق متوقف مؤقتاً
  bool get isPaused => _currentState == AppLifecycleState.paused;

  /// التحقق من أن التطبيق منفصل
  bool get isDetached => _currentState == AppLifecycleState.detached;

  /// التحقق من أن المراقب مهيأ
  bool get isInitialized => _isInitialized;

  /// الحصول على معلومات الحالة
  Map<String, dynamic> getStateInfo() {
    return {
      'currentState': _currentState.toString(),
      'isActive': isActive,
      'isPaused': isPaused,
      'isDetached': isDetached,
      'isInitialized': _isInitialized,
      'memoryUsage': _currentMemoryUsage,
      'peakMemoryUsage': _peakMemoryUsage,
      'frameCounts': Map<String, int>.from(_frameCounts),
    };
  }

  /// طباعة تقرير الحالة
  void printStateReport() {
    if (!kDebugMode) return;
    
    final info = getStateInfo();
    
    print('\n═══════════════════════════════════════');
    print('📱 ATLAS AI - APP MONITOR STATE REPORT');
    print('═══════════════════════════════════════');
    
    print('🔄 Current State: ${info['currentState']}');
    print('✅ Is Active: ${info['isActive']}');
    print('⏸️ Is Paused: ${info['isPaused']}');
    print('🔌 Is Detached: ${info['isDetached']}');
    print('🔧 Is Initialized: ${info['isInitialized']}');
    print('💾 Memory Usage: ${info['memoryUsage']}');
    print('📈 Peak Memory: ${info['peakMemoryUsage']}');
    
    if (info['frameCounts'] is Map) {
      final frameCounts = info['frameCounts'] as Map<String, int>;
      if (frameCounts.isNotEmpty) {
        print('\n🎬 Frame Counts:');
        frameCounts.forEach((widget, count) {
          print('  • $widget: $count frames');
        });
      }
    }
    
    print('═══════════════════════════════════════\n');
  }

  /// إعادة تعيين الإحصائيات
  void resetStats() {
    _frameTimes.clear();
    _frameCounts.clear();
    _currentMemoryUsage = 0;
    _peakMemoryUsage = 0;
    
    if (kDebugMode) print('🔄 Statistics reset');
  }
}

/// Observer لمراقبة دورة حياة التطبيق
class _AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppMonitor.instance._handleAppLifecycleStateChanged(state);
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (kDebugMode) print('♿ Accessibility features changed');
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (kDebugMode) print('🌍 Locales changed: $locales');
  }

  @override
  void didChangeMetrics() {
    if (kDebugMode) print('📏 Metrics changed');
  }

  @override
  void didChangePlatformBrightness() {
    if (kDebugMode) print('🌓 Platform brightness changed');
  }

  @override
  void didChangeTextScaleFactor() {
    if (kDebugMode) print('📝 Text scale factor changed');
  }

  @override
  void didHaveMemoryPressure() {
    if (kDebugMode) print('💾 Memory pressure detected');
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (kDebugMode) print('🚪 App exit requested');
    // Return AppExitResponse.exit to allow the app to exit, AppExitResponse.cancel to cancel
    return AppExitResponse.exit;
  }
}