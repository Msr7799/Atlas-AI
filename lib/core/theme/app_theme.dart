import 'package:flutter/material.dart';

class AppTheme {
  // Night Theme Colors
  static const Color nightBackground = Color(0xFF141414);
  static const Color nightSurface = Color(0xFF3A3A3A);
  static const Color nightHighlight = Color(0xFFC0E8C1);
  static const Color nightText = Color(0xFFF4F4F4);
  static const Color nightSecondaryText = Color(0xFFD0D0D0);
  static const Color nightBorder = Color(0xFF555555);

  // Day Theme Colors
  static const Color dayBackground = Color(0xFFFFFFFF);
  static const Color daySurface = Color(0xFFF7F7F8);
  static const Color dayHighlight = Color(0xFF10A37F);
  static const Color dayText = Color(0xFF353740);
  static const Color daySecondaryText = Color(0xFF6E6E80);
  static const Color dayBorder = Color(0xFFE5E5E7);

  // Gradient Colors (من gradient_theme.dart)
  static const Color gradientStart = Color(0xFF8E9AAF);  // رصاصي فاتح
  static const Color gradientEnd = Color(0xFFCBD2D9);    // رصاصي فاتح أكثر
  static const Color gradientAccent = Color(0xFFA8B2C0); // رصاصي متوسط
  static const Color gradientBackground = Color(0xFF1A1A2E);
  static const Color gradientSurface = Color(0xFF16213E);
  static const Color gradientText = Color(0xFFE8E8E8);
  static const Color gradientSecondaryText = Color(0xFFB8B8B8);
  static const Color gradientBorder = Color(0xFF3D3D5C);

  // Common Colors
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFED8936);
  static const Color successColor = Color(0xFF38A169);
  static const Color infoColor = Color(0xFF3182CE);

  static ThemeData nightTheme({
    String fontFamily = 'Amiri',
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? accentColor,
  }) {
    final Color highlight = accentColor ?? nightHighlight;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nightBackground,
      colorScheme: ColorScheme.dark(
        primary: highlight,
        secondary: highlight,
        surface: nightSurface,
        onPrimary: nightBackground,
        onSecondary: nightBackground,
        onSurface: nightText,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: nightText,
        secondaryColor: nightSecondaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: nightSurface,
        foregroundColor: nightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _buildTextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w600,
          color: nightText,
        ),
      ),
      cardTheme: CardThemeData(
        color: nightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: nightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highlight,
          foregroundColor: nightBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _buildTextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: nightText,
          side: BorderSide(color: nightBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: nightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: nightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: highlight, width: 2),
        ),
        hintStyle: _buildTextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: nightSecondaryText,
        ),
        labelStyle: _buildTextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: nightSecondaryText,
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: nightSurface),
      dividerTheme: const DividerThemeData(color: nightBorder, thickness: 1),
      extensions: [
        GradientColors(
          primaryGradient: const LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          secondaryGradient: const LinearGradient(
            colors: [gradientAccent, gradientEnd],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          backgroundGradient: LinearGradient(
            colors: [
              gradientBackground,
              gradientSurface.withOpacity(0.8),
              gradientStart.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  static ThemeData dayTheme({
    String fontFamily = 'Amiri',
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? accentColor,
  }) {
    final Color highlight = accentColor ?? dayHighlight;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: dayBackground,
      colorScheme: ColorScheme.light(
        primary: highlight,
        secondary: highlight,
        surface: daySurface,
        onPrimary: dayBackground,
        onSecondary: dayBackground,
        onSurface: dayText,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: dayText,
        secondaryColor: daySecondaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dayBackground,
        foregroundColor: dayText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _buildTextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w600,
          color: dayText,
        ),
      ),
      cardTheme: CardThemeData(
        color: daySurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: dayBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highlight,
          foregroundColor: dayBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _buildTextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dayText,
          side: BorderSide(color: dayBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dayBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dayBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dayBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: highlight, width: 2),
        ),
        hintStyle: _buildTextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: daySecondaryText,
        ),
        labelStyle: _buildTextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: daySecondaryText,
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: daySurface),
      dividerTheme: const DividerThemeData(color: dayBorder, thickness: 1),
      extensions: [
        GradientColors(
          primaryGradient: LinearGradient(
            colors: [highlight, highlight.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          secondaryGradient: const LinearGradient(
            colors: [gradientAccent, gradientEnd],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          backgroundGradient: LinearGradient(
            colors: [
              dayBackground,
              daySurface.withOpacity(0.8),
              highlight.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  // Helper Methods (من gradient_theme.dart)
  static TextStyle _buildTextStyle({
    required String fontFamily,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextTheme _buildTextTheme({
    required String fontFamily,
    required double fontSize,
    required Color color,
    required Color secondaryColor,
  }) {
    return TextTheme(
      headlineLarge: _buildTextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize + 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineMedium: _buildTextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize + 10,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: _buildTextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize + 2,
        color: color,
      ),
      bodyMedium: _buildTextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: color,
      ),
      bodySmall: _buildTextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize - 2,
        color: secondaryColor,
      ),
    );
  }

  // Gradient Helper Methods
  static Widget gradientButton({
    required Widget child,
    required VoidCallback onPressed,
    EdgeInsetsGeometry? padding,
    double borderRadius = 12,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget gradientContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 16,
    List<Color>? colors,
    double? blur,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              colors ??
              [gradientStart.withOpacity(0.1), gradientEnd.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: gradientBorder.withOpacity(0.3), width: 1),
        boxShadow: blur != null
            ? [
                BoxShadow(
                  color: gradientStart.withOpacity(0.2),
                  blurRadius: blur,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  static Widget gradientTextWidget(
    String text, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    List<Color>? colors,
    String fontFamily = 'Amiri',
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors ?? [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Theme Extension للـ Gradients
@immutable
class GradientColors extends ThemeExtension<GradientColors> {
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient backgroundGradient;

  const GradientColors({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.backgroundGradient,
  });

  @override
  GradientColors copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? backgroundGradient,
  }) {
    return GradientColors(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  GradientColors lerp(ThemeExtension<GradientColors>? other, double t) {
    if (other is! GradientColors) {
      return this;
    }
    return GradientColors(
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      secondaryGradient: LinearGradient.lerp(
        secondaryGradient,
        other.secondaryGradient,
        t,
      )!,
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
    );
  }
}
