// shared_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';
export 'package:shared_preferences/shared_preferences.dart';

// Global variable for easy access to shared preferences throughout the app
late SharedPreferences prefs;

// Initialize shared preferences
Future<void> initSharedPreferences() async {
  prefs = await SharedPreferences.getInstance();
}