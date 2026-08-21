import 'package:flutter/material.dart';

import '../models/document_model.dart';
import '../models/extracted_date_model.dart';
import '../services/document_service.dart';
import 'conversation_provider.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _service = DocumentService();

  final List<DocumentModel> _documents = [];
  ProviderState _state = ProviderState.initial;
  String? _errorMessage;

  List<DocumentModel> get documents => _documents;
  ProviderState get state => _state;
  String? get errorMessage => _errorMessage;

  List<ExtractedDateModel> get allExtractedDates {
    return _documents.expand((d) => d.extractedDates).toList();
  }

  Future<void> addAndProcessDocument(String fileName, int fileSizeBytes, String path) async {
    _state = ProviderState.loading;
    notifyListeners();

    try {
      final processedDoc = await _service.processUploadedDocument(fileName, fileSizeBytes, path);
      _documents.add(processedDoc);
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Failed to process document upload.';
    } finally {
      notifyListeners();
    }
  }

  void removeDocument(String id) {
    _documents.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}
