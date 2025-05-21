import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../login/login_screen.dart';
import './widgets/home_screen.dart'; // Assumed path
=======
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import "../login/login_screen.dart";
import './widgets/home_screen.dart';
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
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
<<<<<<< HEAD
    final authService = Provider.of<AuthService>(context);
    final userName = authService.currentUser?.displayName ?? 'User';

=======
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('AI Resume Analyzer'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
<<<<<<< HEAD
      drawer: _buildDrawer(context, userName),
=======
      drawer: _buildDrawer(context),
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
      body: PageStorage(
        bucket: PageStorageBucket(),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

<<<<<<< HEAD
  Drawer _buildDrawer(BuildContext context, String userName) {
=======
  Drawer _buildDrawer(BuildContext context) {
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
<<<<<<< HEAD
                  'Welcome, $userName!',
=======
                  'Welcome, User!',
>>>>>>> 4fa26bbdaa87cc69a5d317773c659969cf7cd551
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Analysis History'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
