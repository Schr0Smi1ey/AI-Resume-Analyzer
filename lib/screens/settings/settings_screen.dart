import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/history_service.dart';
import '../../services/theme_provider.dart';
import '../login/login_screen.dart';

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

  Future<void> _changePassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.updatePassword(_passwordController.text);
      _passwordController.clear();
      _confirmPasswordController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Password updated successfully');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update password: $e', isError: true);
    }
  }

  Future<void> _changeName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Name cannot be empty', isError: true);
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.updateDisplayName(name);
      _nameController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Name updated successfully');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update name: $e', isError: true);
    }
  }

  void _showChangePasswordDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);

    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setDialogState) => AlertDialog(
                  title: Text(
                    'Change Password',
                    style: TextStyle(color: textColor),
                  ),
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(
                            color: textColor.withOpacity(0.8),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: accentColor.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: accentColor.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: accentColor),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textColor.withOpacity(0.6),
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
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                            color: textColor.withOpacity(0.8),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: accentColor.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: accentColor.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: accentColor),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textColor.withOpacity(0.6),
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
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                    TextButton(
                      onPressed: _changePassword,
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
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Change Name', style: TextStyle(color: textColor)),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'New Name',
                labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.name,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel', style: TextStyle(color: accentColor)),
              ),
              TextButton(
                onPressed: _changeName,
                child: Text('Update', style: TextStyle(color: accentColor)),
              ),
            ],
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
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: accentColor.withOpacity(0.3)),
            ),
            color:
                isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                    title: Text('Email', style: TextStyle(color: textColor)),
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
            color:
                isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
            color:
                isDark ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
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
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }
}
