/// ثوابت واجهة المستخدم لضمان التناسق
class UIConstants {
  // منع إنشاء instance من الكلاس
  UIConstants._();

  // === Spacing ===
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // === Border Radius ===
  static const double borderRadius4 = 4.0;
  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;
  static const double borderRadius20 = 20.0;
  static const double borderRadius25 = 25.0;

  // === Animation Durations ===
  static const int animationDuration = 300;
  static const int animationDurationMedium = 600;
  static const int animationDurationLong = 800;
  static const int waveAnimationDuration = 1500;

  // === Sizes ===
  static const double iconSize16 = 16.0;
  static const double iconSize20 = 20.0;
  static const double iconSize24 = 24.0;
  static const double iconSize28 = 28.0;
  static const double iconSize32 = 32.0;
  static const double iconSize48 = 48.0;
  static const double iconSize56 = 56.0;
  static const double iconSize64 = 64.0;

  // === Font Sizes ===
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;

  // === Input Heights ===
  static const double inputMinHeight = 50.0;
  static const double inputAreaHeight = 240.0;
  static const double inputAreaHeightSmall = 220.0;
  static const double voiceWaveHeight = 60.0;

  // === Screen Breakpoints ===
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // === Assets Paths ===
  static const String neonChatIcon = 'assets/icons/gif_icon.gif';
  static const String ballAnimation = 'assets/icons/ball_ani.gif';

  // === Default Values ===
  static const int maxMessageLines = 3;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxAttachments = 5;
  
  // === Colors (Hex) ===
  static const int primaryBlue = 0xFF5B8402;
  static const int accentGreen = 0xFF9AD942;
  static const int warningRed = 0xFFD13C32;
  static const int darkRed = 0xFF851305;
  static const int purple = 0xFF644761;
  static const int darkBackground = 0xFF1F2428;

  // === Z-Index / Elevation ===
  static const double elevation0 = 0.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;

  // === Opacity Values ===
  static const double opacityDisabled = 0.4;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.8;
  static const double opacityLight = 0.1;
  static const double opacityMediumLight = 0.2;
  static const double opacityMediumHigh = 0.3;

  // === Stroke Widths ===
  static const double strokeWidth1 = 1.0;
  static const double strokeWidth2 = 2.0;
  static const double strokeWidth3 = 3.0;

  // === Quick Action Card ===
  static const double quickActionCardWidth = 100.0;
  static const double quickActionCardHeight = 120.0;
}

