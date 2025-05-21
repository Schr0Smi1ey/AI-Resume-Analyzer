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
            title: const Text('Extracted Text'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(
                  displayedText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: displayedText));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_snippet),
            onPressed: _showExtractedText,
            tooltip: 'Show extracted text',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showFileInfo,
            tooltip: 'File information',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child:
                            _filePath.endsWith('.pdf')
                                ? SfPdfViewer.file(
                                  File(_filePath),
                                  controller: _pdfController,
                                  initialZoomLevel: _zoomLevel,
                                  enableDoubleTapZooming: true,
                                  enableTextSelection: true,
                                  canShowScrollHead: true,
                                  canShowScrollStatus: true,
                                  interactionMode: PdfInteractionMode.pan,
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.description, size: 64),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Preview not available for ${_filePath.split('.').last.toUpperCase()} files',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                    ],
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
                            child: const Icon(Icons.zoom_in),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'zoomOut',
                            onPressed: _zoomOut,
                            tooltip: 'Zoom out',
                            child: const Icon(Icons.zoom_out),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'resetZoom',
                            onPressed: _resetZoom,
                            tooltip: 'Reset zoom',
                            child: const Icon(Icons.fullscreen_exit),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _analyzeResume,
        label: const Text('Analyze with AI'),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }

  void _showFileInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('File Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Name', _fileName),
                _buildInfoRow('Type', _filePath.split('.').last.toUpperCase()),
                _buildInfoRow(
                  'Size',
                  '${(_fileSize / 1024).toStringAsFixed(1)} KB',
                ),
                _buildInfoRow('Path', _filePath.split('/').last),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
