import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PermissionsManager {
  static final PermissionsManager _instance = PermissionsManager._internal();
  factory PermissionsManager() => _instance;
  PermissionsManager._internal();

  /// فحص وطلب جميع الأذونات المطلوبة
  Future<Map<String, bool>> checkAndRequestAllPermissions(BuildContext? context) async {
    final results = <String, bool>{};

    // أذونات التخزين
    results['storage'] = await _checkAndRequestStoragePermissions();

    // أذونات الشبكة (عادة مُمنوحة تلقائياً)
    results['network'] = await _checkNetworkPermissions();

    // أذونات الكاميرا (اختيارية)
    results['camera'] = await _checkAndRequestPermission(
      Permission.camera,
      context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'الكاميرا' : 'Camera',
      context,
    );

    // أذونات المايكروفون (اختيارية)
    results['microphone'] = await _checkAndRequestPermission(
      Permission.microphone,
      context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'المايكروفون' : 'Microphone',
      context,
    );

    // أذونات الصور
    results['photos'] = await _checkAndRequestPhotosPermission(context);

    // أذونات التنبيهات
    results['notifications'] = await _checkAndRequestPermission(
      Permission.notification,
      context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'التنبيهات' : 'Notifications',
      context,
    );

    return results;
  }

  /// فحص وطلب أذونات التخزين
  Future<bool> _checkAndRequestStoragePermissions([BuildContext? context]) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Android 13+ (API 33+) - أذونات وسائط منفصلة
      if (androidInfo.version.sdkInt >= 33) {
        final images = await _checkAndRequestPermission(
          Permission.photos,
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'الصور' : 'Photos',
          context,
        );
        final videos = await _checkAndRequestPermission(
          Permission.videos,
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'الفيديوهات' : 'Videos',
          context,
        );
        final audio = await _checkAndRequestPermission(
          Permission.audio,
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'الملفات الصوتية' : 'Audio Files',
          context,
        );

        return images && videos && audio;
      }
      // Android 11-12 (API 30-32)
      else if (androidInfo.version.sdkInt >= 30) {
        return await _checkAndRequestPermission(
          Permission.manageExternalStorage,
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'إدارة التخزين الخارجي' : 'Manage External Storage',
          context,
        );
      }
      // Android 10 وأقل (API 29-)
      else {
        final read = await _checkAndRequestPermission(
          Permission.storage,
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'قراءة التخزين' : 'Storage Access',
          context,
        );
        return read;
      }
    } else if (Platform.isIOS) {
      // iOS يستخدم أذونات منفصلة لكل نوع
      return await _checkAndRequestPermission(
        Permission.photos, 
        context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'مكتبة الصور' : 'Photo Library',
        context,
      );
    }

    return true; // للمنصات الأخرى
  }

  /// فحص أذونات الشبكة
  Future<bool> _checkNetworkPermissions() async {
    // أذونات الشبكة عادة مُمنوحة تلقائياً
    // لكن يمكن فحص حالة الشبكة
    try {
      final status = await Permission.phone.status;
      return status != PermissionStatus.permanentlyDenied;
    } catch (e) {
      return true; // افتراض أن الأذونات متاحة
    }
  }

  /// فحص وطلب أذونات الصور
  Future<bool> _checkAndRequestPhotosPermission([BuildContext? context]) async {
    if (Platform.isIOS) {
      return await _checkAndRequestPermission(
        Permission.photos, 
        context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'مكتبة الصور' : 'Photo Library',
        context,
      );
    } else if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        return await _checkAndRequestPermission(
          Permission.photos, 
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'الصور' : 'Photos',
          context,
        );
      } else {
        return await _checkAndRequestPermission(
          Permission.storage, 
          context != null && Localizations.localeOf(context).languageCode == 'ar' ? 'التخزين' : 'Storage',
          context,
        );
      }
    }

    return true;
  }

  /// فحص وطلب إذن محدد
  Future<bool> _checkAndRequestPermission(
    Permission permission,
    String name,
    [BuildContext? context]
  ) async {
    try {
      final status = await permission.status;

      if (status.isGranted) {
        if (kDebugMode) {
          final grantedMsg = context != null && Localizations.localeOf(context).languageCode == 'ar' 
              ? '[PERMISSIONS] ✅ إذن $name: مُمنوح'
              : '[PERMISSIONS] ✅ Permission $name: Granted';
          print(grantedMsg);
        }
        return true;
      }

      if (status.isDenied) {
        if (kDebugMode) {
          final deniedMsg = context != null && Localizations.localeOf(context).languageCode == 'ar'
              ? '[PERMISSIONS] ⚠️ إذن $name: مرفوض، جار طلب الإذن...'
              : '[PERMISSIONS] ⚠️ Permission $name: Denied, requesting permission...';
          print(deniedMsg);
        }
        final newStatus = await permission.request();

        if (newStatus.isGranted) {
          if (kDebugMode) {
            final grantedMsg = context != null && Localizations.localeOf(context).languageCode == 'ar'
                ? '[PERMISSIONS] ✅ إذن $name: تم منحه'
                : '[PERMISSIONS] ✅ Permission $name: Granted';
            print(grantedMsg);
          }
          return true;
        } else {
          if (kDebugMode) {
            final rejectedMsg = context != null && Localizations.localeOf(context).languageCode == 'ar'
                ? '[PERMISSIONS] ❌ إذن $name: مرفوض من المستخدم'
                : '[PERMISSIONS] ❌ Permission $name: Rejected by user';
            print(rejectedMsg);
          }
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        if (kDebugMode) {
          final permanentlyDeniedMsg = context != null && Localizations.localeOf(context).languageCode == 'ar'
              ? '[PERMISSIONS] 🚫 إذن $name: مرفوض نهائياً'
              : '[PERMISSIONS] 🚫 Permission $name: Permanently denied';
          print(permanentlyDeniedMsg);
        }
        return false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        final errorMsg = context != null && Localizations.localeOf(context).languageCode == 'ar'
            ? '[PERMISSIONS] ❌ خطأ في فحص إذن $name: $e'
            : '[PERMISSIONS] ❌ Error checking permission $name: $e';
        print(errorMsg);
      }
      return false;
    }
  }

  /// فتح إعدادات التطبيق
  Future<bool> openSettingsApp() async {
    try {
      return await openAppSettings();
    } catch (e) {
      if (kDebugMode) print('[PERMISSIONS] خطأ في فتح إعدادات التطبيق: $e');
      return false;
    }
  }

  /// فحص إذن محدد فقط
  Future<bool> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) print('[PERMISSIONS] خطأ في فحص الإذن: $e');
      return false;
    }
  }

  /// طلب إذن محدد
  Future<bool> requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) print('[PERMISSIONS] خطأ في طلب الإذن: $e');
      return false;
    }
  }

  /// فحص جميع الأذونات الحالية
  Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    final permissions = <String, PermissionStatus>{};

    try {
      permissions['storage'] = await Permission.storage.status;
      permissions['camera'] = await Permission.camera.status;
      permissions['microphone'] = await Permission.microphone.status;
      permissions['photos'] = await Permission.photos.status;
      permissions['notification'] = await Permission.notification.status;

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt >= 30) {
          permissions['manageExternalStorage'] =
              await Permission.manageExternalStorage.status;
        }

        if (androidInfo.version.sdkInt >= 33) {
          permissions['photos'] = await Permission.photos.status;
          permissions['videos'] = await Permission.videos.status;
          permissions['audio'] = await Permission.audio.status;
        }
      }
    } catch (e) {
      if (kDebugMode) print('[PERMISSIONS] خطأ في فحص جميع الأذونات: $e');
    }

    return permissions;
  }

  /// طباعة تقرير الأذونات
  Future<void> printPermissionsReport() async {
    if (kDebugMode) print('\n═══════════════════════════════════════');
    if (kDebugMode) print('📋 ATLAS AI - PERMISSIONS REPORT');
    if (kDebugMode) print('═══════════════════════════════════════');

    final permissions = await checkAllPermissions();

    for (final entry in permissions.entries) {
      final status = entry.value;
      final icon = status.isGranted
          ? '✅'
          : status.isDenied
          ? '⚠️'
          : status.isPermanentlyDenied
          ? '🚫'
          : '❓';

      if (kDebugMode) print('$icon ${entry.key}: ${_getStatusText(status)}');
    }

    if (kDebugMode) print('═══════════════════════════════════════\n');
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'مُمنوح';
      case PermissionStatus.denied:
        return 'مرفوض';
      case PermissionStatus.restricted:
        return 'مقيد';
      case PermissionStatus.limited:
        return 'محدود';
      case PermissionStatus.permanentlyDenied:
        return 'مرفوض نهائياً';
      default:
        return 'غير معروف';
    }
  }

  /// فحص سريع للأذونات الأساسية
  Future<bool> hasEssentialPermissions() async {
    if (Platform.isAndroid) {
      final storage = await checkPermission(Permission.storage);
      return storage;
    } else if (Platform.isIOS) {
      // iOS عادة لا يحتاج أذونات مسبقة للتشغيل الأساسي
      return true;
    }

    return true;
  }

  /// رسالة توضيحية للمستخدم حول الأذونات
  String getPermissionExplanation(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'يحتاج Atlas AI لحفظ المحادثات والملفات المُصدرة على جهازك';
      case Permission.camera:
        return 'يمكن لـ Atlas AI استخدام الكاميرا لتحليل الصور ومعالجتها';
      case Permission.microphone:
        return 'يمكن لـ Atlas AI استخدام المايكروفون لتسجيل المذكرات الصوتية';
      case Permission.photos:
        return 'يحتاج Atlas AI للوصول للصور لمعالجتها ومشاركتها';
      case Permission.notification:
        return 'يمكن لـ Atlas AI إرسال تنبيهات مفيدة حول حالة المهام';
      default:
        return 'هذا الإذن مطلوب لتشغيل بعض ميزات Atlas AI بشكل صحيح';
    }
  }
}
