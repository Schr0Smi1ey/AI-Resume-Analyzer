import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/history_service.dart';
import '../../services/theme_provider.dart';
import '../login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final backgroundColor =
        isError
            ? Colors.red.withOpacity(0.8)
            : const Color(0xFF00C853).withOpacity(0.8);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _changePassword(BuildContext dialogContext) async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    final authService = Provider.of<AuthService>(dialogContext, listen: false);
    try {
      await authService.updatePassword(_passwordController.text);
      _passwordController.clear();
      _confirmPasswordController.clear();
      if (!mounted) return;
      Navigator.pop(dialogContext);
      _showSnackBar('Password updated successfully');
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        Navigator.pop(dialogContext);
        _showSnackBar(
          'Please sign out and sign in again to update your password',
          isError: true,
        );
        await authService.signOut();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update password: $e';
      });
    }
  }

  Future<void> _changeName(BuildContext dialogContext) async {
    if (!_nameFormKey.currentState!.validate()) {
      return;
    }
    final authService = Provider.of<AuthService>(dialogContext, listen: false);
    try {
      final user = authService.currentUser;
      if (user == null) {
        throw AuthException('no-user', 'No user signed in');
      }
      await authService.updateDisplayName(_nameController.text.trim());
      await user.reload(); // Force refresh user data
      _nameController.clear();
      if (!mounted) return;
      Navigator.pop(dialogContext);
      _showSnackBar('Name updated successfully');
      setState(() {}); // Trigger UI rebuild
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        Navigator.pop(dialogContext);
        _showSnackBar(
          'Please sign out and sign in again to update your name',
          isError: true,
        );
        await authService.signOut();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update name: $e';
      });
    }
  }

  void _showChangePasswordDialog() {
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
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;

    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setDialogState) => AlertDialog(
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    'Change Password',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  content: Form(
                    key: _passwordFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            labelStyle: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: accentColor,
                                semanticLabel:
                                    obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setDialogState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: accentColor,
                                semanticLabel:
                                    obscureConfirmPassword
                                        ? 'Show confirm password'
                                        : 'Hide confirm password',
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setDialogState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _errorMessage = null;
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _changePassword(dialogContext),
                      child: Text(
                        'Update',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showChangeNameDialog() {
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
    final cardColor =
        isDark ? const Color(0xFF1B5E20).withOpacity(0.3) : Colors.white;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setDialogState) => AlertDialog(
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    'Change Name',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  content: Form(
                    key: _nameFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'New Name',
                            labelStyle: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(
                              color: secondaryTextColor.withOpacity(0.6),
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
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          autofocus: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setDialogState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _errorMessage = null;
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _changeName(dialogContext),
                      child: Text(
                        'Update',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.person, color: accentColor),
                        trailing:
                            user != null
                                ? Icon(Icons.edit, size: 20, color: accentColor)
                                : null,
                        title: Text(
                          'Change Name',
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          user?.displayName ?? 'Not set',
                          style: TextStyle(
                            color:
                                user?.displayName != null
                                    ? textColor
                                    : secondaryTextColor,
                          ),
                        ),
                        onTap: user != null ? _showChangeNameDialog : null,
                        enabled: user != null,
                      ),
                      ListTile(
                        leading: Icon(Icons.email, color: accentColor),
                        title: Text(
                          'Email',
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          user?.email ?? 'Not signed in',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                        enabled: false,
                      ),
                      ListTile(
                        leading: Icon(Icons.lock, color: accentColor),
                        trailing:
                            user != null
                                ? Icon(Icons.edit, size: 20, color: accentColor)
                                : null,
                        title: Text(
                          'Change Password',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: user != null ? _showChangePasswordDialog : null,
                        enabled: user != null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        secondary: Icon(Icons.dark_mode, color: accentColor),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(color: textColor),
                        ),
                        value: themeProvider.themeMode == ThemeMode.dark,
                        activeColor: accentColor,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
                color: cardColor,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red.shade300),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red.shade300),
                  ),
                  onTap: () async {
                    await Provider.of<AuthService>(
                      context,
                      listen: false,
                    ).signOut();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(
                      context,
                      LoginScreen.routeName,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
