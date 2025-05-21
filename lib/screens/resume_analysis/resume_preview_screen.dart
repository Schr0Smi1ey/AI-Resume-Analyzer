import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart';
import '../../services/pdf_extractor.dart';
import 'resume_analysis_screen.dart';

class ResumePreviewScreen extends StatefulWidget {
  static const routeName = '/resume-preview';
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  late String _filePath;
  late String _fileName;
  late int _fileSize;
  late String _jobDesc;
  late String _jobRole;
  late String _userName;
  String _extractedText = '';
  bool _isLoading = true;
  final PdfViewerController _pdfController = PdfViewerController();
  double _zoomLevel = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _filePath = args['filePath'];
      _fileName = args['fileName'];
      _fileSize = args['fileSize'];
      _jobDesc = args['jobDesc'] ?? '';
      _jobRole = args['jobRole'] ?? '';
      _userName = args['userName'] ?? '';
      _loadFileContent();
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _loadFileContent() async {
    try {
      if (_filePath.endsWith('.pdf')) {
        _extractedText = await _extractPdfText(_filePath);
      } else if (_filePath.endsWith('.docx')) {
        _extractedText = await _extractDocxText(_filePath);
      } else {
        _extractedText = await File(_filePath).readAsString();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _extractedText = 'Error processing file: ${e.toString()}';
        _isLoading = false;
      });
      _showSnackBar('Error processing file: ${e.toString()}', isError: true);
    }
  }

  Future<String> _extractPdfText(String filePath) async {
    try {
      final file = File(filePath);
      return await PdfExtractor.extractText(file) ?? 'No text extracted.';
    } catch (e) {
      throw Exception('Failed to extract PDF text: $e');
    }
  }

  Future<String> _extractDocxText(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final documentFile = archive.firstWhere(
        (file) => file.name == 'word/document.xml',
        orElse: () => throw Exception('DOCX XML content not found.'),
      );

      final xml = XmlDocument.parse(String.fromCharCodes(documentFile.content));
      final text = xml
          .findAllElements('w:t')
          .map((node) => node.text)
          .join(' ');

      return text
          .replaceAll('\t', ' ')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    } catch (e) {
      throw Exception('Failed to extract DOCX text: $e');
    }
  }

  void _analyzeResume() {
    Navigator.pushNamed(
      context,
      ResumeAnalysisScreen.routeName,
      arguments: {
        'filePath': _filePath,
        'fileName': _fileName,
        'fileSize': _fileSize,
        'jobDesc': _jobDesc,
        'jobRole': _jobRole,
        'userName': _userName,
        'extractedText': _extractedText,
      },
    );
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel += 0.2;
      _pdfController.zoomLevel = _zoomLevel;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoomLevel > 0.1) {
        _zoomLevel -= 0.2;
        _pdfController.zoomLevel = _zoomLevel;
      }
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _pdfController.zoomLevel = _zoomLevel;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final backgroundColor =
        isError
            ? Colors.red.withOpacity(0.8)
            : (isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50))
                .withOpacity(0.8);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _buildConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    bool showCopyButton = false,
    String? textToCopy,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);

    return AlertDialog(
      title: Text(title, style: TextStyle(color: textColor)),
      content: Text(
        content,
        style: TextStyle(color: textColor.withOpacity(0.8)),
      ),
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: accentColor)),
        ),
        if (showCopyButton)
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: textToCopy ?? ''));
              if (!mounted) return;
              _showSnackBar('Copied to clipboard');
              Navigator.pop(context);
            },
            child: Text('Copy', style: TextStyle(color: accentColor)),
          ),
      ],
    );
  }

  void _showExtractedText() {
    final displayedText =
        _extractedText
            .replaceAll('\t', ' ')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .replaceAll(RegExp(r'\n{3,}'), '\n\n')
            .trim();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Extracted Text',
              style: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFE0E0E0)
                        : const Color(0xFF212121),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                child: SelectableText(
                  displayedText,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFE0E0E0).withOpacity(0.8)
                            : const Color(0xFF212121).withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF121212)
                    : const Color(0xFFE8F5E9),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF00E676)
                            : const Color(0xFF4CAF50),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: displayedText));
                  if (!mounted) return;
                  _showSnackBar('Copied to clipboard');
                  Navigator.pop(context);
                },
                child: Text(
                  'Copy',
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF00E676)
                            : const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showFileInfo() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'File Information',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Name',
                    _fileName,
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Type',
                    _filePath.split('.').last.toUpperCase(),
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Size',
                    '${(_fileSize / 1024).toStringAsFixed(1)} KB',
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Path',
                    _filePath.split('/').last,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              ),
            ),
            backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: accentColor)),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define theme-dependent colors
    final primaryColor = const Color(0xFF00C853); // Motivating green
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    return Scaffold(
      backgroundColor: backgroundColor, // Explicitly set Scaffold background
      appBar: AppBar(
        title: Text(
          _fileName,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.text_snippet, color: accentColor),
            onPressed: _showExtractedText,
            tooltip: 'Show extracted text',
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: accentColor),
            onPressed: _showFileInfo,
            tooltip: 'File information',
          ),
        ],
      ),
      body:
          _isLoading
              ? Container(
                color: backgroundColor, // Ensure loading state background
                child: Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              )
              : Container(
                color: backgroundColor, // Ensure consistent background
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child:
                              _filePath.endsWith('.pdf')
                                  ? Container(
                                    color:
                                        backgroundColor, // Background for PDF viewer
                                    child: SfPdfViewer.file(
                                      File(_filePath),
                                      controller: _pdfController,
                                      initialZoomLevel: _zoomLevel,
                                      enableDoubleTapZooming: true,
                                      enableTextSelection: true,
                                      canShowScrollHead: true,
                                      canShowScrollStatus: true,
                                      interactionMode: PdfInteractionMode.pan,
                                    ),
                                  )
                                  : Container(
                                    color:
                                        backgroundColor, // Background for non-PDF
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 64,
                                            color: accentColor,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Preview not available for ${_filePath.split('.').last.toUpperCase()} files',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    if (_filePath.endsWith('.pdf'))
                      Positioned(
                        bottom: 80,
                        right: 20,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'zoomIn',
                              onPressed: _zoomIn,
                              tooltip: 'Zoom in',
                              backgroundColor: primaryColor,
                              child: Icon(Icons.zoom_in, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoomOut',
                              onPressed: _zoomOut,
                              tooltip: 'Zoom out',
                              backgroundColor: primaryColor,
                              child: Icon(Icons.zoom_out, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'resetZoom',
                              onPressed: _resetZoom,
                              tooltip: 'Reset zoom',
                              backgroundColor: primaryColor,
                              child: Icon(
                                Icons.fullscreen_exit,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _analyzeResume,
        label: Text('Analyze with AI', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.auto_awesome, color: Colors.white),
        backgroundColor: primaryColor,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
