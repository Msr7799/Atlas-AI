# 📊 Project Analysis Report
Generated on: 08 أغسطس, 2025 06:02:06 م

## 🌳 Project Structure
```
lib
|-- core
|   |-- config
|   |   `-- app_config.dart
|   |-- performance
|   |   |-- app_optimizer.dart
|   |   |-- database_optimizer.dart
|   |   |-- image_optimizer.dart
|   |   |-- network_optimizer.dart
|   |   |-- performance_optimizer.dart
|   |   `-- performance_report.dart
|   |-- services
|   |   |-- api_key_manager.dart
|   |   |-- chat_export_service.dart
|   |   |-- fine_tuning_advisor_service.dart
|   |   |-- gptgod_service.dart
|   |   |-- groq_service.dart
|   |   |-- huggingface_service.dart
|   |   |-- lazy_service_initializer.dart
|   |   |-- local_ai_service.dart
|   |   |-- mcp_service.dart
|   |   |-- model_training_service.dart
|   |   |-- openrouter_service.dart
|   |   |-- permissions_manager.dart
|   |   |-- prompt_enhancer_service.dart
|   |   |-- simple_model_training_service.dart
|   |   `-- tavily_service.dart
|   |-- theme
|   |   |-- app_theme.dart
|   |   `-- unified_theme.dart
|   |-- utils
|   |   |-- asset_optimizer.dart
|   |   |-- memory_manager.dart
|   |   |-- network_checker.dart
|   |   |-- performance_monitor.dart
|   |   |-- responsive_helper.dart
|   |   `-- speech_stub.dart
|   `-- widgets
|       `-- optimized_widgets.dart
|-- data
|   |-- datasources
|   |   `-- database_helper.dart
|   |-- models
|   |   |-- attachment_model.dart
|   |   |-- message_model.dart
|   |   |-- message_model.g.dart
|   |   `-- thinking_process_model.dart
|   `-- repositories
|       `-- chat_repository.dart
|-- main.dart
`-- presentation
    |-- pages
    |   |-- api_settings_page.dart
    |   |-- main_chat_page.dart
    |   `-- model_training_page.dart
    |-- providers
    |   |-- chat_provider.dart
    |   |-- chat_selection_provider.dart
    |   |-- prompt_enhancer_provider.dart
    |   |-- settings_provider.dart
    |   |-- theme_provider.dart
    |   `-- training_provider.dart
    `-- widgets
        |-- attachment_preview.dart
        |-- chat_drawer.dart
        |-- chat_export_dialog.dart
        |-- chat_search_header.dart
        |-- debug_panel.dart
        |-- message_bubble.dart
        |-- models_info_dialog.dart
        |-- prompt_enhancement_dialog.dart
        |-- search_status_widget.dart
        |-- settings_dialog.dart
        |-- thinking_process_widget.dart
        |-- training_config_widget.dart
        |-- training_logs_widget.dart
        `-- training_progress_widget.dart

15 directories, 61 files
```


## Flutter Analyze Issues

/----------------------------------------------\
Analyzing Fine_tuning_AI...                                     

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\fine_tuning_advisor_service.dart:30:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\fine_tuning_advisor_service.dart:39:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\fine_tuning_advisor_service.dart:44:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\fine_tuning_advisor_service.dart:45:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\gptgod_service.dart:35:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\gptgod_service.dart:92:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\gptgod_service.dart:93:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\gptgod_service.dart:106:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\gptgod_service.dart:207:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\gptgod_service.dart:289:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:25:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:50:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:58:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:62:13 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:103:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:108:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:125:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:130:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:185:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:186:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:199:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:200:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:236:17 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:272:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:278:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:281:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:306:19 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:311:15 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:316:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\groq_service.dart:398:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:37:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:44:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:169:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:170:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:183:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:230:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:294:15 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\huggingface_service.dart:301:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:34:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:43:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:51:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:59:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:67:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:71:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:73:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:138:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:153:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\lazy_service_initializer.dart:155:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\mcp_service.dart:28:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\mcp_service.dart:62:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\mcp_service.dart:94:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\mcp_service.dart:114:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:22:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:38:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:41:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:49:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:66:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:68:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:75:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:336:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:342:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:715:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:764:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:775:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:780:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:790:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:793:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:797:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:875:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:877:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:913:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:942:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\model_training_service.dart:959:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:32:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:39:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:204:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:205:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:218:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:249:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:283:15 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\openrouter_service.dart:288:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:129:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:134:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:138:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:141:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:147:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:153:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:163:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:174:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:185:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:217:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:225:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:226:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:227:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:241:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\permissions_manager.dart:244:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\prompt_enhancer_service.dart:59:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\prompt_enhancer_service.dart:64:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\prompt_enhancer_service.dart:95:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\prompt_enhancer_service.dart:111:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\prompt_enhancer_service.dart:122:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\prompt_enhancer_service.dart:244:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:20:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:36:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:40:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:60:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:63:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:67:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\simple_model_training_service.dart:300:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\tavily_service.dart:23:31 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\tavily_service.dart:53:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\tavily_service.dart:70:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\services\tavily_service.dart:94:7 - avoid_print

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:144:31 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:145:29 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:251:43 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:263:26 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:264:25 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:343:34 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:380:30 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:380:60 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:385:50 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\core\theme\app_theme.dart:389:40 - deprecated_member_use

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:18:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:79:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:86:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:105:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:106:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:107:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:109:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:112:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:115:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:119:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:120:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:124:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:127:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:131:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:135:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:136:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:137:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:138:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:143:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:144:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:145:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:146:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\network_checker.dart:149:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:128:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:133:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:134:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:135:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:136:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:137:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\core\utils\performance_monitor.dart:138:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\api_settings_page.dart:140:7 - avoid_print

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:221:42 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:222:43 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:226:44 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:227:45 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:296:50 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:299:52 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:404:42 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:580:42 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:617:36 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:619:55 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:737:40 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:739:59 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:976:37 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:978:56 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:1590:39 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:1592:58 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\api_settings_page.dart:1676:55 - deprecated_member_use

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:148:28 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:149:27 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:152:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:163:7 - avoid_print

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:241:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:244:47 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:293:56 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:296:56 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:305:45 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:312:47 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:326:49 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:349:57 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:373:51 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:472:38 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:475:36 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:490:51 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:518:53 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:568:49 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:584:49 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:587:51 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:775:58 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:917:26 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:918:26 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:927:43 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:935:41 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:968:42 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:971:45 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:980:47 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:988:47 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1007:48 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1010:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1018:55 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1052:61 - deprecated_member_use

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:1150:45 - avoid_print

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1169:58 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1173:58 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1184:52 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1208:48 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1253:44 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1301:61 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1302:61 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1313:54 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1330:54 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1347:68 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\pages\main_chat_page.dart:1359:66 - deprecated_member_use

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:1392:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\pages\main_chat_page.dart:1522:7 - avoid_print

/----------------------------------------------\
  error - Undefined class 'LocalAIService' - lib\presentation\providers\chat_provider.dart:30:9 - undefined_class

/----------------------------------------------\
  error - The method 'LocalAIService' isn't defined for the type 'ChatProvider' - lib\presentation\providers\chat_provider.dart:30:42 - undefined_method

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:40:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:75:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:84:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:91:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:95:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:99:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:100:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:113:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:122:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:127:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:131:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:132:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:154:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:169:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:211:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:215:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:360:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:384:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:386:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:418:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:442:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:457:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:467:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:470:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:483:13 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:500:13 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:535:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:539:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:561:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:577:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:621:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:630:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:634:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:662:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:674:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:696:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:709:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:733:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:757:9 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:762:5 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:783:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:831:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:833:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:861:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:901:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:920:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:931:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:948:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:959:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:971:7 - avoid_print

/----------------------------------------------\
  error - The method 'clearSessionMessages' isn't defined for the type 'ChatRepository' - lib\presentation\providers\chat_provider.dart:1000:25 - undefined_method

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:1001:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:1007:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:1032:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:1038:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:1044:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\chat_provider.dart:1050:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\prompt_enhancer_provider.dart:34:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\prompt_enhancer_provider.dart:43:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\prompt_enhancer_provider.dart:48:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\settings_provider.dart:111:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\settings_provider.dart:212:11 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\settings_provider.dart:220:7 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\providers\settings_provider.dart:242:7 - avoid_print

/----------------------------------------------\
   info - 'value' is deprecated and shouldn't be used. Use component accessors like .r or .g, or toARGB32 for an explicit conversion - lib\presentation\providers\theme_provider.dart:83:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\attachment_preview.dart:22:56 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\attachment_preview.dart:81:75 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_drawer.dart:27:57 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_drawer.dart:214:33 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_drawer.dart:232:60 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:61:57 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:96:36 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:97:34 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:147:41 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:220:44 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:223:60 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\chat_export_dialog.dart:300:62 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\debug_panel.dart:228:64 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\debug_panel.dart:295:64 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\debug_panel.dart:787:49 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:22:56 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:58:54 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:132:64 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:137:47 - deprecated_member_use

/----------------------------------------------\
   info - 'toolbarOptions' is deprecated and shouldn't be used. Use `contextMenuBuilder` instead. This feature was deprecated after v3.3.0-0.5.pre - lib\presentation\widgets\message_bubble.dart:173:31 - deprecated_member_use

/----------------------------------------------\
   info - 'ToolbarOptions' is deprecated and shouldn't be used. Use `contextMenuBuilder` instead. This feature was deprecated after v3.3.0-0.5.pre - lib\presentation\widgets\message_bubble.dart:173:53 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:200:48 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:202:48 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:223:48 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:225:48 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\message_bubble.dart:274:33 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\models_info_dialog.dart:179:26 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\models_info_dialog.dart:181:45 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\models_info_dialog.dart:226:32 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\models_info_dialog.dart:296:45 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\models_info_dialog.dart:387:22 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\models_info_dialog.dart:389:41 - deprecated_member_use

/----------------------------------------------\
   info - 'WillPopScope' is deprecated and shouldn't be used. Use PopScope instead. The Android predictive back feature will not work with WillPopScope. This feature was deprecated after v3.12.0-1.0.pre - lib\presentation\widgets\prompt_enhancement_dialog.dart:48:12 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:78:59 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:133:36 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:134:34 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:184:41 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:218:63 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:221:56 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:263:44 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:312:47 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:324:33 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:461:41 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:463:22 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:477:28 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:571:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:574:62 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:654:35 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\prompt_enhancement_dialog.dart:656:54 - deprecated_member_use

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\widgets\prompt_enhancement_dialog.dart:866:25 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\widgets\prompt_enhancement_dialog.dart:908:25 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\widgets\prompt_enhancement_dialog.dart:949:25 - avoid_print

/----------------------------------------------\
   info - Don't invoke 'print' in production code - lib\presentation\widgets\prompt_enhancement_dialog.dart:991:25 - avoid_print

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\search_status_widget.dart:28:62 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\search_status_widget.dart:31:64 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\search_status_widget.dart:129:39 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:591:70 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:596:60 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:615:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:616:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:652:46 - deprecated_member_use

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:653:46 - deprecated_member_use

/----------------------------------------------\
  error - The element type 'BuildContext' can't be assigned to the list type 'Widget' - lib\presentation\widgets\settings_dialog.dart:674:27 - list_element_type_not_assignable

/----------------------------------------------\
  error - Undefined name 'mobile' - lib\presentation\widgets\settings_dialog.dart:675:27 - undefined_identifier

/----------------------------------------------\
  error - Expected to find ')' - lib\presentation\widgets\settings_dialog.dart:675:33 - expected_token

/----------------------------------------------\
  error - Expected to find ']' - lib\presentation\widgets\settings_dialog.dart:675:33 - expected_token

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:679:23 - expected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:679:24 - missing_identifier

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:679:24 - unexpected_token

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:680:21 - expected_token

/----------------------------------------------\
  error - Expected to find '}' - lib\presentation\widgets\settings_dialog.dart:680:21 - expected_token

/----------------------------------------------\
warning - Dead code - lib\presentation\widgets\settings_dialog.dart:680:22 - dead_code

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:680:22 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:680:22 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:680:22 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:681:19 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:681:19 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:681:19 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:681:20 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:681:20 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:681:20 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:682:17 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:682:17 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:682:17 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:682:18 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:682:18 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:682:18 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:683:15 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:683:15 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:683:15 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:683:16 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:683:16 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:683:16 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:684:13 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:684:13 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:684:13 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:684:14 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:684:14 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:684:14 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:685:11 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:685:11 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:685:11 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:685:12 - missing_identifier

/----------------------------------------------\
  error - Expected to find ';' - lib\presentation\widgets\settings_dialog.dart:685:12 - expected_token

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:685:12 - unexpected_token

/----------------------------------------------\
  error - Expected an identifier - lib\presentation\widgets\settings_dialog.dart:686:9 - missing_identifier

/----------------------------------------------\
  error - Unexpected text ';' - lib\presentation\widgets\settings_dialog.dart:686:9 - unexpected_token

/----------------------------------------------\
   info - Unnecessary empty statement - lib\presentation\widgets\settings_dialog.dart:686:10 - empty_statements

/----------------------------------------------\
  error - Expected a class member - lib\presentation\widgets\settings_dialog.dart:687:8 - expected_class_member

/----------------------------------------------\
  error - Expected a class member - lib\presentation\widgets\settings_dialog.dart:688:5 - expected_class_member

/----------------------------------------------\
  error - Expected a class member - lib\presentation\widgets\settings_dialog.dart:688:6 - expected_class_member

/----------------------------------------------\
  error - Undefined name '_mcpJsonController' - lib\presentation\widgets\settings_dialog.dart:694:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name '_mcpJsonController' - lib\presentation\widgets\settings_dialog.dart:695:11 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:828:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:839:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:845:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:853:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:861:28 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:862:28 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:869:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:896:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:906:29 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:909:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:920:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:930:29 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:931:31 - undefined_identifier

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:931:62 - deprecated_member_use

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:933:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:943:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:953:29 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:955:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:966:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:983:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1001:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1013:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1023:29 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1024:31 - undefined_identifier

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:1024:62 - deprecated_member_use

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1026:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1044:27 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1046:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1054:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1062:27 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1065:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1091:27 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1093:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1110:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1118:29 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1119:31 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1121:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1131:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1153:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1164:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1174:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1190:31 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1193:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1202:51 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1206:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1216:21 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1228:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name '_mcpJsonController' - lib\presentation\widgets\settings_dialog.dart:1237:23 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1239:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1251:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1261:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1267:45 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1272:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1278:48 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1283:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1294:29 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1297:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1306:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1315:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1325:23 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1336:23 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1350:23 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1356:60 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1359:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1375:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1381:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1387:25 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1390:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1403:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1411:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1421:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1435:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1457:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1463:25 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1466:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1480:33 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1482:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1490:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1498:33 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1501:21 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1512:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1521:42 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1528:31 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1531:32 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1532:32 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1535:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1552:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1558:25 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1561:13 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1575:33 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1577:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1585:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1593:33 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1596:21 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1607:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1627:9 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1638:17 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1647:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1656:31 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:1658:19 - undefined_identifier

/----------------------------------------------\
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\presentation\widgets\settings_dialog.dart:1777:46 - deprecated_member_use

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:2211:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:2233:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:2266:15 - undefined_identifier

/----------------------------------------------\
  error - Undefined name 'context' - lib\presentation\widgets\settings_dialog.dart:2288:19 - undefined_identifier

/----------------------------------------------\
  error - Undefined name '_mcpJsonController' - lib\presentation\widgets\settings_dialog.dart:2331:53 - undefined_identifier

/----------------------------------------------\
  error - Expected a method, getter, setter or operator declaration - lib\presentation\widgets\settings_dialog.dart:2351:1 - expected_executable

/----------------------------------------------\
   info - Invalid regular expression syntax - lib\presentation\widgets\training_logs_widget.dart:210:30 - valid_regexps

/----------------------------------------------\
   info - Don't use 'BuildContext's across async gaps - lib\presentation\widgets\training_progress_widget.dart:365:45 - use_build_context_synchronously

/----------------------------------------------\

## 📈 Project Statistics

### 📁 File Structure
- **Dart files**: `61`
- **Total lines of code**: `23495`
- **Directories**: `16`

### 🎯 Code Metrics
- **Average lines per file**: `385`
- **Pages**: `3`
- **Services**: `15`
- **Custom Widgets**: `14`
- **Providers**: `6`

### ⚡ Performance Components
- **Performance optimization files**: `6`

