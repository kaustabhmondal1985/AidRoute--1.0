import 'package:flutter/material.dart';

import '../models/answer_model.dart';
import '../models/message_model.dart';
import '../services/conversation_service.dart';
import '../services/translation_service.dart';

enum ProviderState { initial, loading, success, error, empty, retrying }

class ConversationProvider extends ChangeNotifier {
  final ConversationService _service = ConversationService();

  final List<MessageModel> _messages = [];
  final List<AnswerModel> _answers = [];
  ProviderState _state = ProviderState.initial;
  String? _errorMessage;
  bool _isTyping = false;

  int _currentQuestionStep = 3;
  int _totalQuestions = 8;
  String _activeLangCode = 'en';
  String? _category; // Changed from hardcoded 'GENERAL' to nullable

  List<MessageModel> get messages => _messages;
  List<AnswerModel> get answers => _answers;
  ProviderState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isTyping => _isTyping;
  int get currentQuestionStep => _currentQuestionStep;
  int get totalQuestions => _totalQuestions;
  String? get category => _category;

  Future<void> startConversation(String languageCode) async {
    _activeLangCode = languageCode;
    _state = ProviderState.loading;
    _errorMessage = null;
    _messages.clear();
    _answers.clear();
    _currentQuestionStep = 1;
    _totalQuestions = 8;
    notifyListeners();

    try {
      final initialMessage = await _service.getInitialAiMessage(languageCode);
      _messages.add(initialMessage);
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Failed to start intake conversation. Please try again.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_activeLangCode == languageCode) return;
    _activeLangCode = languageCode;

    // If conversation is empty, start fresh
    if (_messages.isEmpty) {
      await startConversation(languageCode);
      return;
    }

    // Translate existing messages dynamically
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final translatedText = await TranslationService.translateText(
        msg.text,
        languageCode,
      );

      List<String>? translatedOptions;
      if (msg.options != null) {
        translatedOptions = [];
        for (final opt in msg.options!) {
          translatedOptions.add(
            await TranslationService.translateText(opt, languageCode),
          );
        }
      }

      _messages[i] = MessageModel(
        id: msg.id,
        text: translatedText,
        sender: msg.sender,
        timestamp: msg.timestamp,
        options: translatedOptions,
      );
    }
    notifyListeners();
  }

  void setCategory(String? category) {
    _category = category;
    notifyListeners();
  }

  Future<void> sendUserMessage(String text, String languageCode) async {
    if (text.trim().isEmpty) return;
    _activeLangCode = languageCode;

    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _answers.add(
      AnswerModel(
        questionId: 'q_${_messages.length}',
        questionPrompt: _messages.length > 1
            ? _messages[_messages.length - 2].text
            : 'Initial Query',
        responseText: text,
        timestamp: DateTime.now(),
      ),
    );

    _isTyping = true;
    notifyListeners();

    try {
      final aiReply = await _service.processUserResponse(
        userText: text,
        history: _answers,
        languageCode: languageCode,
        category:
            _category ?? 'GENERAL', // Use fallback if category not set yet
      );
      _messages.add(aiReply);
      _currentQuestionStep = (_answers.length + 1).clamp(1, _totalQuestions);
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Could not get AI response. Please tap retry.';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
