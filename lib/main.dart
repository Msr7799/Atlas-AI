import 'dart:async';
import 'core/theme/app_theme.dart';
import 'core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'core/monitoring/app_monitor.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/providers/chat_provider.dart';
import 'core/performance/performance_manager.dart';
import 'presentation/providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/lazy_service_initializer.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/training_provider.dart';
import 'presentation/pages/main_chat_page_enhanced.dart';
import 'presentation/providers/chat_selection_provider.dart';
import 'presentation/providers/prompt_enhancer_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// === استيراد الملفات الجديدة المدمجة ===

// === استيراد الخدمات المطلوبة ===


// === تعريف المتغيرات العامة الجديدة ===
final performanceManager = PerformanceManager();
final appMonitor = AppMonitor.instance;

void main() async {
  // إضافة Debug Mode
  if (kDebugMode) {
    print('🚀 Starting Atlas AI...');
    print('📱 Debug mode enabled');
  }
  
  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        
        // تحميل .env بشكل آمن
        try {
          await dotenv.load(fileName: ".env");
          if (kDebugMode) {
            print('✅ .env file loaded successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ لم يتم العثور على ملف .env: $e');
            print('🔄 سيتم استخدام القيم الافتراضية');
          }
        }
        
        // === تهيئة الخدمات الجديدة ===
        try {
          await PerformanceManager.initialize();
          if (kDebugMode) {
            print('✅ PerformanceManager initialized successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ فشل في تهيئة PerformanceManager: $e');
          }
        }
        
        try {
          AppMonitor.initialize();
          if (kDebugMode) {
            print('✅ AppMonitor initialized successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ فشل في تهيئة AppMonitor: $e');
          }
        }
        
        try {
          await LazyServiceInitializer().initializeServices();
          if (kDebugMode) {
            print('✅ LazyServiceInitializer initialized successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ فشل في تهيئة LazyServiceInitializer: $e');
          }
        }
        
        // === تحميل مسبق للأصول المهمة ===
        try {
          await AppUtils.preloadImportantAssets();
          if (kDebugMode) {
            print('✅ Important assets preloaded successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ فشل في التحميل المسبق للأصول: $e');
          }
        }
        
        if (kDebugMode) {
          print('🎯 All services initialized, starting app...');
        }
        
        runApp(const MyApp());
        
      } catch (e, stack) {
        if (kDebugMode) {
          print('❌ خطأ في بدء التطبيق: $e');
          print('🔍 Stack trace: $stack');
        }
        
        // تشغيل التطبيق بوضع آمن
        if (kDebugMode) {
          print('🛡️ Starting Safe Mode App...');
        }
        runApp(const SafeModeApp());
      }
    },
    (error, stack) {
      if (kDebugMode) {
        print('❌ خطأ في Zone: $error');
        print('🔍 Stack trace: $stack');
      }
      
      // في حالة خطأ Zone، تشغيل التطبيق الآمن
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const SafeModeApp());
    },
  );
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
              fontWeight: themeProvider.fontWeight,
              accentColor: themeProvider.accentColor,
            ),
            darkTheme: AppTheme.nightTheme(
              fontFamily: themeProvider.fontFamily,
              fontSize: themeProvider.fontSize,
              fontWeight: themeProvider.fontWeight,
              accentColor: themeProvider.accentColor,
            ),
            home: const SplashScreen(),
            // للاختبار المؤقت - يمكن تغيير home إلى MainChatPageEnhanced مباشرة
            // home: const MainChatPageEnhanced(),
            routes: {
              '/mainChatPage': (context) => const MainChatPageEnhanced(),
            },
            themeMode: themeProvider.themeMode,
            // إضافة Error Boundary
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                if (kDebugMode) {
                  print('❌ Error in app: ${errorDetails.exception}');
                  print('🔍 Stack trace: ${errorDetails.stack}');
                }
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'حدث خطأ في التطبيق',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorDetails.exception.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/mainChatPage');
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              };
              return child!;
            },
          );
        },
      ),
    );
  }
}

// تطبيق وضع آمن
class SafeModeApp extends StatelessWidget {
  const SafeModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas AI - Safe Mode',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تم تشغيل التطبيق في الوضع الآمن',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'حدث خطأ أثناء بدء التطبيق. يمكنك إعادة المحاولة أو الاتصال بالدعم الفني.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // إعادة تشغيل التطبيق
                          SystemNavigator.pop();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // إعادة تشغيل التطبيق
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const MyApp()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('تشغيل عادي'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
