import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/resume_analysis/login/login_screen.dart';
import 'screens/signup/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/resume_analysis/resume_preview_screen.dart';
import 'screens/resume_analysis/resume_analysis_screen.dart';
import 'screens/history/history_screen.dart';
import 'services/theme_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? errorMessage;

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    errorMessage = 'Failed to load environment variables: $e';
  }

  // Initialize Firebase
  if (errorMessage == null) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      errorMessage = 'Failed to initialize Firebase: $e';
    }
  }

  // Set preferred orientations
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    errorMessage ??= 'Failed to set device orientations: $e';
  }

  // If there's an error, run the app with ErrorScreen; otherwise, run the main app
  runApp(
    errorMessage != null
        ? ErrorScreenApp(errorMessage: errorMessage)
        : const AIResumeAnalyzerApp(),
  );
}

// ErrorScreenApp to display initialization errors
class ErrorScreenApp extends StatelessWidget {
  final String errorMessage;

  const ErrorScreenApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Analyzer - Error',
      debugShowCheckedModeBanner: false,
      home: ErrorScreen(errorMessage: errorMessage),
    );
  }
}

// ErrorScreen widget to display error messages
class ErrorScreen extends StatelessWidget {
  final String errorMessage;

  const ErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Optionally, allow retrying the app initialization
                  SystemNavigator.pop(); // Exit the app, or implement retry logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close App', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIResumeAnalyzerApp extends StatelessWidget {
  const AIResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => ApiService()),
        Provider(create: (context) => AuthService()),
        Provider(create: (context) => HistoryService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI Resume Analyzer',
            debugShowCheckedModeBanner: false,
            theme: _buildThemeData(),
            darkTheme: _buildDarkThemeData(),
            themeMode: themeProvider.themeMode,
            home: const LoginScreen(), // Fallback home screen
            initialRoute: LoginScreen.routeName,
            routes: {
              LoginScreen.routeName: (context) => const LoginScreen(),
              SignupScreen.routeName: (context) => const SignupScreen(),
              DashboardScreen.routeName: (context) => const DashboardScreen(),
              SettingsScreen.routeName: (context) => const SettingsScreen(),
              HistoryScreen.routeName: (context) => const HistoryScreen(),
              ResumePreviewScreen.routeName:
                  (context) => const ResumePreviewScreen(),
              ResumeAnalysisScreen.routeName: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return ResumeAnalysisScreen(
                  args:
                      args is Map<String, dynamic>
                          ? args
                          : {}, // Fallback to empty map
                  preloadedAnalysis:
                      args is Map<String, dynamic>
                          ? args['preloadedAnalysis']
                          : null,
                );
              },
            },
            onUnknownRoute: (settings) {
              // Fallback for undefined routes
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData _buildDarkThemeData() {
    return ThemeData.dark().copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
