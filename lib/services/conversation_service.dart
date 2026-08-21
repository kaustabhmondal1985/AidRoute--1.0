import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/answer_model.dart';
import '../models/message_model.dart';
import 'api_client.dart';

class ConversationService {
  Future<MessageModel> getInitialAiMessage(String languageCode) async {
    String greeting;
    List<String> options;

    switch (languageCode) {
      case 'es':
        greeting =
            'Hola, soy su asistente de admisión AidRoute. Para comenzar, por favor describa su situación o seleccione una categoría a continuación:';
        options = [
          'Aviso de desalojo / Vivienda',
          'Problema de empleo o salario',
          'Derecho familiar o custodia',
          'Deuda o problema financiero',
        ];
        break;
      case 'fr':
        greeting =
            'Bonjour, je suis votre assistant d\'orientation AidRoute. Pour commencer, veuillez décrire votre situation ou choisir une catégorie ci-dessous:';
        options = [
          'Avis d\'expulsion / Logement',
          'Problème d\'emploi ou de salaire',
          'Droit de la famille ou garde',
          'Dette ou problème financier',
        ];
        break;
      case 'hi':
        greeting =
            'नमस्ते, मैं आपका AidRoute सहायक हूँ। अपनी स्थिति बताने के लिए नीचे दी गई श्रेणी चुनें या विवरण लिखें:';
        options = [
          'बेदखली नोटिस / आवास समस्या',
          'रोजगार या वेतन की समस्या',
          'पारिवारिक कानून या हिरासत',
          'कर्ज या वित्तीय समस्या',
        ];
        break;
      case 'mr':
        greeting =
            'नमस्कार, मी तुमचा AidRoute सहाय्यक आहे. तुमची परिस्थिती सांगण्यासाठी खालील वर्ग निवडा किंवा माहिती लिहा:';
        options = [
          'घरखाली नोटीस / गृहनिर्माण',
          'रोजगार किंवा पगाराची अडचण',
          'कौटुंबिक कायदा किंवा ताबा',
          'कर्ज किंवा आर्थिक अडचण',
        ];
        break;
      case 'mix':
        greeting =
            'Hello! Main aapka AidRoute assistant hoon. Apni situation explain karein ya neeche category select karein:';
        options = [
          'Eviction Notice / Housing Issue',
          'Job or Salary Problem',
          'Family or Custody Question',
          'Debt or Money Issue',
        ];
        break;
      default:
        greeting =
            'Hello, I am your AidRoute intake companion. To help us understand your situation, please describe what happened or choose a category below:';
        options = [
          'Eviction Notice / Housing Issue',
          'Employment or Wage Problem',
          'Family Law or Custody Question',
          'Debt or Consumer Problem',
        ];
        break;
    }

    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: greeting,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      options: options,
    );
  }

  Future<MessageModel> processUserResponse({
    required String userText,
    required List<AnswerModel> history,
    required String languageCode,
    required String category,
  }) async {
    try {
      // Convert conversation history to backend format
      final messages = history
          .map((answer) => {'role': 'user', 'content': answer.responseText})
          .toList();

      // Add current user message
      messages.add({'role': 'user', 'content': userText});

      // Extract case facts from history
      final caseFacts = history
          .map((answer) => answer.responseText)
          .where((text) => text.isNotEmpty)
          .toList();

      // Convert category to backend format if needed
      final backendCategory = _isBackendFormat(category)
          ? category
          : _convertToBackendCategory(category);

      // Call backend intake API
      final response = await ApiClient.post(
        AppConstants.intakeEndpoint + '/process',
        body: {
          'category': backendCategory,
          'user_message': userText,
          'case_facts': caseFacts,
          'messages': messages,
          'documents': [],
        },
      );

      if (!ApiClient.isSuccess(response.statusCode)) {
        throw Exception(ApiClient.handleError(response));
      }

      final responseData = jsonDecode(response.body);

      // Convert backend response to MessageModel
      final pendingQuestion = responseData['pending_question'] as String?;

      if (responseData['intake_complete'] == true) {
        // Intake is complete, provide completion message
        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Thank you for providing all the necessary information. Your intake is complete.',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
          options: ['Review Case Summary', 'Upload Documents'],
        );
      }

      // Return the AI's next question
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: pendingQuestion ?? 'Could you please provide more details?',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        options: null,
      );
    } catch (e) {
      throw Exception('Failed to process user response: ${e.toString()}');
    }
  }

  bool _isBackendFormat(String category) {
    // Backend format is like "HOUSING_EVICTION" - uppercase with underscores
    return category.contains('_') && category == category.toUpperCase();
  }

  String _convertToBackendCategory(String categoryId) {
    // Convert frontend category ID to backend category format
    switch (categoryId.toLowerCase()) {
      case 'cat_housing':
        return 'HOUSING_EVICTION';
      case 'cat_employment':
        return 'EMPLOYMENT';
      case 'cat_family':
        return 'FAMILY';
      case 'cat_criminal':
        return 'CRIMINAL';
      case 'cat_consumer':
        return 'CONSUMER';
      default:
        // Try to extract from the ID
        if (categoryId.startsWith('cat_')) {
          final category = categoryId.substring(4).toUpperCase();
          return category;
        }
        return 'HOUSING_EVICTION'; // Default fallback
    }
  }
}
