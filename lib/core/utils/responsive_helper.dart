import 'package:flutter/material.dart';

/// مساعد التصميم المتجاوب لضمان التوافق مع جميع أحجام الشاشات
class ResponsiveHelper {
  // نقاط التوقف للشاشات المختلفة
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// التحقق من نوع الجهاز
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// الحصول على نوع الجهاز
  static DeviceType getDeviceType(BuildContext context) {
    if (isMobile(context)) return DeviceType.mobile;
    if (isTablet(context)) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// الحصول على عرض متجاوب
  static double getResponsiveWidth(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على ارتفاع متجاوب
  static double getResponsiveHeight(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على حجم خط متجاوب
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على padding متجاوب
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على margin متجاوب
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على عدد الأعمدة للشبكة
  static int getGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// الحصول على aspect ratio متجاوب
  static double getResponsiveAspectRatio(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// بناء layout متجاوب
  static Widget buildResponsiveLayout(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على constraints متجاوبة
  static BoxConstraints getResponsiveConstraints(
    BuildContext context, {
    BoxConstraints? mobile,
    BoxConstraints? tablet,
    BoxConstraints? desktop,
  }) {
    final screenSize = MediaQuery.of(context).size;

    if (isDesktop(context)) {
      return desktop ??
          BoxConstraints(
            maxWidth: screenSize.width * 0.7,
            maxHeight: screenSize.height * 0.8,
          );
    }

    if (isTablet(context)) {
      return tablet ??
          BoxConstraints(
            maxWidth: screenSize.width * 0.8,
            maxHeight: screenSize.height * 0.85,
          );
    }

    return mobile ??
        BoxConstraints(
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.9,
        );
  }

  /// الحصول على حجم متجاوب للأيقونات
  static double getResponsiveIconSize(
    BuildContext context, {
    double mobile = 24,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على قيمة متجاوبة عامة - مفيدة لأي نوع من البيانات
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// التحقق من الاتجاه
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// الحصول على safe area
  static EdgeInsets getSafeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// الحصول على نسبة العرض إلى الارتفاع للشاشة
  static double getScreenAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }
}

/// أنواع الأجهزة
enum DeviceType { mobile, tablet, desktop }

/// Widget مساعد للتصميم المتجاوب
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.buildResponsiveLayout(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Builder للتصميم المتجاوب مع constraints
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceType deviceType,
  )
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveHelper.getDeviceType(context);
        return builder(context, constraints, deviceType);
      },
    );
  }
}
