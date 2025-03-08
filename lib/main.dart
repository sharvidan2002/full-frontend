// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'auth_screens.dart' as auth;
import 'assist_screens.dart' as assist;
import 'dashboard_screen.dart';
import 'treatment_plan_screens.dart';
import 'chat_bot_screen.dart';
import 'mood_tracker_screen.dart';
import 'resources_screen.dart';
import 'menu_screen.dart';
import 'shared_preferences.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await initSharedPreferences();

  // Set preferred orientations to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NaraApp());
}

class NaraApp extends StatelessWidget {
  const NaraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NARA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6E77F6),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF6E77F6),
          secondary: const Color(0xFF6E77F6),
        ),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start with splash screen, then decide route in the splash screen
      home: const SplashScreen(),
      // Define all app routes
      routes: {
        '/welcome': (context) => const auth.WelcomeScreen(),
        '/login': (context) => const auth.WelcomeScreen(),
        '/signup': (context) => const auth.CreateAccountScreen(),
        '/assist': (context) => const assist.AssistLandingScreen(),
        '/treatment-plans': (context) {
          // Extract arguments if available
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TreatmentPlanFlow(
            onComplete: args?['onComplete'] ?? () {
              // Default completion handler
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          );
        },
        '/dashboard': (context) {
          // Extract arguments if available
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          // Get selected plan from arguments or try to find by name in preferences
          TreatmentPlan? selectedPlan = args?['selectedPlan'];
          final startDate = args?['startDate'] ?? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('startDate') ?? DateTime.now().millisecondsSinceEpoch);

          // If arguments don't have the plan, try to get it from preferences
          if (selectedPlan == null) {
            final planName = prefs.getString('selectedPlanName');
            if (planName != null) {
              // Find the plan with the saved name
              final plans = TreatmentPlanFlow.getPlans();
              for (var plan in plans) {
                if (plan.name == planName) {
                  selectedPlan = plan;
                  break;
                }
              }
            }
          }

          // Save start date to preferences if it's from arguments
          if (args != null && args.containsKey('startDate')) {
            prefs.setInt('startDate', startDate.millisecondsSinceEpoch);
          }

          return MainNavigationScreen(
            selectedPlan: selectedPlan,
            startDate: startDate,
          );
        },
      },
    );
  }
}

// Splash Screen (NARA)
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after a delay
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if we're still mounted before navigating
    if (!mounted) return;

    // Check all flags with debug outputs
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final hasCompletedScreeningEver = prefs.getBool('hasCompletedScreeningEver') ?? false;

    print("SPLASH SCREEN STATE CHECK:");
    print("Onboarding completed: $hasCompletedOnboarding");
    print("Is logged in: $isLoggedIn");
    print("Screening completed: $hasCompletedScreeningEver");

    if (!hasCompletedOnboarding) {
      // First time user - start with onboarding
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen1(),
        ),
      );
    } else if (!isLoggedIn) {
      // Onboarding completed but not logged in
      Navigator.pushReplacementNamed(context, '/welcome');
    } else if (!hasCompletedScreeningEver) {
      // Logged in but never completed screening
      print("Navigating to screening because hasCompletedScreeningEver = $hasCompletedScreeningEver");
      Navigator.pushReplacementNamed(context, '/assist');
    } else {
      // Fully onboarded user - go to dashboard
      print("Navigating to dashboard - all steps completed");
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NARA',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the path of self-restoration!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // No button needed as we automatically navigate
            const SizedBox(height: 80), // Space at bottom
          ],
        ),
      ),
    );
  }
}

// Onboarding Screen 1
class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      title: 'Embark on the journey of self-healing!',
      currentPage: 0,
      totalPages: 3,
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen2(),
          ),
        );
      },
      onSkip: () {
        // Mark onboarding as completed
        prefs.setBool('hasCompletedOnboarding', true);
        Navigator.pushReplacementNamed(context, '/welcome');
      },
    );
  }
}

// Onboarding Screen 2
class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      title: 'Support That Extends Beyond Individuals',
      currentPage: 1,
      totalPages: 3,
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen3(),
          ),
        );
      },
      onSkip: () {
        // Mark onboarding as completed
        prefs.setBool('hasCompletedOnboarding', true);
        Navigator.pushReplacementNamed(context, '/welcome');
      },
    );
  }
}

// Onboarding Screen 3
class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      title: 'Personalized AI Assistance Redefined',
      currentPage: 2,
      totalPages: 3,
      onNext: () {
        // Mark onboarding as completed
        prefs.setBool('hasCompletedOnboarding', true);
        Navigator.pushReplacementNamed(context, '/welcome');
      },
      onSkip: () {
        // Mark onboarding as completed
        prefs.setBool('hasCompletedOnboarding', true);
        Navigator.pushReplacementNamed(context, '/welcome');
      },
    );
  }
}

// Reusable Template for Onboarding Screens
class OnboardingTemplate extends StatelessWidget {
  final String title;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingTemplate({
    Key? key,
    required this.title,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == currentPage
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.2),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onSkip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Skip'),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Main Navigation Screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  final TreatmentPlan? selectedPlan;
  final DateTime startDate;

  const MainNavigationScreen({
    Key? key,
    this.selectedPlan,
    required this.startDate,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize screens
    _screens = [
      DashboardScreen(
        selectedPlan: widget.selectedPlan,
        startDate: widget.startDate,
      ),
      const MoodTrackerScreen(),
      const ChatBotScreen(),
      const ResourcesScreen(),
      const MenuScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Set Navigation Bar theme
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 10,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mood_outlined),
              activeIcon: Icon(Icons.mood),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Resources',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_outlined),
              activeIcon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}