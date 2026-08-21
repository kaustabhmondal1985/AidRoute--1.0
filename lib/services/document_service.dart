import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/document_model.dart';
import '../models/extracted_date_model.dart';
import 'api_client.dart';

class DocumentService {
  Future<DocumentModel> processUploadedDocument(
    String fileName,
    int fileSizeBytes,
    String path,
  ) async {
    try {
      // Phase 1: Upload to backend
      final docId = DateTime.now().millisecondsSinceEpoch.toString();
      var doc = DocumentModel(
        id: docId,
        fileName: fileName,
        fileType: fileName.endsWith('.pdf') ? 'PDF Document' : 'Image File',
        fileSizeBytes: fileSizeBytes,
        status: DocumentStatus.uploading,
        localPath: path,
      );

      // Read file and prepare for upload
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File not found at path: $path');
      }

      final fileBytes = await file.readAsBytes();

      // Create multipart request
      final response = await ApiClient.multipartPost(
        AppConstants.documentsEndpoint + '/upload',
        files: {
          'document': http.MultipartFile.fromBytes(
            'document',
            fileBytes,
            filename: fileName,
          ),
        },
        fields: {
          'file_name': fileName,
          'file_type': fileName.endsWith('.pdf')
              ? 'application/pdf'
              : 'image/jpeg',
        },
      );

      if (!ApiClient.isSuccess(response.statusCode)) {
        throw Exception(ApiClient.handleError(response));
      }

      // Phase 2: Processing
      doc = doc.copyWith(status: DocumentStatus.processing);

      // Simulate processing time while backend processes
      await Future.delayed(const Duration(milliseconds: 1500));

      // Parse backend response
      final responseData = jsonDecode(response.body);

      // Extract dates from backend response
      final extractedDates = _parseExtractedDates(responseData);

      doc = doc.copyWith(
        status: DocumentStatus.ready,
        extractedDates: extractedDates,
        summaryText:
            responseData['summary_text'] ?? 'Document processed successfully.',
      );

      return doc;
    } catch (e) {
      print('[WARNING] Document processing failed: $e. Returning error state.');
      return DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        fileType: fileName.endsWith('.pdf') ? 'PDF Document' : 'Image File',
        fileSizeBytes: fileSizeBytes,
        status: DocumentStatus.error,
        localPath: path,
        summaryText: 'Document processing failed: $e',
      );
    }
  }

  List<ExtractedDateModel> _parseExtractedDates(
    Map<String, dynamic> responseData,
  ) {
    final datesData = responseData['extracted_dates'] as List?;
    if (datesData == null) {
      return [];
    }

    return datesData.map((dateData) {
      return ExtractedDateModel(
        id: dateData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.parse(
          dateData['date'] ?? DateTime.now().toIso8601String(),
        ),
        label: dateData['label'] ?? 'Unknown Date',
        sourceDocumentName: dateData['source_document_name'] ?? '',
        contextSnippet: dateData['context_snippet'] ?? '',
      );
    }).toList();
  }
}
