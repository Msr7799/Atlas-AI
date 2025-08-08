/// ملف stub مؤقت لحزم الصوت المُعطلة
/// هذا الملف يوفر classes وهمية لتجنب أخطاء البناء
library;

class SpeechToText {
  Future<bool> initialize({
    Function(String)? onStatus,
    Function(dynamic)? onError,
  }) async {
    return false; // الصوت غير مدعوم
  }

  Future<void> stop() async {
    // لا يفعل شيء
  }

  Future<void> listen({
    required Function(SpeechRecognitionResult) onResult,
    String? localeId,
  }) async {
    // لا يفعل شيء
  }
}

class SpeechRecognitionResult {
  final String recognizedWords;
  final bool finalResult;

  SpeechRecognitionResult({
    required this.recognizedWords,
    required this.finalResult,
  });
}

class FlutterTts {
  Future<dynamic> setLanguage(String language) async {
    return null;
  }

  Future<dynamic> setSpeechRate(double rate) async {
    return null;
  }

  Future<dynamic> setVolume(double volume) async {
    return null;
  }

  Future<dynamic> setPitch(double pitch) async {
    return null;
  }

  Future<dynamic> speak(String text) async {
    return null;
  }

  Future<dynamic> stop() async {
    return null;
  }
}
