import 'extracted_date_model.dart';

enum DocumentStatus { uploading, processing, ready, error }

class DocumentModel {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final DocumentStatus status;
  final String? localPath;
  final List<ExtractedDateModel> extractedDates;
  final String? summaryText;

  const DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.status,
    this.localPath,
    this.extractedDates = const [],
    this.summaryText,
  });

  DocumentModel copyWith({
    DocumentStatus? status,
    List<ExtractedDateModel>? extractedDates,
    String? summaryText,
  }) {
    return DocumentModel(
      id: id,
      fileName: fileName,
      fileType: fileType,
      fileSizeBytes: fileSizeBytes,
      status: status ?? this.status,
      localPath: localPath,
      extractedDates: extractedDates ?? this.extractedDates,
      summaryText: summaryText ?? this.summaryText,
    );
  }
}
