import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientTheme {
  // Gradient Theme Colors
  static const Color gradientStart = Color(0xFF667EEA);
  static const Color gradientEnd = Color(0xFF764BA2);
  static const Color gradientAccent = Color(0xFFF093FB);
  static const Color gradientBackground = Color(0xFF1A1A2E);
  static const Color gradientSurface = Color(0xFF16213E);
  static const Color gradientText = Color(0xFFE8E8E8);
  static const Color gradientSecondaryText = Color(0xFFB8B8B8);
  static const Color gradientBorder = Color(0xFF3D3D5C);
  
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: gradientBackground,
      
      // Custom Extension for Gradient Support
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
      
      colorScheme: ColorScheme.dark(
        primary: gradientStart,
        secondary: gradientAccent,
        surface: gradientSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: gradientText,
        error: const Color(0xFFFF6B6B),
        tertiary: gradientEnd,
      ),
      
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: gradientText,
        displayColor: gradientText,
      ).copyWith(
        headlineLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: gradientText,
          shadows: [
            Shadow(
              color: gradientStart.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: gradientText,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: gradientText,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: gradientText,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          color: gradientSecondaryText,
          height: 1.4,
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: gradientText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: gradientText,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: gradientSurface.withOpacity(0.8),
        elevation: 8,
        shadowColor: gradientStart.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: gradientBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gradientSurface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: gradientBorder.withOpacity(0.5),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: gradientBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: gradientStart,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.cairo(
          color: gradientSecondaryText.withOpacity(0.7),
        ),
        labelStyle: GoogleFonts.cairo(
          color: gradientSecondaryText,
        ),
      ),
    );
  }
  
  // Helper method to create gradient button
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
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }
  
  // Helper method to create gradient container
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
          colors: colors ?? [
            gradientStart.withOpacity(0.1),
            gradientEnd.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: gradientBorder.withOpacity(0.3),
          width: 1,
        ),
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
  
  // Helper method for gradient text widget
  static Widget gradientTextWidget(
    String text, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    List<Color>? colors,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors ?? [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Theme Extension for Gradient Support
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
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      secondaryGradient: LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t)!,
      backgroundGradient: LinearGradient.lerp(backgroundGradient, other.backgroundGradient, t)!,
    );
  }
}
