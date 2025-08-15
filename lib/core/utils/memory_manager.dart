import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// مدير الذاكرة لتحسين إدارة الموارد
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final Map<String, dynamic> _resources = {};
  final Map<String, VoidCallback> _disposers = {};

  /// تسجيل مورد مع دالة إغلاق
  void registerResource(String key, dynamic resource, VoidCallback? disposer) {
    _resources[key] = resource;
    if (disposer != null) {
      _disposers[key] = disposer;
    }
    
    if (kDebugMode) {
      print('تم تسجيل المورد: $key');
    }
  }

  /// الحصول على مورد
  T? getResource<T>(String key) {
    final resource = _resources[key];
    if (resource is T) {
      return resource;
    }
    return null;
  }

  /// إزالة مورد
  void removeResource(String key) {
    final disposer = _disposers[key];
    if (disposer != null) {
      disposer();
      _disposers.remove(key);
    }
    
    _resources.remove(key);
    
    if (kDebugMode) {
      print('تم إزالة المورد: $key');
    }
  }

  /// إزالة جميع الموارد
  void clearAll() {
    for (final key in _disposers.keys) {
      _disposers[key]?.call();
    }
    
    _resources.clear();
    _disposers.clear();
    
    if (kDebugMode) {
      print('تم إزالة جميع الموارد');
    }
  }

  /// الحصول على قائمة الموارد
  List<String> getResourceKeys() {
    return _resources.keys.toList();
  }

  /// التحقق من وجود مورد
  bool hasResource(String key) {
    return _resources.containsKey(key);
  }

  /// الحصول على عدد الموارد
  int getResourceCount() {
    return _resources.length;
  }
}

/// مزيج لتحسين إدارة الذاكرة في StatefulWidget
mixin MemoryOptimizedMixin<T extends StatefulWidget> on State<T> {
  // استخدام instance منفصل لكل widget بدلاً من singleton
  final Map<String, dynamic> _localResources = {};
  final Map<String, VoidCallback> _localDisposers = {};
  final Set<String> _disposedKeys = {}; // تتبع ما تم تنظيفه بالفعل
  bool _isDisposed = false;

  @override
  void dispose() {
    if (!_isDisposed) {
      _disposeLocalResources();
      _isDisposed = true;
    }
    super.dispose();
  }

  /// تنظيف الموارد المحلية فقط
  void _disposeLocalResources() {
    try {
      for (final key in List.from(_localDisposers.keys)) {
        if (_disposedKeys.contains(key)) {
          continue; // تم تنظيفه بالفعل
        }
        
        final disposer = _localDisposers[key];
        if (disposer != null) {
          try {
            disposer();
            _disposedKeys.add(key); // تمييز أنه تم تنظيفه
            if (kDebugMode) {
              print('تم تنظيف المورد المحلي: $key');
            }
          } catch (e) {
            if (kDebugMode) {
              print('خطأ في تنظيف المورد $key: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تنظيف الموارد المحلية: $e');
      }
    } finally {
      _localResources.clear();
      _localDisposers.clear();
      _disposedKeys.clear();
    }
  }

  /// تسجيل AnimationController
  void registerAnimationController(String key, AnimationController controller) {
    if (_isDisposed) return;
    
    // تنظيف المورد السابق إذا كان موجوداً
    _removeLocalResource(key);
    
    _localResources[key] = controller;
    _localDisposers[key] = () {
      try {
        controller.dispose();
      } catch (e) {
        if (kDebugMode) {
          print('خطأ في تنظيف AnimationController: $e');
        }
      }
    };
    
    if (kDebugMode) {
      print('تم تسجيل AnimationController: $key');
    }
  }

  /// تسجيل TextEditingController
  void registerTextController(String key, TextEditingController controller) {
    if (_isDisposed) return;
    
    _removeLocalResource(key);
    
    _localResources[key] = controller;
    _localDisposers[key] = () {
      controller.dispose();
    };
    
    if (kDebugMode) {
      print('تم تسجيل TextEditingController: $key');
    }
  }

  /// تسجيل ScrollController
  void registerScrollController(String key, ScrollController controller) {
    if (_isDisposed) return;
    
    _removeLocalResource(key);
    
    _localResources[key] = controller;
    _localDisposers[key] = () {
      if (controller.hasClients) {
        controller.dispose();
      }
    };
    
    if (kDebugMode) {
      print('تم تسجيل ScrollController: $key');
    }
  }

  /// تسجيل FocusNode
  void registerFocusNode(String key, FocusNode node) {
    if (_isDisposed) return;
    
    _removeLocalResource(key);
    
    _localResources[key] = node;
    _localDisposers[key] = () {
      node.dispose();
    };
    
    if (kDebugMode) {
      print('تم تسجيل FocusNode: $key');
    }
  }

  /// إزالة مورد محلي
  void _removeLocalResource(String key) {
    if (_disposedKeys.contains(key)) {
      return; // تم تنظيفه بالفعل
    }
    
    final disposer = _localDisposers[key];
    if (disposer != null) {
      try {
        disposer();
        _disposedKeys.add(key); // تمييز أنه تم تنظيفه
      } catch (e) {
        if (kDebugMode) {
          print('خطأ في إزالة المورد $key: $e');
        }
      }
      _localDisposers.remove(key);
    }
    _localResources.remove(key);
  }

  /// الحصول على مورد محلي
  T? getLocalResource<T>(String key) {
    if (_isDisposed) return null;
    final resource = _localResources[key];
    return resource is T ? resource : null;
  }

  /// التحقق من وجود مورد محلي
  bool hasLocalResource(String key) {
    return !_isDisposed && _localResources.containsKey(key);
  }
} 