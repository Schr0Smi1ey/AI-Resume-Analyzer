import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login/login_screen.dart';
import 'screens/signup/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/resume_analysis/resume_preview_screen.dart';
import 'screens/resume_analysis/resume_analysis_screen.dart';
<<<<<<< HEAD
import 'screens/history/history_screen.dart';
import 'services/theme_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/history_service.dart';
=======
import 'services/theme_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
<<<<<<< HEAD
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Optionally, show an error screen or fallback UI
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
=======
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // For desktop window management
  SystemChrome.setPreferredOrientations([
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
<<<<<<< HEAD
  ]);

  runApp(const AIResumeAnalyzerApp());
=======
  ]).then((_) {
    runApp(const AIResumeAnalyzerApp());
  });
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
}

class AIResumeAnalyzerApp extends StatelessWidget {
  const AIResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
<<<<<<< HEAD
        Provider(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => ApiService()),
        Provider(create: (context) => AuthService()),
        Provider(create: (context) => HistoryService()),
=======
        ChangeNotifierProvider(create: (context) => ApiService()),
        Provider(create: (context) => AuthService()),
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI Resume Analyzer',
            debugShowCheckedModeBanner: false,
            theme: _buildThemeData(),
            darkTheme: _buildDarkThemeData(),
            themeMode: themeProvider.themeMode,
            initialRoute: LoginScreen.routeName,
            routes: {
              LoginScreen.routeName: (context) => const LoginScreen(),
              SignupScreen.routeName: (context) => const SignupScreen(),
              DashboardScreen.routeName: (context) => const DashboardScreen(),
<<<<<<< HEAD
              SettingsScreen.routeName: (context) => const SettingsScreen(),
              HistoryScreen.routeName: (context) => const HistoryScreen(),
              ResumePreviewScreen.routeName:
                  (context) => const ResumePreviewScreen(),
              ResumeAnalysisScreen.routeName:
                  (context) => ResumeAnalysisScreen(
                    args:
                        ModalRoute.of(context)?.settings.arguments
                            as Map<String, dynamic>,
                    preloadedAnalysis:
                        (ModalRoute.of(context)?.settings.arguments
                            as Map<String, dynamic>)['preloadedAnalysis'],
                  ),
=======
              ResumePreviewScreen.routeName:
                  (context) => const ResumePreviewScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == ResumeAnalysisScreen.routeName) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ResumeAnalysisScreen(args: args),
                );
              }
              return null;
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
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
<<<<<<< HEAD
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
=======
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
    );
  }

  ThemeData _buildDarkThemeData() {
    return ThemeData.dark().copyWith(
<<<<<<< HEAD
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
=======
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
<<<<<<< HEAD
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
=======
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
    );
  }
}
