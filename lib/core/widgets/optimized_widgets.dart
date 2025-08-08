import 'package:flutter/material.dart';

/// مجموعة من الـ widgets المحسنة للأداء
class OptimizedWidgets {
  /// SizedBox محسن مع const
  static const SizedBox space8 = SizedBox(height: 8);
  static const SizedBox space16 = SizedBox(height: 16);
  static const SizedBox space24 = SizedBox(height: 24);
  static const SizedBox space32 = SizedBox(height: 32);

  /// Divider محسن
  static const Divider divider = Divider(height: 1);

  /// CircularProgressIndicator محسن
  static const CircularProgressIndicator loadingIndicator = CircularProgressIndicator();

  /// Icon محسن للرسائل
  static const Icon sendIcon = Icon(Icons.send);
  static const Icon attachIcon = Icon(Icons.attach_file);
  static const Icon settingsIcon = Icon(Icons.settings);
  static const Icon closeIcon = Icon(Icons.close);

  /// Text محسن للعناوين
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Container محسن مع RepaintBoundary
  static Widget optimizedContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? borderRadius,
  }) {
    return RepaintBoundary(
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius != null 
              ? BorderRadius.circular(borderRadius) 
              : null,
        ),
        child: child,
      ),
    );
  }

  /// ListView محسن مع RepaintBoundary
  static Widget optimizedListView({
    required List<Widget> children,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return RepaintBoundary(
      child: ListView(
        controller: controller,
        shrinkWrap: shrinkWrap,
        children: children,
      ),
    );
  }

  /// Card محسن
  static Widget optimizedCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return RepaintBoundary(
      child: Card(
        margin: margin,
        elevation: elevation,
        child: child,
      ),
    );
  }

  /// Button محسن
  static Widget optimizedButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
  }) {
    return RepaintBoundary(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  /// TextField محسن
  static Widget optimizedTextField({
    required TextEditingController controller,
    String? hintText,
    int? maxLines,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return RepaintBoundary(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
} 