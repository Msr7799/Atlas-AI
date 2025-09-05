enum TrainingTaskType {
  sentimentAnalysis,
  dialectLearning,
  textClassification,
  languageModeling,
  questionAnswering,
  textSummarization,
  namedEntityRecognition,
  conversationalAI,
}

extension TrainingTaskTypeExtension on TrainingTaskType {
  String get arabicName {
    switch (this) {
      case TrainingTaskType.sentimentAnalysis:
        return 'تحليل المشاعر';
      case TrainingTaskType.dialectLearning:
        return 'تعلم اللهجات';
      case TrainingTaskType.textClassification:
        return 'تصنيف النصوص';
      case TrainingTaskType.languageModeling:
        return 'نمذجة اللغة';
      case TrainingTaskType.questionAnswering:
        return 'الإجابة على الأسئلة';
      case TrainingTaskType.textSummarization:
        return 'تلخيص النصوص';
      case TrainingTaskType.namedEntityRecognition:
        return 'التعرف على الكيانات المسماة';
      case TrainingTaskType.conversationalAI:
        return 'الذكاء الاصطناعي التحاوري';
    }
  }

  String get englishName {
    switch (this) {
      case TrainingTaskType.sentimentAnalysis:
        return 'Sentiment Analysis';
      case TrainingTaskType.dialectLearning:
        return 'Dialect Learning';
      case TrainingTaskType.textClassification:
        return 'Text Classification';
      case TrainingTaskType.languageModeling:
        return 'Language Modeling';
      case TrainingTaskType.questionAnswering:
        return 'Question Answering';
      case TrainingTaskType.textSummarization:
        return 'Text Summarization';
      case TrainingTaskType.namedEntityRecognition:
        return 'Named Entity Recognition';
      case TrainingTaskType.conversationalAI:
        return 'Conversational AI';
    }
  }

  String get description {
    switch (this) {
      case TrainingTaskType.sentimentAnalysis:
        return 'تدريب نموذج لتحليل المشاعر في النصوص (إيجابي/سلبي/محايد)';
      case TrainingTaskType.dialectLearning:
        return 'تدريب نموذج لفهم وإنتاج اللهجات المحلية والعامية';
      case TrainingTaskType.textClassification:
        return 'تدريب نموذج لتصنيف النصوص إلى فئات مختلفة';
      case TrainingTaskType.languageModeling:
        return 'تدريب نموذج لغوي لإنتاج نصوص طبيعية';
      case TrainingTaskType.questionAnswering:
        return 'تدريب نموذج للإجابة على الأسئلة بناءً على السياق';
      case TrainingTaskType.textSummarization:
        return 'تدريب نموذج لتلخيص النصوص الطويلة';
      case TrainingTaskType.namedEntityRecognition:
        return 'تدريب نموذج للتعرف على الأشخاص والأماكن والمنظمات';
      case TrainingTaskType.conversationalAI:
        return 'تدريب نموذج للمحادثة الطبيعية مع المستخدمين';
    }
  }

  List<String> get requiredDataColumns {
    switch (this) {
      case TrainingTaskType.sentimentAnalysis:
        return ['text', 'sentiment'];
      case TrainingTaskType.dialectLearning:
        return ['text', 'dialect', 'standard_arabic'];
      case TrainingTaskType.textClassification:
        return ['text', 'category'];
      case TrainingTaskType.languageModeling:
        return ['text'];
      case TrainingTaskType.questionAnswering:
        return ['question', 'context', 'answer'];
      case TrainingTaskType.textSummarization:
        return ['text', 'summary'];
      case TrainingTaskType.namedEntityRecognition:
        return ['text', 'entities'];
      case TrainingTaskType.conversationalAI:
        return ['input', 'response'];
    }
  }

  Map<String, dynamic> get defaultConfig {
    switch (this) {
      case TrainingTaskType.sentimentAnalysis:
        return {
          'model_name': 'aubmindlab/bert-base-arabert',
          'epochs': 3,
          'batch_size': 16,
          'learning_rate': 2e-5,
          'max_length': 512,
        };
      case TrainingTaskType.dialectLearning:
        return {
          'model_name': 'aubmindlab/bert-base-arabertv2',
          'epochs': 5,
          'batch_size': 8,
          'learning_rate': 1e-5,
          'max_length': 256,
        };
      case TrainingTaskType.textClassification:
        return {
          'model_name': 'aubmindlab/bert-base-arabert',
          'epochs': 4,
          'batch_size': 16,
          'learning_rate': 2e-5,
          'max_length': 512,
        };
      case TrainingTaskType.languageModeling:
        return {
          'model_name': 'aubmindlab/aragpt2-base',
          'epochs': 3,
          'batch_size': 4,
          'learning_rate': 5e-5,
          'max_length': 1024,
        };
      case TrainingTaskType.questionAnswering:
        return {
          'model_name': 'aubmindlab/bert-base-arabert',
          'epochs': 3,
          'batch_size': 8,
          'learning_rate': 3e-5,
          'max_length': 512,
        };
      case TrainingTaskType.textSummarization:
        return {
          'model_name': 'UBC-NLP/AraT5-base',
          'epochs': 4,
          'batch_size': 4,
          'learning_rate': 1e-4,
          'max_length': 1024,
        };
      case TrainingTaskType.namedEntityRecognition:
        return {
          'model_name': 'aubmindlab/bert-base-arabert',
          'epochs': 5,
          'batch_size': 16,
          'learning_rate': 2e-5,
          'max_length': 256,
        };
      case TrainingTaskType.conversationalAI:
        return {
          'model_name': 'microsoft/DialoGPT-medium',
          'epochs': 3,
          'batch_size': 4,
          'learning_rate': 5e-5,
          'max_length': 512,
        };
    }
  }
}
