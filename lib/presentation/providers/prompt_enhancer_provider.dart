import 'package:flutter/material.dart';
import '../../core/services/prompt_enhancer_service.dart';
import '../../data/models/message_model.dart';

class PromptEnhancerProvider extends ChangeNotifier {
  final PromptEnhancerService _enhancerService = PromptEnhancerService();

  bool _isEnhancing = false;
  PromptEnhancementResult? _lastResult;
  String? _error;

  bool get isEnhancing => _isEnhancing;
  PromptEnhancementResult? get lastResult => _lastResult;
  String? get error => _error;
  bool get hasResult => _lastResult != null;

  Future<PromptEnhancementResult?> enhancePrompt({
    required String originalPrompt,
    required List<MessageModel> conversationHistory,
    String? contextTopic,
  }) async {
    if (originalPrompt.trim().isEmpty) {
      _error = 'لا يمكن تحسين برومبت فارغ';
      notifyListeners();
      return null;
    }

    _isEnhancing = true;
    _error = null;
    _lastResult = null;
    notifyListeners();

    try {
      print('[PROMPT_ENHANCER_PROVIDER] 🚀 بدء تحسين البرومبت...');

      final result = await _enhancerService.enhancePrompt(
        originalPrompt: originalPrompt,
        conversationHistory: conversationHistory,
        contextTopic: contextTopic,
      );

      _lastResult = result;
      print('[PROMPT_ENHANCER_PROVIDER] ✅ تم تحسين البرومبت بنجاح');

      return result;
    } catch (e) {
      _error = 'فشل في تحسين البرومبت: ${e.toString()}';
      print('[PROMPT_ENHANCER_PROVIDER] ❌ خطأ: $_error');
      return null;
    } finally {
      _isEnhancing = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _lastResult = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
