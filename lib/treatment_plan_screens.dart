// treatment_plan_screens.dart
import 'package:flutter/material.dart';
import 'shared_preferences.dart'; // Import shared_preferences

// Model class for Plan Item
class PlanActivity {
  final String title;

  PlanActivity({required this.title});
}

// Model class for Treatment Plan
class TreatmentPlan {
  final String name;
  final String description;
  final List<PlanActivity> activities;
  final String duration;

  TreatmentPlan({
    required this.name,
    required this.description,
    required this.activities,
    required this.duration,
  });
}

// Plan Selection Screen
class PlanSelectionScreen extends StatelessWidget {
  final Function(TreatmentPlan) onPlanSelected;

  PlanSelectionScreen({
    Key? key,
    required this.onPlanSelected,
  }) : super(key: key);

  final List<TreatmentPlan> plans = [
    TreatmentPlan(
      name: 'Fresh Start',
      description: 'A new day, a fresh start. This plan helps you build stability with small, mindful steps. One choice at a time—you\'re not alone.',
      activities: [
        PlanActivity(title: 'Self-check-in, gratitude journaling'),
        PlanActivity(title: 'Hydration, balanced meals'),
        PlanActivity(title: 'Gentle stretching, short walks'),
        PlanActivity(title: 'Support groups, meaningful conversations'),
      ],
      duration: '10-15 mins',
    ),
    TreatmentPlan(
      name: 'Strong Everyday',
      description: 'Show up daily, build strength & balance, and take control of your recovery.',
      activities: [
        PlanActivity(title: 'Walking, light strength training'),
        PlanActivity(title: 'Affirmations, deep breathing'),
        PlanActivity(title: 'Triggers & coping strategies'),
      ],
      duration: '20-30 mins',
    ),
    TreatmentPlan(
      name: 'Resilience',
      description: 'Push forward with discipline. Your past doesn\'t define you—your actions do.',
      activities: [
        PlanActivity(title: 'Strength training, endurance workouts'),
        PlanActivity(title: 'Journaling, reframing challenges'),
        PlanActivity(title: 'Screen-free relaxation, gratitude'),
      ],
      duration: '30-45 mins',
    ),
    TreatmentPlan(
      name: 'Unbreakable',
      description: 'A holistic approach to emotional & physical recovery—you are unbreakable.',
      activities: [
        PlanActivity(title: 'Meditation, emotional check-ins'),
        PlanActivity(title: 'Walks, swimming, stretching'),
        PlanActivity(title: 'Support groups, meaningful conversations'),
      ],
      duration: '20-30 mins',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Let\'s Choose a plan',
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF6E77F6),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'select the plan you think is most suitable for you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: plans.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    return _buildPlanButton(context, plans[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanButton(BuildContext context, TreatmentPlan plan) {
    return InkWell(
      onTap: () => onPlanSelected(plan),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF6E77F6),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            plan.name,
            style: TextStyle(
              color: const Color(0xFF6E77F6),
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Plan Detail Screen
class PlanDetailScreen extends StatelessWidget {
  final TreatmentPlan plan;
  final VoidCallback onStartPlan;

  const PlanDetailScreen({
    Key? key,
    required this.plan,
    required this.onStartPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          plan.name,
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF6E77F6),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: plan.activities.length + 1, // +1 for the duration item
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index < plan.activities.length) {
                      return _buildActivityItem(plan.activities[index]);
                    } else {
                      return _buildActivityItem(PlanActivity(title: plan.duration));
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Add debug print
                    print("Starting plan: ${plan.name}");

                    // Call the onStartPlan callback
                    onStartPlan();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start this Plan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(PlanActivity activity) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF6E77F6),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Text(
          activity.title,
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// This is the main wrapper that handles navigation between plan screens
class TreatmentPlanFlow extends StatefulWidget {
  final VoidCallback onComplete;

  const TreatmentPlanFlow({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  static List<TreatmentPlan> getPlans() {
    return [
      TreatmentPlan(
        name: 'Fresh Start',
        description: 'A new day, a fresh start. This plan helps you build stability with small, mindful steps. One choice at a time—you\'re not alone.',
        activities: [
          PlanActivity(title: 'Self-check-in, gratitude journaling'),
          PlanActivity(title: 'Hydration, balanced meals'),
          PlanActivity(title: 'Gentle stretching, short walks'),
          PlanActivity(title: 'Support groups, meaningful conversations'),
        ],
        duration: '10-15 mins',
      ),
      TreatmentPlan(
        name: 'Strong Everyday',
        description: 'Show up daily, build strength & balance, and take control of your recovery.',
        activities: [
          PlanActivity(title: 'Walking, light strength training'),
          PlanActivity(title: 'Affirmations, deep breathing'),
          PlanActivity(title: 'Triggers & coping strategies'),
        ],
        duration: '20-30 mins',
      ),
      TreatmentPlan(
        name: 'Resilience',
        description: 'Push forward with discipline. Your past doesn\'t define you—your actions do.',
        activities: [
          PlanActivity(title: 'Strength training, endurance workouts'),
          PlanActivity(title: 'Journaling, reframing challenges'),
          PlanActivity(title: 'Screen-free relaxation, gratitude'),
        ],
        duration: '30-45 mins',
      ),
      TreatmentPlan(
        name: 'Unbreakable',
        description: 'A holistic approach to emotional & physical recovery—you are unbreakable.',
        activities: [
          PlanActivity(title: 'Meditation, emotional check-ins'),
          PlanActivity(title: 'Walks, swimming, stretching'),
          PlanActivity(title: 'Support groups, meaningful conversations'),
        ],
        duration: '20-30 mins',
      ),
    ];
  }

  @override
  State<TreatmentPlanFlow> createState() => _TreatmentPlanFlowState();
}

class _TreatmentPlanFlowState extends State<TreatmentPlanFlow> {
  TreatmentPlan? selectedPlan;

  void _selectPlan(TreatmentPlan plan) {
    setState(() {
      selectedPlan = plan;
    });

    // Store the selected plan name in preferences
    prefs.setString('selectedPlanName', plan.name);

    // BACKUP: Also set the screening completed flag here
    prefs.setBool('hasCompletedScreeningEver', true);
    print("Flag set in treatment plan selection: ${prefs.getBool('hasCompletedScreeningEver')}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailScreen(
          plan: plan,
          onStartPlan: () {
            // First pop back to plan selection screen
            Navigator.pop(context);

            // Store the plan start date
            final startDate = DateTime.now();

            // AGAIN set the flag as a triple-backup
            prefs.setBool('hasCompletedScreeningEver', true);

            // Navigate to dashboard with the selected plan and start date
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
                  (route) => false,
              arguments: {
                'selectedPlan': plan,
                'startDate': startDate,
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlanSelectionScreen(
      onPlanSelected: _selectPlan,
    );
  }
}

// Example of how to integrate with the existing flow
class IntegrationExample extends StatelessWidget {
  const IntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // After assessment is complete, show the treatment plan flow
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TreatmentPlanFlow(
                    onComplete: () {
                      // Handle when user starts a plan
                      Navigator.pop(context); // Return to main screen or next step
                    },
                  ),
                ),
              );
            },
            child: Text('Show Treatment Plans'),
          ),
        ),
      ),
    );
  }
}