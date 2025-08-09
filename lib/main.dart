import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/main_chat_page.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/training_provider.dart';
import 'presentation/providers/prompt_enhancer_provider.dart';
import 'presentation/providers/chat_selection_provider.dart';
import 'core/theme/app_theme.dart';
// استيراد الخدمات المطلوبة
// import 'core/services/fine_tuning_advisor_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// إضافة المحسن الشامل
import 'core/performance/app_optimizer.dart';
import 'core/services/lazy_service_initializer.dart';
import 'core/utils/memory_manager.dart';
import 'core/utils/performance_monitor.dart';

void main() async {
  // بدء قياس أداء بدء التطبيق
  PerformanceMonitor().startTimer('app_startup');

  WidgetsFlutterBinding.ensureInitialized();

  // تحسين الأداء قبل تحميل التطبيق
  await PerformanceMonitor().measureAsync('app_optimizer_init', () async {
    await AppOptimizer.initialize();
  });

  await dotenv.load(fileName: ".env");

  // تهيئة الخدمات المطلوبة مع دعم المفاتيح الافتراضية
  await PerformanceMonitor().measureAsync('services_initialization', () async {
    await LazyServiceInitializer().initializeServices();
  });

  // بدء مراقبة الأداء
  AppOptimizer.optimizeRuntime();

  // تسجيل معالج تنظيف الذاكرة عند إغلاق التطبيق
  MemoryManager().registerResource('app_lifecycle', 'main_app', () async {
    await AppOptimizer.safeShutdown();
    LazyServiceInitializer().dispose();
    MemoryManager().clearAll();
  });

  // إنهاء قياس أداء بدء التطبيق
  PerformanceMonitor().stopTimer('app_startup');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => PromptEnhancerProvider()),
        ChangeNotifierProvider(create: (_) => ChatSelectionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Atlas AI',
            debugShowCheckedModeBanner: false,
            // دعم اللغة العربية والاتجاه الصحيح
            locale: const Locale('ar'),
            supportedLocales: const [
              Locale('ar'), // العربية
              Locale('en'), // الإنجليزية
            ],
            // إضافة delegates للترجمة ودعم اللغة العربية
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // تحسين الأداء بإزالة إعادة البناء غير الضرورية
            theme: AppTheme.dayTheme(
              fontFamily: themeProvider.fontFamily,
              fontSize: themeProvider.fontSize,
              accentColor: themeProvider.accentColor,
            ),
            darkTheme: AppTheme.nightTheme(
              fontFamily: themeProvider.fontFamily,
              fontSize: themeProvider.fontSize,
              accentColor: themeProvider.accentColor,
            ),
            home: const SplashScreen(),
            routes: {
              '/mainChatPage': (context) => const MainChatPage(),
            },
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}
