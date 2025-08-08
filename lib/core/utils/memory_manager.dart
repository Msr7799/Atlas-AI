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
  final MemoryManager _memoryManager = MemoryManager();

  @override
  void dispose() {
    _memoryManager.clearAll();
    super.dispose();
  }

  /// تسجيل AnimationController
  void registerAnimationController(String key, AnimationController controller) {
    _memoryManager.registerResource(key, controller, () {
      controller.dispose();
    });
  }

  /// تسجيل TextEditingController
  void registerTextController(String key, TextEditingController controller) {
    _memoryManager.registerResource(key, controller, () {
      controller.dispose();
    });
  }

  /// تسجيل ScrollController
  void registerScrollController(String key, ScrollController controller) {
    _memoryManager.registerResource(key, controller, () {
      controller.dispose();
    });
  }

  /// تسجيل FocusNode
  void registerFocusNode(String key, FocusNode node) {
    _memoryManager.registerResource(key, node, () {
      node.dispose();
    });
  }
} 