import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../resume_analysis/login/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 6;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasDigit = password.contains(RegExp(r'\d'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
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

  void _showErrorModal(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Error',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: accentColor)),
              ),
            ],
          ),
    );
  }

  void _showVerificationModal() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Verify Your Email',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            content: Text(
              'A verification email has been sent to ${emailController.text.trim()}. Please verify your email and then log in.',
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.routeName,
                  );
                },
                child: Text('OK', style: TextStyle(color: accentColor)),
              ),
            ],
          ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    try {
      final user = await authService.registerWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        await user.updateDisplayName(name);
        await authService.signOut();
        _showVerificationModal();
      }
    } on AuthException catch (e) {
      _showErrorModal(e.message);
    }
  }

  Future<void> _signInWithGoogle() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final user = await authService.signInWithGoogle();
      if (user != null) {
        _showSnackBar('Google Sign-Up successful');
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardScreen.routeName,
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      _showErrorModal(e.message);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.removeListener(_validatePassword);
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define theme-dependent colors
    final primaryColor = const Color(0xFF00C853);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: FadeInUp(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutExpo,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/ai_resume_analyzer.png',
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join us to optimize your resume',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: accentColor,
                                  ),
                                  filled: true,
                                  fillColor: cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: accentColor,
                                  ),
                                  filled: true,
                                  fillColor: cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: accentColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: accentColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (!_hasMinLength ||
                                      !_hasUppercase ||
                                      !_hasDigit ||
                                      !_hasSpecialChar) {
                                    return 'Password does not meet requirements';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• Minimum 6 characters',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _hasMinLength
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    '• At least 1 uppercase letter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _hasUppercase
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    '• At least 1 digit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _hasDigit ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    '• At least 1 special character',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _hasSpecialChar
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: accentColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: accentColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _signUp,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.all(
                                      accentColor,
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _signInWithGoogle,
                                  icon: Image.asset(
                                    'lib/assets/images/google_logo.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  label: Text(
                                    'Sign up with Google',
                                    style: TextStyle(color: accentColor),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    foregroundColor: accentColor,
                                    side: BorderSide(
                                      color: accentColor.withOpacity(0.5),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed:
                                    () => Navigator.pushReplacementNamed(
                                      context,
                                      LoginScreen.routeName,
                                    ),
                                child: Text(
                                  'Already have an account? Login',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
