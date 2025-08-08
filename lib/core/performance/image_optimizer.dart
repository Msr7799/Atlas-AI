import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

/// محسن الصور للتطبيق
class ImageOptimizer {
  static final Map<String, ui.Image?> _imageCache = {};
  static const int _maxCacheSize = 20;

  /// تحميل صورة محسّنة
  static Widget optimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      // تحسينات الأداء
      cacheWidth: (width ?? 100).toInt(),
      cacheHeight: (height ?? 100).toInt(),
      // تحسين جودة الصورة
      filterQuality: FilterQuality.medium,
      // تحسين التحميل
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      // معالج الأخطاء
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
      },
    );
  }

  /// تحميل صورة من الشبكة مع تحسين
  static Widget optimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // تحسينات الأداء
      cacheWidth: (width ?? 100).toInt(),
      cacheHeight: (height ?? 100).toInt(),
      // تحسين جودة الصورة
      filterQuality: FilterQuality.medium,
      // تحسين التحميل
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      // معالج الأخطاء
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
      },
    );
  }

  /// تحميل مسبق للصور
  static Future<void> preloadImages(List<String> imagePaths) async {
    for (String path in imagePaths) {
      if (_imageCache.length >= _maxCacheSize) {
        // إزالة الصورة الأقدم
        _imageCache.remove(_imageCache.keys.first);
      }

      try {
        final image = await _loadImageFromAsset(path);
        _imageCache[path] = image;
      } catch (e) {
        // تجاهل الأخطاء في التحميل المسبق
      }
    }
  }

  /// تحميل صورة من الأصول
  static Future<ui.Image?> _loadImageFromAsset(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      return null;
    }
  }

  /// تنظيف ذاكرة الصور
  static void clearImageCache() {
    _imageCache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// الحصول على حجم ذاكرة الصور
  static int getImageCacheSize() {
    return _imageCache.length;
  }
}

/// محسن الأيقونات
class IconOptimizer {
  /// تحسين الأيقونات
  static Widget optimizedIcon({
    required IconData icon,
    double? size,
    Color? color,
  }) {
    return Icon(icon, size: size, color: color);
  }

  /// تحسين الأيقونات مع تأثيرات
  static Widget optimizedAnimatedIcon({
    required IconData icon,
    double? size,
    Color? color,
    bool animate = false,
  }) {
    if (!animate) {
      return optimizedIcon(icon: icon, size: size, color: color);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: optimizedIcon(icon: icon, size: size, color: color),
        );
      },
    );
  }
}
