import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../resume_analysis/login/login_screen.dart';
import './widgets/home_screen.dart'; // Assumed path

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _widgetOptions = const [
    HomeScreen(key: PageStorageKey('homeScreen')),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userName = authService.currentUser?.displayName ?? 'User';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('AI Resume Analyzer', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textColor),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      drawer: _buildDrawer(
        context,
        userName,
        backgroundColor,
        textColor,
        accentColor,
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color:
                  _selectedIndex == 0
                      ? accentColor
                      : textColor.withOpacity(0.6),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color:
                  _selectedIndex == 1
                      ? accentColor
                      : textColor.withOpacity(0.6),
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color:
                  _selectedIndex == 2
                      ? accentColor
                      : textColor.withOpacity(0.6),
            ),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: backgroundColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textColor.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Drawer _buildDrawer(
    BuildContext context,
    String userName,
    Color backgroundColor,
    Color textColor,
    Color accentColor,
  ) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: accentColor.withOpacity(0.2),
                  child: Icon(Icons.person, size: 40, color: accentColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome, $userName!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    fontSize: 14,
                    color: accentColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: textColor),
            title: Text('Home', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: textColor),
            title: Text('Analysis History', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: textColor),
            title: Text('Settings', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade300),
            title: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red.shade300),
            ),
            onTap: () {
              Navigator.pop(context);
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
