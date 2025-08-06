import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/main_chat_page.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/training_provider.dart';
import 'presentation/providers/prompt_enhancer_provider.dart';
import 'presentation/providers/chat_selection_provider.dart';
import 'core/theme/app_theme.dart'; // تحديث الاستيراد للثيم الموحد
import 'core/services/groq_service.dart';
import 'core/services/gptgod_service.dart';
import 'core/services/tavily_service.dart';
import 'core/services/mcp_service.dart';
import 'core/services/fine_tuning_advisor_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // تهيئة الخدمات
  GroqService().initialize();
  GPTGodService().initialize();
  TavilyService().initialize();
  McpService().initialize();
  await FineTuningAdvisorService().initialize();

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
            title: 'العميل العربي الذكي',
            debugShowCheckedModeBanner: false,
            // تمرير خصائص الخط واللون من ThemeProvider إلى الثيم
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
            home: const MainChatPage(),
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}
