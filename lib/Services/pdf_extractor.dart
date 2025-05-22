import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractor {
  /// Extracts all text and links from the PDF.
  static Future<Map<String, dynamic>> extractTextAndLinks(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final textExtractor = PdfTextExtractor(document);

      String fullText = '';
      List<String> links = [];

      for (int i = 0; i < document.pages.count; i++) {
        // Extract text
        fullText += textExtractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );

        // Extract links from the page
        final page = document.pages[i];
        final annotations = page.annotations;

        for (int j = 0; j < annotations.count; j++) {
          final annotation = annotations[j];
          if (annotation is PdfUriAnnotation) {
            links.add(annotation.uri);
          }
        }
      }

      document.dispose();

      return {'fullText': fullText, 'links': links};
    } catch (e) {
      throw Exception('Failed to extract text and links from PDF: $e');
    }
  }

  /// Returns the full extracted text only (for backward compatibility)
  static Future<String?> extractText(File pdfFile) async {
    try {
      final result = await extractTextAndLinks(pdfFile);
      return result['fullText'];
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Returns both text and links
  static Future<Map<String, dynamic>> extractResumeDetails(File pdfFile) async {
    try {
      return await extractTextAndLinks(pdfFile);
    } catch (e) {
      throw Exception('Failed to extract resume details from PDF: $e');
    }
  }
}
