import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setDialogState) => AlertDialog(
                  title: const Text('Change Password'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _changePassword,
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showChangeNameDialog() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Change Name'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'New Name',
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.name,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(onPressed: _changeName, child: const Text('Update')),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: theme.cardTheme.elevation,
            shape: theme.cardTheme.shape,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.person,
                      semanticLabel: 'Change name',
                    ),
                    trailing:
                        user != null
                            ? const Icon(
                              Icons.edit,
                              size: 20,
                              semanticLabel: 'Edit name',
                            )
                            : null,
                    title: const Text('Change Name'),
                    subtitle: Text(
                      user?.displayName ?? 'Not set',
                      style: TextStyle(
                        color:
                            user?.displayName != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    onTap: user != null ? _showChangeNameDialog : null,
                    enabled: user != null,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.email,
                      semanticLabel: 'User email',
                    ),
                    title: const Text(
                      'Email',
                      semanticsLabel: 'User email address',
                    ),
                    subtitle: Text(user?.email ?? 'Not signed in'),
                    enabled: false,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.lock,
                      semanticLabel: 'Change password',
                    ),
                    trailing:
                        user != null
                            ? const Icon(
                              Icons.edit,
                              size: 20,
                              semanticLabel: 'Edit password',
                            )
                            : null,
                    title: const Text('Change Password'),
                    onTap: user != null ? _showChangePasswordDialog : null,
                    enabled: user != null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: theme.cardTheme.elevation,
            shape: theme.cardTheme.shape,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.dark_mode,
                      semanticLabel: 'Dark mode toggle',
                    ),
                    title: const Text('Dark Mode'),
                    value: themeProvider.themeMode == ThemeMode.dark,
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
            elevation: theme.cardTheme.elevation,
            shape: theme.cardTheme.shape,
            child: ListTile(
              leading: const Icon(Icons.logout, semanticLabel: 'Sign out'),
              title: const Text('Sign Out'),
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
=======
import '../../services/theme_provider.dart'; // Fixed import path (lowercase 's')

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: const Text('user@example.com'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Password'),
                          subtitle: const Text('••••••••'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'App Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          value: isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Clear History'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
    );
  }
}
