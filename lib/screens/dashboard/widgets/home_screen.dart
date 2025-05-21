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

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _jobRole, _jobDesc;
  PlatformFile? _selectedFile;

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
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to upload file: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
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
            (context) => AlertDialog(
              title: const Text('Missing Resume'),
              content: const Text('Please upload your resume to proceed.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final spacing = screenHeight * 0.010;
        final buttonPadding = screenHeight * 0.018;

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
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
                                color:
                                    Colors
                                        .orange
                                        .shade400, // Lighter orange for visibility
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
                          color:
                              Colors
                                  .white, // Changed to white for dark background
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Optimize your resume with AI-powered insights',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color:
                              Colors.grey.shade300, // Lighter grey for subtitle
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(
                        height: spacing * 0.5,
                      ), // Reduced gap from spacing to spacing * 0.5
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
                            ),
                            SizedBox(height: spacing * 0.8),

                            // Job Role Field
                            _buildInputField(
                              context,
                              'Target Job Role',
                              Icons.work,
                              (value) => _jobRole = value,
                              'Please enter job role',
                            ),
                            SizedBox(height: spacing * 0.8),

                            // Job Description Field
                            _buildInputField(
                              context,
                              'Job Description',
                              Icons.description,
                              (value) => _jobDesc = value,
                              'Please enter job description',
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
                                      color:
                                          Colors
                                              .green
                                              .shade300, // Changed to white for dark background
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.8),
                                  Container(
                                    width: screenWidth * 0.3,
                                    padding: EdgeInsets.all(spacing),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                        0.3,
                                      ), // Slightly more opaque for visibility
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                          0.5,
                                        ), // Lighter border
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            0.3,
                                          ), // Darker shadow for contrast
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
                                            color:
                                                Colors
                                                    .grey
                                                    .shade300, // Lighter grey for text
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
                                            ),
                                            label: Text('Upload Resume'),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.05,
                                                vertical: buttonPadding,
                                              ),
                                              backgroundColor:
                                                  Colors
                                                      .blue
                                                      .shade400, // Lighter blue for visibility
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ).copyWith(
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                    Colors.blue.shade300,
                                                  ),
                                            ),
                                            onPressed: _processFile,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: spacing * 0.5,
                                  ), // Minimal gap between Upload and Analyze buttons
                                  ZoomIn(
                                    duration: const Duration(milliseconds: 600),
                                    child: Center(
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.analytics,
                                          size: screenHeight * 0.025,
                                        ),
                                        label: Text('Analyze Resume'),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.06,
                                            vertical: buttonPadding,
                                          ),
                                          backgroundColor:
                                              Colors
                                                  .purple
                                                  .shade400, // Lighter purple for visibility
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ).copyWith(
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.purple.shade300,
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
                                    color: Colors.green.shade800.withOpacity(
                                      0.3,
                                    ), // Darker green for contrast
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Selected: ${_selectedFile!.name}',
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.018,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Colors
                                                  .green
                                                  .shade200, // Lighter green for text
                                        ),
                                      ),
                                      Text(
                                        '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.014,
                                          color:
                                              Colors
                                                  .green
                                                  .shade300, // Lighter green for text
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
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String label,
    IconData icon,
    Function(String?) onSaved,
    String validationMsg, {
    int maxLines = 1,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: screenWidth * 0.5,
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.003),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              size: screenHeight * 0.025,
              color: Colors.blue.shade300,
            ), // Lighter blue for icon
            filled: true,
            fillColor: Colors.white.withOpacity(
              0.95,
            ), // More opaque for better contrast
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ), // Lighter border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue.shade300,
                width: 2,
              ), // Lighter blue for focus
            ),
            labelStyle: TextStyle(
              fontSize: screenHeight * 0.018,
              color: Colors.grey.shade400, // Lighter grey for label
            ),
          ),
          maxLines: maxLines,
          validator: (value) => value?.isEmpty ?? true ? validationMsg : null,
          onSaved: onSaved,
        ),
      ),
    );
  }
}
