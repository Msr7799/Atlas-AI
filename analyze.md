# Project Analysis Report

## Project Structure
lib
├── core
│   ├── config
│   │   └── app_config.dart
│   ├── constants
│   ├── services
│   │   ├── chat_export_service.dart
│   │   ├── fine_tuning_advisor_service.dart
│   │   ├── gptgod_service.dart
│   │   ├── groq_service.dart
│   │   ├── mcp_service.dart
│   │   ├── model_training_service.dart
│   │   ├── prompt_enhancer_service.dart
│   │   ├── simple_model_training_service.dart
│   │   └── tavily_service.dart
│   └── theme
│       ├── app_theme.dart
│       ├── gradient_theme.dart
│       └── unified_theme.dart
├── data
│   ├── datasources
│   │   └── database_helper.dart
│   ├── models
│   │   ├── attachment_model.dart
│   │   ├── message_model.dart
│   │   ├── message_model.g.dart
│   │   └── thinking_process_model.dart
│   └── repositories
│       └── chat_repository.dart
├── domain
│   ├── entities
│   ├── repositories
│   └── usecases
├── main.dart
├── presentation
│   ├── pages
│   │   ├── main_chat_page.dart
│   │   └── model_training_page.dart
│   ├── providers
│   │   ├── chat_provider.dart
│   │   ├── chat_selection_provider.dart
│   │   ├── prompt_enhancer_provider.dart
│   │   ├── settings_provider.dart
│   │   ├── theme_provider.dart
│   │   └── training_provider.dart
│   └── widgets
│       ├── attachment_preview.dart
│       ├── chat_drawer.dart
│       ├── chat_export_dialog.dart
│       ├── debug_panel.dart
│       ├── message_bubble.dart
│       ├── prompt_enhancement_dialog.dart
│       ├── settings_dialog.dart
│       ├── thinking_process_widget.dart
│       ├── training_config_widget.dart
│       ├── training_logs_widget.dart
│       └── training_progress_widget.dart
└── utils

19 directories, 39 files
