import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../../resume_analysis/resume_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  String? _name, _jobRole, _jobDesc;
  PlatformFile? _selectedFile;

  @override
  bool get wantKeepAlive => true; // This preserves the state

  Future<void> _processFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => _buildAlertDialog(
              title: 'Error',
              content: 'Failed to upload file: ${e.toString()}',
            ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      Navigator.pushNamed(
        context,
        ResumePreviewScreen.routeName,
        arguments: {
          'filePath': _selectedFile!.path!,
          'fileName': _selectedFile!.name,
          'fileSize': _selectedFile!.size,
          'userName': _name,
          'jobRole': _jobRole,
          'jobDesc': _jobDesc,
        },
      );
    } else if (_selectedFile == null) {
      showDialog(
        context: context,
        builder:
            (context) => _buildAlertDialog(
              title: 'Missing Resume',
              content: 'Please upload your resume to proceed.',
            ),
      );
    }
  }

  AlertDialog _buildAlertDialog({
    required String title,
    required String content,
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
          child: Text('OK', style: TextStyle(color: accentColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin
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
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final spacing = screenHeight * 0.010;
          final buttonPadding = screenHeight * 0.018;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: screenWidth > 1200 ? 1200 : screenWidth,
              ),
              padding: EdgeInsets.all(spacing * 1.5),
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lottie animation with badge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ZoomIn(
                            duration: const Duration(milliseconds: 1000),
                            child: Lottie.asset(
                              'lib/assets/animations/resume_animation.json',
                              height: screenHeight * 0.18,
                              width: screenHeight * 0.18,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: screenHeight * 0.03,
                            right: -screenHeight * 0.04,
                            child: Container(
                              padding: EdgeInsets.all(spacing * 0.5),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.015,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI Resume Analyzer',
                        style: TextStyle(
                          fontSize: screenHeight * 0.035,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Optimize your resume with AI-powered insights',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: secondaryTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      // Input Fields and File Upload Section
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Name Field
                            _buildInputField(
                              context,
                              'Your Name',
                              Icons.person,
                              (value) => _name = value,
                              'Please enter your name',
                              initialValue: _name,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              accentColor: accentColor,
                            ),
                            SizedBox(height: spacing * 0.8),

                            // Job Role Field
                            _buildInputField(
                              context,
                              'Target Job Role',
                              Icons.work,
                              (value) => _jobRole = value,
                              'Please enter job role',
                              initialValue: _jobRole,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              accentColor: accentColor,
                            ),
                            SizedBox(height: spacing * 0.8),

                            // Job Description Field
                            _buildInputField(
                              context,
                              'Job Description',
                              Icons.description,
                              (value) => _jobDesc = value,
                              'Please enter job description',
                              initialValue: _jobDesc,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              accentColor: accentColor,
                              maxLines: 3,
                            ),
                            SizedBox(height: spacing * 1.2),

                            // File Upload Section with Analyze Button Below
                            FadeInRight(
                              duration: const Duration(milliseconds: 800),
                              child: Column(
                                children: [
                                  Text(
                                    'Upload Your Resume',
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.022,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.8),
                                  Container(
                                    width: screenWidth * 0.3,
                                    padding: EdgeInsets.all(spacing),
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Colors.grey.shade800
                                                  .withOpacity(0.5)
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Supported formats: PDF, DOCX, TXT',
                                          style: TextStyle(
                                            fontSize: screenHeight * 0.016,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        SizedBox(height: spacing * 0.8),
                                        ElasticIn(
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          child: ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.upload_file,
                                              size: screenHeight * 0.025,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              'Upload Resume',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.05,
                                                vertical: buttonPadding,
                                              ),
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ).copyWith(
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                    primaryColor.withOpacity(
                                                      0.8,
                                                    ),
                                                  ),
                                            ),
                                            onPressed: _processFile,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  ZoomIn(
                                    duration: const Duration(milliseconds: 600),
                                    child: Center(
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.analytics,
                                          size: screenHeight * 0.025,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Analyze Resume',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.06,
                                            vertical: buttonPadding,
                                          ),
                                          backgroundColor: accentColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ).copyWith(
                                          overlayColor: WidgetStateProperty.all(
                                            accentColor.withOpacity(0.8),
                                          ),
                                        ),
                                        onPressed: _submitForm,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: spacing),

                            // Selected File Info
                            if (_selectedFile != null)
                              FadeIn(
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  padding: EdgeInsets.all(spacing * 0.8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Selected: ${_selectedFile!.name}',
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.018,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.014,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String label,
    IconData icon,
    Function(String?) onSaved,
    String validationMsg, {
    String? initialValue,
    Color? textColor,
    Color? secondaryTextColor,
    Color? accentColor,
    int maxLines = 1,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: screenWidth * 0.5,
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.003),
        child: TextFormField(
          initialValue: initialValue,
          onChanged: onSaved,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              size: screenHeight * 0.025,
              color: accentColor,
            ),
            filled: true,
            fillColor:
                isDark
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor!.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            labelStyle: TextStyle(
              fontSize: screenHeight * 0.018,
              color: secondaryTextColor,
            ),
          ),
          style: TextStyle(color: textColor),
          maxLines: maxLines,
          validator: (value) => value?.isEmpty ?? true ? validationMsg : null,
          onSaved: onSaved,
        ),
      ),
    );
  }
}
