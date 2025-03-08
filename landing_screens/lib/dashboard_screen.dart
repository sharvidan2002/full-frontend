// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'shared_preferences.dart'; // Import shared_preferences
import 'chat_bot_screen.dart';
import 'mood_tracker_screen.dart';
import 'treatment_plan_screens.dart';
import 'resources_screen.dart';

class DashboardScreen extends StatefulWidget {
  final TreatmentPlan? selectedPlan;
  final DateTime startDate;

  const DashboardScreen({
    Key? key,
    this.selectedPlan,
    required this.startDate,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  TreatmentPlan? _selectedPlan; // Local copy of the selected plan

  // Get plans from TreatmentPlanFlow
  List<TreatmentPlan> get plans => TreatmentPlanFlow.getPlans();

  // Track daily tasks
  List<TaskItem> dailyTasks = [
    TaskItem(title: 'Task 1', isCompleted: false),
    TaskItem(title: 'Task 2', isCompleted: false),
    TaskItem(title: 'Task 3', isCompleted: false),
    TaskItem(title: 'Task 4', isCompleted: false),
    TaskItem(title: 'Task 5', isCompleted: false),
    TaskItem(title: 'Task 6', isCompleted: false),
    TaskItem(title: 'Task 7', isCompleted: false),
    TaskItem(title: 'Task 8', isCompleted: false),
    TaskItem(title: 'Task 9', isCompleted: false),
  ];

  // Track exercises
  List<TaskItem> exercises = [
    TaskItem(title: 'Exercise 1', isCompleted: false),
    TaskItem(title: 'Exercise 2', isCompleted: false),
    TaskItem(title: 'Exercise 3', isCompleted: false),
    TaskItem(title: 'Exercise 4', isCompleted: false),
    TaskItem(title: 'Exercise 5', isCompleted: false),
    TaskItem(title: 'Exercise 6', isCompleted: false),
    TaskItem(title: 'Exercise 7', isCompleted: false),
    TaskItem(title: 'Exercise 8', isCompleted: false),
    TaskItem(title: 'Exercise 9', isCompleted: false),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.selectedPlan; // Initialize local copy
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    // If no selected plan was passed, try to get it from preferences
    if (_selectedPlan == null) {
      _retrieveSelectedPlan();
    }
  }

  // Retrieve plan from SharedPreferences
  Future<void> _retrieveSelectedPlan() async {
    final planName = prefs.getString('selectedPlanName');
    if (planName != null) {
      // Find the plan with the saved name
      for (var plan in plans) {
        if (plan.name == planName) {
          setState(() {
            _selectedPlan = plan;
          });
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Handle logout
  void _handleLogout() {
    // Clear logged in status but keep onboarding and screening flags
    prefs.setBool('isLoggedIn', false);

    // Navigate back to welcome/login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/welcome',
          (route) => false,
    );
  }

  // Calculate sobriety period
  String _getSobrietyPeriod() {
    final now = DateTime.now();
    final difference = now.difference(widget.startDate);

    int days = difference.inDays;
    int months = (days / 30).floor();
    int remainingDays = days % 30;

    return '$months months, $remainingDays days';
  }

  // Calculate progress percentages
  double get dailyTasksPercentage {
    if (dailyTasks.isEmpty) return 0.0;
    int completedCount = dailyTasks.where((task) => task.isCompleted).length;
    return (completedCount / dailyTasks.length) * 100;
  }

  double get exercisesPercentage {
    if (exercises.isEmpty) return 0.0;
    int completedCount = exercises.where((exercise) => exercise.isCompleted).length;
    return (completedCount / exercises.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF7F9FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header with welcome message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Home',
                            style: TextStyle(
                              fontSize: 28,
                              color: Color(0xFF6E77F6),
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6E77F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.celebration,
                                  color: Color(0xFF6E77F6),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Sobriety: ${_getSobrietyPeriod()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6E77F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      _buildTabButton('Daily Tasks', 0),
                      _buildTabButton('Milestones', 1),
                      _buildTabButton('Exercises', 2),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDailyTasksTab(),
                    _buildMilestonesTab(),
                    _buildExercisesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? const Color(0xFF6E77F6) : Colors.transparent,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: const Color(0xFF6E77F6).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTasksTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dailyTasks.length,
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Theme(
                data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    dailyTasks[index].title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      decoration: dailyTasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: dailyTasks[index].isCompleted
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                  value: dailyTasks[index].isCompleted,
                  activeColor: const Color(0xFF6E77F6),
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      dailyTasks[index].isCompleted = value ?? false;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExercisesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: exercises.length,
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Theme(
                data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    exercises[index].title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      decoration: exercises[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: exercises[index].isCompleted
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                  value: exercises[index].isCompleted,
                  activeColor: const Color(0xFF6E77F6),
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      exercises[index].isCompleted = value ?? false;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMilestonesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Tasks Progress
            _buildProgressSection('Daily Tasks', dailyTasksPercentage),
            const SizedBox(height: 30),
            // Exercises Progress
            _buildProgressSection('Exercises', exercisesPercentage),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(String title, double percentage) {
    final Color progressColor = percentage > 75
        ? const Color(0xFF4CAF50)  // Green for high progress
        : percentage > 40
        ? const Color(0xFF6E77F6)  // Blue for medium progress
        : const Color(0xFFFFA726);  // Orange for low progress

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    title == 'Daily Tasks' ? Icons.assignment : Icons.fitness_center,
                    color: const Color(0xFF6E77F6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E77F6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Progress
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: MediaQuery.of(context).size.width * (percentage / 100) * 0.67, // Adjusting for padding
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor.withOpacity(0.7),
                            progressColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to handle menu options
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuOption(
                icon: Icons.person,
                title: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile screen
                },
              ),
              _buildMenuOption(
                icon: Icons.menu_book,
                title: 'Resources',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to resources screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResourcesScreen()),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings screen
                },
              ),
              _buildMenuOption(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help screen
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(thickness: 1),
              ),
              _buildMenuOption(
                icon: Icons.exit_to_app,
                title: 'Logout',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  // Call the logout method with SharedPreferences
                  _handleLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF6E77F6),
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color == Colors.red ? color : Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

// Model class for task items
class TaskItem {
  final String title;
  bool isCompleted;

  TaskItem({
    required this.title,
    required this.isCompleted,
  });
}