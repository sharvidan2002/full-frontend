// menu_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the actual package
import 'resources_screen.dart';
import 'auth_screens.dart'; // Import auth_screens for WelcomeScreen

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  // Handle logout
  void _handleLogout(BuildContext context) async {
    // Show logout confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Get SharedPreferences instance
              final prefs = await SharedPreferences.getInstance();

              // Clear logged in status but keep onboarding and screening flags
              prefs.setBool('isLoggedIn', false);

              // Close the dialog
              Navigator.pop(context);

              // Navigate back to welcome/login screen and remove all routes from stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
                    (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF6E77F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF6E77F6)),
            title: const Text('Profile'),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Color(0xFF6E77F6)),
            title: const Text('Daily Tasks'),
            onTap: () {
              // Navigate to daily tasks screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.mood, color: Color(0xFF6E77F6)),
            title: const Text('Mood Tracker'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
              // Access the state of MainNavigationScreen to change the index
              // This is a simplified approach - you might want to use state management
              // like Provider or Riverpod for this in a real app
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Color(0xFF6E77F6)),
            title: const Text('Resources'),
            onTap: () {
              // Navigate to resources screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResourcesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Color(0xFF6E77F6)),
            title: const Text('Support Groups'),
            onTap: () {
              // Navigate to support groups screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note, color: Color(0xFF6E77F6)),
            title: const Text('Journal'),
            onTap: () {
              // Navigate to journal screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF6E77F6)),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF6E77F6)),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help and support screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Call the logout handler
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }
}

// Re-export MainNavigationScreen for use in this file
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is just a stub for the reference in this file
    // The actual implementation is in main.dart
    return Container();
  }
}