import '../core/localization/localization_service.dart';

class TranslationService {
  static Future<String> translateText(String input, String targetLangCode) async {
    if (input.trim().isEmpty) return input;
    
    // First check exact localization key or dictionary match
    final localized = LocalizationService.getText(targetLangCode, input);
    if (localized != input && localized.isNotEmpty) {
      return localized;
    }

    // Dynamic phrase translation map for runtime chat content and labels
    final Map<String, Map<String, String>> dynamicTranslations = {
      'es': {
        'What happened? Use your own words.': '¿Qué sucedió? Use sus propias palabras.',
        'When did you first receive the notice?': '¿Cuándo recibió el aviso por primera vez?',
        'Eviction / Housing Issue': 'Aviso de desalojo / Vivienda',
        'Family or Custody Dispute': 'Disputa familiar o custodia',
        'Workplace Discrimination': 'Discriminación laboral',
        'Immigration Matter': 'Asunto de inmigración',
        'Debt or Financial Issue': 'Deuda o problema financiero',
        'Criminal Record Query': 'Consulta de antecedentes penales',
        'Other': 'Otro',
        'Question 1 of about 8': 'Pregunta 1 de aprox. 8',
        'Question 2 of about 8': 'Pregunta 2 de aprox. 8',
        'Question 3 of about 8': 'Pregunta 3 de aprox. 8',
        'Question 4 of about 8': 'Pregunta 4 de aprox. 8',
        'Question 5 of about 8': 'Pregunta 5 de aprox. 8',
        'Question 6 of about 8': 'Pregunta 6 de aprox. 8',
        'Question 7 of about 8': 'Pregunta 7 de aprox. 8',
        'Question 8 of about 8': 'Pregunta 8 de aprox. 8',
        'Housing law': 'Derecho de vivienda',
        'Tenant rights': 'Derechos del inquilino',
        'Available today • 2 open cases': 'Disponible hoy • 2 casos abiertos',
        'Available tomorrow • 1 open case': 'Disponible mañana • 1 caso abierto',
        'Available Wednesday • 0 open cases': 'Disponible el miércoles • 0 casos abiertos',
        'Housing specialty, language support, and availability': 'Especialidad en vivienda, soporte de idioma y disponibilidad',
      },
      'fr': {
        'What happened? Use your own words.': 'Que s’est-il passé? Utilisez vos propres mots.',
        'When did you first receive the notice?': 'Quand avez-vous reçu l’avis pour la première fois?',
        'Eviction / Housing Issue': 'Avis d’expulsion / Logement',
        'Family or Custody Dispute': 'Droit de la famille ou garde',
        'Workplace Discrimination': 'Discrimination au travail',
        'Immigration Matter': 'Affaire d’immigration',
        'Debt or Financial Issue': 'Dette ou problème financier',
        'Criminal Record Query': 'Casier judiciaire',
        'Other': 'Autre',
        'Question 1 of about 8': 'Question 1 sur environ 8',
        'Question 2 of about 8': 'Question 2 sur environ 8',
        'Question 3 of about 8': 'Question 3 sur environ 8',
        'Question 4 of about 8': 'Question 4 sur environ 8',
        'Question 5 of about 8': 'Question 5 sur environ 8',
        'Question 6 of about 8': 'Question 6 sur environ 8',
        'Question 7 of about 8': 'Question 7 sur environ 8',
        'Question 8 of about 8': 'Question 8 sur environ 8',
        'Housing law': 'Droit du logement',
        'Tenant rights': 'Droits des locataires',
        'Available today • 2 open cases': 'Disponible aujourd’hui • 2 dossiers en cours',
        'Available tomorrow • 1 open case': 'Disponible demain • 1 dossier en cours',
        'Available Wednesday • 0 open cases': 'Disponible mercredi • 0 dossier en cours',
        'Housing specialty, language support, and availability': 'Spécialité logement, assistance linguistique et disponibilité',
      },
      'hi': {
        'What happened? Use your own words.': 'क्या हुआ था? अपने शब्दों में बताएं।',
        'When did you first receive the notice?': 'आपको पहली बार नोटिस कब मिला?',
        'Eviction / Housing Issue': 'बेदखली / आवास समस्या',
        'Family or Custody Dispute': 'पारिवारिक या हिरासत विवाद',
        'Workplace Discrimination': 'कार्यस्थल पर भेदभाव',
        'Immigration Matter': 'इमिग्रेशन मामला',
        'Debt or Financial Issue': 'कर्ज या वित्तीय समस्या',
        'Criminal Record Query': 'आपराधिक रिकॉर्ड प्रश्न',
        'Other': 'अन्य',
        'Question 1 of about 8': 'प्रश्न 1 (कुल 8 में से)',
        'Question 2 of about 8': 'प्रश्न 2 (कुल 8 में से)',
        'Question 3 of about 8': 'प्रश्न 3 (कुल 8 में से)',
        'Question 4 of about 8': 'प्रश्न 4 (कुल 8 में से)',
        'Question 5 of about 8': 'प्रश्न 5 (कुल 8 में से)',
        'Question 6 of about 8': 'प्रश्न 6 (कुल 8 में से)',
        'Question 7 of about 8': 'प्रश्न 7 (कुल 8 में से)',
        'Question 8 of about 8': 'प्रश्न 8 (कुल 8 में से)',
        'Housing law': 'आवास कानून',
        'Tenant rights': 'किराएदार अधिकार',
        'Available today • 2 open cases': 'आज उपलब्ध • 2 खुले मामले',
        'Available tomorrow • 1 open case': 'कल उपलब्ध • 1 खुला मामला',
        'Available Wednesday • 0 open cases': 'बुधवार उपलब्ध • 0 खुले मामले',
        'Housing specialty, language support, and availability': 'आवास विशेषज्ञता, भाषा सहायता और उपलब्धता',
      },
      'mr': {
        'What happened? Use your own words.': 'काय घडले? तुमचे स्वतःचे शब्द वापरा.',
        'When did you first receive the notice?': 'तुम्हाला नोटीस पहिल्यांदा कधी मिळाली?',
        'Eviction / Housing Issue': 'घरखाली करणे / गृहनिर्माण समस्या',
        'Family or Custody Dispute': 'कौटुंबिक किंवा ताबा विवाद',
        'Workplace Discrimination': 'कामाच्या ठिकाणी भेदभाव',
        'Immigration Matter': 'इमिग्रेशन विषय',
        'Debt or Financial Issue': 'कर्ज किंवा आर्थिक अडचण',
        'Criminal Record Query': 'गुन्हेगारी नोंद प्रश्न',
        'Other': 'इतर',
        'Question 1 of about 8': 'प्रश्न 1 (सुमारे 8 पैकी)',
        'Question 2 of about 8': 'प्रश्न 2 (सुमारे 8 पैकी)',
        'Question 3 of about 8': 'प्रश्न 3 (सुमारे 8 पैकी)',
        'Question 4 of about 8': 'प्रश्न 4 (सुमारे 8 पैकी)',
        'Question 5 of about 8': 'प्रश्न 5 (सुमारे 8 पैकी)',
        'Question 6 of about 8': 'प्रश्न 6 (सुमारे 8 पैकी)',
        'Question 7 of about 8': 'प्रश्न 7 (सुमारे 8 पैकी)',
        'Question 8 of about 8': 'प्रश्न 8 (सुमारे 8 पैकी)',
        'Housing law': 'गृहनिर्माण कायदा',
        'Tenant rights': 'भाडेकरूचे अधिकार',
        'Available today • 2 open cases': 'आज उपलब्ध • 2 उघड्या केसेस',
        'Available tomorrow • 1 open case': 'उद्या उपलब्ध • 1 उघडी केस',
        'Available Wednesday • 0 open cases': 'बुधवारी उपलब्ध • 0 उघड्या केसेस',
        'Housing specialty, language support, and availability': 'गृहनिर्माण विशेषज्ज्ञता, भाषा सहाय्य आणि उपलब्धता',
      },
      'mix': {
        'What happened? Use your own words.': 'Kya hua tha? Apne words mein explain karein.',
        'When did you first receive the notice?': 'Aapko notice pehli baar kab mila?',
        'Eviction / Housing Issue': 'Eviction / Housing Issue',
        'Family or Custody Dispute': 'Family or Custody Dispute',
        'Workplace Discrimination': 'Workplace Discrimination',
        'Immigration Matter': 'Immigration Matter',
        'Debt or Financial Issue': 'Debt & Financial Issue',
        'Criminal Record Query': 'Criminal Record Query',
        'Other': 'Other Issue',
        'Question 1 of about 8': 'Question 1 of about 8',
        'Question 2 of about 8': 'Question 2 of about 8',
        'Question 3 of about 8': 'Question 3 of about 8',
        'Question 4 of about 8': 'Question 4 of about 8',
        'Question 5 of about 8': 'Question 5 of about 8',
        'Question 6 of about 8': 'Question 6 of about 8',
        'Question 7 of about 8': 'Question 7 of about 8',
        'Question 8 of about 8': 'Question 8 of about 8',
        'Housing law': 'Housing Law',
        'Tenant rights': 'Tenant Rights',
        'Available today • 2 open cases': 'Available today • 2 open cases',
        'Available tomorrow • 1 open case': 'Available tomorrow • 1 open case',
        'Available Wednesday • 0 open cases': 'Available Wednesday • 0 open cases',
        'Housing specialty, language support, and availability': 'Housing specialty, language support and availability',
      },
    };

    final langDict = dynamicTranslations[targetLangCode];
    if (langDict != null && langDict.containsKey(input)) {
      return langDict[input]!;
    }

    return input;
  }
}
