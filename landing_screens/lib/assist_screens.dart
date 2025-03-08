// assist_screens.dart
import 'package:flutter/material.dart';
import 'package:nara_app/treatment_plan_screens.dart';
import 'main.dart';
import 'shared_preferences.dart';

// Data model for substance use
class SubstanceData {
  final String name;
  final String description;
  bool usedInLifetime = false;
  int frequencyLast3Months = 0; // 0-Never, 2-Once/Twice, 3-Monthly, 4-Weekly, 6-Daily
  int urgeToUse = 0; // 0-Never, 3-Once/Twice, 4-Monthly, 5-Weekly, 6-Daily
  int healthSocialProblems = 0; // 0-Never, 4-Once/Twice, 5-Monthly, 6-Weekly, 7-Daily
  int failedResponsibilities = 0; // 0-Never, 5-Once/Twice, 6-Monthly, 7-Weekly, 8-Daily
  int concernFromOthers = 0; // 0-No never, 6-Yes in past 3 months, 3-Yes but not in past 3 months
  int triedToControl = 0; // 0-No never, 6-Yes in past 3 months, 3-Yes but not in past 3 months
  bool injected = false;
  int injectionFrequency = 0; // 0-No, 1-Yes <4 days/month, 2-Yes >4 days/month

  SubstanceData({
    required this.name,
    required this.description,
  });

  int calculateScore() {
    // Skip Q5 (failedResponsibilities) for tobacco
    if (name.contains('Tobacco')) {
      return frequencyLast3Months +
          urgeToUse +
          healthSocialProblems +
          concernFromOthers +
          triedToControl;
    } else {
      return frequencyLast3Months +
          urgeToUse +
          healthSocialProblems +
          failedResponsibilities +
          concernFromOthers +
          triedToControl;
    }
  }

  String getRiskLevel() {
    int score = calculateScore();

    if (name.contains('Alcohol')) {
      if (score >= 0 && score <= 10) return 'Lower Risk';
      if (score >= 11 && score <= 26) return 'Moderate Risk';
      if (score >= 27) return 'High Risk';
    } else {
      if (score >= 0 && score <= 3) return 'Lower Risk';
      if (score >= 4 && score <= 26) return 'Moderate Risk';
      if (score >= 27) return 'High Risk';
    }
    return 'Unknown Risk';
  }
}

// Main ASSIST Questionnaire Flow Screen
class AssistQuestionnaireScreen extends StatefulWidget {
  const AssistQuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<AssistQuestionnaireScreen> createState() => _AssistQuestionnaireScreenState();
}

// In your assist_screens.dart file, modify the _AssistQuestionnaireScreenState class
// to navigate to treatment plans after completing the questionnaire:

class _AssistQuestionnaireScreenState extends State<AssistQuestionnaireScreen> {
  final AssistQuestionnaire _questionnaire = AssistQuestionnaire();
  int _currentStep = 0;

  void _goToNextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _updateQuestionnaire(AssistQuestionnaire updatedQuestionnaire) {
    setState(() {
      _questionnaire.substances = updatedQuestionnaire.substances;
      _questionnaire.otherSubstanceSpecify = updatedQuestionnaire.otherSubstanceSpecify;
      _currentStep++;
    });
  }

  void _finishQuestionnaire() {
    print("Setting hasCompletedScreeningEver to true"); // Debug log

    // EXPLICITLY set the flag to true with proper key name
    prefs.setBool('hasCompletedScreeningEver', true);

    // Double-check that the flag was set correctly
    print("Flag set? ${prefs.getBool('hasCompletedScreeningEver')}"); // Should print true

    // CRITICAL: Save the result immediately to ensure persistence
    prefs.commit(); // Note: If your Flutter version is newer, this might be automatic

    // Navigate to treatment plans
    Navigator.pushNamed(
      context,
      '/treatment-plans',
      arguments: {
        'onComplete': () {
          // After treatment plan selection, make sure the flag is still set
          final flagSet = prefs.getBool('hasCompletedScreeningEver') ?? false;
          print("Flag still set after treatment plan? $flagSet"); // Debug log

          // Go to dashboard and clear all previous screens
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
                (route) => false,
          );
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return IntroScreen(
          onNextPressed: _goToNextStep,
        );
      case 1:
        return LifetimeUseScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 2:
      // Check if there are any substances used in lifetime
        if (_questionnaire.getUsedSubstances().isEmpty) {
          // No substances used, skip to results
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentStep = 8; // Jump to results
            });
          });
          return Container(); // Return empty container while redirecting
        }
        return FrequencyScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 3:
      // Check if there are any substances used in last 3 months
        if (_questionnaire.getUsedLast3Months().isEmpty) {
          // No substances used in last 3 months, skip to Q6
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentStep = 6; // Jump to Q6
            });
          });
          return Container(); // Return empty container while redirecting
        }
        return UrgeToUseScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 4:
        return ProblemsScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 5:
        return FailedResponsibilitiesScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 6:
        return ConcernScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 7:
        return CutDownScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 8:
        return InjectionScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 9:
        return ResultsScreen(
          questionnaire: _questionnaire,
          onFinish: _finishQuestionnaire,
        );
      default:
        return WelcomeScreen(
          onStartPressed: () {
            setState(() {
              _currentStep = 0;
            });
          },
        );
    }
  }
}

class AssistQuestionnaire {
  List<SubstanceData> substances = [
    SubstanceData(
      name: 'Tobacco products',
      description: '(cigarettes, chewing tobacco, cigars, etc.)',
    ),
    SubstanceData(
      name: 'Alcoholic beverages',
      description: '(beer, wine, spirits, etc.)',
    ),
    SubstanceData(
      name: 'Cannabis',
      description: '(marijuana, pot, grass, hash, etc.)',
    ),
    SubstanceData(
      name: 'Cocaine',
      description: '(coke, crack, etc.)',
    ),
    SubstanceData(
      name: 'Amphetamine-type stimulants',
      description: '(speed, meth, ecstasy, etc.)',
    ),
    SubstanceData(
      name: 'Inhalants',
      description: '(nitrous, glue, petrol, paint thinner, etc.)',
    ),
    SubstanceData(
      name: 'Sedatives or sleeping pills',
      description: '(diazepam, alprazolam, flunitrazepam, midazolam, etc.)',
    ),
    SubstanceData(
      name: 'Hallucinogens',
      description: '(LSD, acid, mushrooms, trips, ketamine, etc.)',
    ),
    SubstanceData(
      name: 'Opioids',
      description: '(heroin, morphine, methadone, buprenorphine, codeine, etc.)',
    ),
    SubstanceData(
      name: 'Other',
      description: '',
    ),
  ];

  String otherSubstanceSpecify = '';

  List<SubstanceData> getUsedSubstances() {
    return substances.where((substance) => substance.usedInLifetime).toList();
  }

  List<SubstanceData> getUsedLast3Months() {
    return getUsedSubstances().where((substance) => substance.frequencyLast3Months > 0).toList();
  }

  int calculateHighestScore() {
    int highestScore = 0;
    for (var substance in substances) {
      final score = substance.calculateScore();
      if (score > highestScore) {
        highestScore = score;
      }
    }
    return highestScore;
  }
}

class AssistLandingScreen extends StatelessWidget {
  const AssistLandingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ASSIST Questionnaire',
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome to the ASSIST Questionnaire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6E77F6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'This questionnaire will help assess your substance use patterns and provide personalized feedback.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssistQuestionnaireScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Questionnaire',
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
}

// Welcome/Intro Screen
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStartPressed;

  const WelcomeScreen({
    Key? key,
    required this.onStartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test Yourself!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: onStartPressed,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E77F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Question 6: Expressed Concern by Others
class ConcernScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const ConcernScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<ConcernScreen> createState() => _ConcernScreenState();
}

class _ConcernScreenState extends State<ConcernScreen> {
  @override
  Widget build(BuildContext context) {
    final usedSubstances = widget.questionnaire.getUsedSubstances();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Has a friend or relative or anyone else ever expressed concern about your use of [substance]?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstances[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${substance.name} ${substance.description}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOptionButton(
                            context,
                            'No, Never',
                            substance.concernFromOthers == 0,
                                () {
                              setState(() {
                                substance.concernFromOthers = 0;
                              });
                            }
                        ),
                        const SizedBox(height: 8),
                        _buildOptionButton(
                            context,
                            'Yes, in the past 3 months',
                            substance.concernFromOthers == 6,
                                () {
                              setState(() {
                                substance.concernFromOthers = 6;
                              });
                            }
                        ),
                        const SizedBox(height: 8),
                        _buildOptionButton(
                            context,
                            'Yes, but not in the past 3 months',
                            substance.concernFromOthers == 3,
                                () {
                              setState(() {
                                substance.concernFromOthers = 3;
                              });
                            }
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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

  Widget _buildOptionButton(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF6E77F6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF6E77F6).withOpacity(0.1)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Results Screen
class ResultsScreen extends StatelessWidget {
  final AssistQuestionnaire questionnaire;
  final VoidCallback onFinish;

  const ResultsScreen({
    Key? key,
    required this.questionnaire,
    required this.onFinish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highestScore = questionnaire.calculateHighestScore();
    final riskLevel = _getRiskLevel(highestScore);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Results',
                style: TextStyle(
                  fontSize: 40,
                  color: const Color(0xFF6E77F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You\'ve completed the first step towards recovery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: DashedCirclePainter(color: const Color(0xFF6E77F6)),
                  child: Center(
                    child: Text(
                      highestScore.toString(),
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _getRiskText(riskLevel),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getAdviceText1(riskLevel),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getAdviceText2(riskLevel),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to treatment plan selection using Navigator
                    Navigator.pushNamed(
                      context,
                      '/treatment-plans',
                      arguments: {'onComplete': onFinish},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Choose Your Plan',
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

  String _getRiskLevel(int score) {
    if (score >= 0 && score <= 3) return 'low';
    if (score >= 4 && score <= 26) return 'moderate';
    if (score >= 27) return 'high';
    return 'unknown';
  }

  String _getRiskText(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 'Your responses indicate a low risk of addiction.';
      case 'moderate':
        return 'Your responses suggest a moderate risk of addiction.';
      case 'high':
        return 'Your responses indicate a high risk of addiction.';
      default:
        return 'Your risk level could not be determined.';
    }
  }

  String _getAdviceText1(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 'While your current substance use appears to be under control, it\'s important to maintain healthy habits and stay aware of potential risks.';
      case 'moderate':
        return 'This indicates a pattern that may affect your health and well-being over time.';
      case 'high':
        return 'This suggests significant concerns related to substance use.';
      default:
        return 'Consider monitoring your substance use habits.';
    }
  }

  String _getAdviceText2(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 'Consider periodic self-assessments to ensure continued well-being.';
      case 'moderate':
        return 'It could be helpful to reflect on your substance use and consider seeking professional guidance to prevent further risks.';
      case 'high':
        return 'Seeking professional support is highly recommended to address these issues and prevent serious health, social, or legal consequences. Early intervention can be crucial for recovery.';
      default:
        return 'If you have concerns, consulting with a healthcare professional is advised.';
    }
  }
}

// Update your assist_screens.dart with this modified ResultsScreen
// and DashedCirclePainter class

class DashedCirclePainter extends CustomPainter {
  final Color color;

  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Path path = Path();

    // Create a dashed circular path
    for (double i = 0; i < 360; i += 12) {
      final double startAngle = i * (3.14159 / 180);
      final double endAngle = (i + 6) * (3.14159 / 180);

      path.addArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        endAngle - startAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Question 8: Injection Use
class InjectionScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const InjectionScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<InjectionScreen> createState() => _InjectionScreenState();
}

class _InjectionScreenState extends State<InjectionScreen> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have you ever used any drug by injection (non-medical use only)?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOptionButton(
                          context,
                          'No, Never',
                          selectedOption == 0,
                              () {
                            setState(() {
                              selectedOption = 0;
                            });
                          }
                      ),
                      const SizedBox(height: 12),
                      _buildOptionButton(
                          context,
                          'Yes, in the past 3 months',
                          selectedOption == 1,
                              () {
                            setState(() {
                              selectedOption = 1;
                            });
                          }
                      ),
                      const SizedBox(height: 12),
                      _buildOptionButton(
                          context,
                          'Yes, but not in the past 3 months',
                          selectedOption == 2,
                              () {
                            setState(() {
                              selectedOption = 2;
                            });
                          }
                      ),

                      if (selectedOption == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              'If it is in the past 3 months, it is',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildOptionButton(
                                context,
                                'Less than 4 days per month',
                                widget.questionnaire.substances.first.injectionFrequency == 1,
                                    () {
                                  setState(() {
                                    widget.questionnaire.substances.first.injectionFrequency = 1;
                                  });
                                }
                            ),
                            const SizedBox(height: 12),
                            _buildOptionButton(
                                context,
                                'More than 4 days per month',
                                widget.questionnaire.substances.first.injectionFrequency == 2,
                                    () {
                                  setState(() {
                                    widget.questionnaire.substances.first.injectionFrequency = 2;
                                  });
                                }
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedOption != null) {
                      for (var substance in widget.questionnaire.substances) {
                        substance.injected = selectedOption! > 0;
                      }
                      widget.onNext(widget.questionnaire);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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

  Widget _buildOptionButton(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF6E77F6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF6E77F6).withOpacity(0.1)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Question 7: Attempted to Cut Down
class CutDownScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const CutDownScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<CutDownScreen> createState() => _CutDownScreenState();
}

class _CutDownScreenState extends State<CutDownScreen> {
  @override
  Widget build(BuildContext context) {
    final usedSubstances = widget.questionnaire.getUsedSubstances();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have you ever tried to cut down on using [substance] but failed?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstances[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${substance.name} ${substance.description}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOptionButton(
                            context,
                            'No, Never',
                            substance.triedToControl == 0,
                                () {
                              setState(() {
                                substance.triedToControl = 0;
                              });
                            }
                        ),
                        const SizedBox(height: 8),
                        _buildOptionButton(
                            context,
                            'Yes, in the past 3 months',
                            substance.triedToControl == 6,
                                () {
                              setState(() {
                                substance.triedToControl = 6;
                              });
                            }
                        ),
                        const SizedBox(height: 8),
                        _buildOptionButton(
                            context,
                            'Yes, but not in the past 3 months',
                            substance.triedToControl == 3,
                                () {
                              setState(() {
                                substance.triedToControl = 3;
                              });
                            }
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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

  Widget _buildOptionButton(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF6E77F6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF6E77F6).withOpacity(0.1)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Intro information screen
class IntroScreen extends StatelessWidget {
  final VoidCallback onNextPressed;

  const IntroScreen({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Substance use frequency',
          style: TextStyle(
            color: const Color(0xFF6E77F6),
            fontSize: 24,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Never: not used in the last 3 months - 1',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Once or twice: 1 to 2 times in the last 3 months - 2',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Monthly: average of 1 to 3 times per month over the last 3 months - 3',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Weekly: 1 to 4 times per week - 4',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Daily or almost daily: 5 to 7 days per week - 5',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
}

// Question 1: Lifetime substance use
class LifetimeUseScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const LifetimeUseScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<LifetimeUseScreen> createState() => _LifetimeUseScreenState();
}

class _LifetimeUseScreenState extends State<LifetimeUseScreen> {
  final TextEditingController _otherController = TextEditingController();
  bool isOtherSelected = false;

  @override
  void initState() {
    super.initState();
    isOtherSelected = widget.questionnaire.substances.last.usedInLifetime;
    _otherController.text = widget.questionnaire.otherSubstanceSpecify;
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Let\'s Begin',
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
              Text(
                'In your life, which of the following substances have you ever used (non-medical use only)?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: widget.questionnaire.substances.length,
                    itemBuilder: (context, index) {
                      final substance = widget.questionnaire.substances[index];
                      final isOther = index == widget.questionnaire.substances.length - 1;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CheckboxListTile(
                            title: Text(
                              '${substance.name} ${substance.description}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            value: substance.usedInLifetime,
                            activeColor: const Color(0xFF6E77F6),
                            checkColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                substance.usedInLifetime = value ?? false;
                                if (isOther) {
                                  isOtherSelected = value ?? false;
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (isOther && isOtherSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                              child: TextField(
                                controller: _otherController,
                                decoration: InputDecoration(
                                  hintText: 'Specify',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (value) {
                                  widget.questionnaire.otherSubstanceSpecify = value;
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isOtherSelected) {
                      widget.questionnaire.otherSubstanceSpecify = _otherController.text;
                    }
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
}

// Question 2: Frequency in last 3 months
class FrequencyScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const FrequencyScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<FrequencyScreen> createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {
  final Map<int, String> frequencyLabels = {
    0: 'Never',
    2: 'Once or twice',
    3: 'Monthly',
    4: 'Weekly',
    6: 'Daily or almost daily',
  };

  final Map<int, int> frequencyScores = {
    1: 0, // Never
    2: 2, // Once or twice
    3: 3, // Monthly
    4: 4, // Weekly
    5: 6, // Daily or almost daily
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstances = widget.questionnaire.getUsedSubstances();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In the past three months, how often have you used the substances you mentioned?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstances[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${substance.name} ${substance.description}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final buttonNumber = i + 1;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  substance.frequencyLast3Months = frequencyScores[buttonNumber]!;
                                });
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF6E77F6),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: substance.frequencyLast3Months == frequencyScores[buttonNumber]
                                      ? const Color(0xFF6E77F6).withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  buttonNumber.toString(),
                                  style: TextStyle(
                                    color: const Color(0xFF6E77F6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
}

// Question 3: Urge to Use
class UrgeToUseScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const UrgeToUseScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<UrgeToUseScreen> createState() => _UrgeToUseScreenState();
}

class _UrgeToUseScreenState extends State<UrgeToUseScreen> {
  final Map<int, int> urgeScores = {
    1: 0, // Never
    2: 3, // Once or twice
    3: 4, // Monthly
    4: 5, // Weekly
    5: 6, // Daily or almost daily
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstancesLast3Months = widget.questionnaire.getUsedLast3Months();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'During the past three months, how often have you had a strong desire or urge to use [substance]?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstancesLast3Months.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstancesLast3Months[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${substance.name} ${substance.description}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final buttonNumber = i + 1;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  substance.urgeToUse = urgeScores[buttonNumber]!;
                                });
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF6E77F6),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: substance.urgeToUse == urgeScores[buttonNumber]
                                      ? const Color(0xFF6E77F6).withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  buttonNumber.toString(),
                                  style: TextStyle(
                                    color: const Color(0xFF6E77F6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
}

// Question 4: Health, Social, Legal, Financial Problems
class ProblemsScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const ProblemsScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  final Map<int, int> problemScores = {
    1: 0, // Never
    2: 4, // Once or twice
    3: 5, // Monthly
    4: 6, // Weekly
    5: 7, // Daily or almost daily
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstancesLast3Months = widget.questionnaire.getUsedLast3Months();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'During the past three months, how often has your use of [substance] led to health, social, legal or financial problems?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstancesLast3Months.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstancesLast3Months[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${substance.name} ${substance.description}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final buttonNumber = i + 1;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  substance.healthSocialProblems = problemScores[buttonNumber]!;
                                });
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF6E77F6),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: substance.healthSocialProblems == problemScores[buttonNumber]
                                      ? const Color(0xFF6E77F6).withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  buttonNumber.toString(),
                                  style: TextStyle(
                                    color: const Color(0xFF6E77F6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
}

// Question 5: Failed Responsibilities
class FailedResponsibilitiesScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const FailedResponsibilitiesScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<FailedResponsibilitiesScreen> createState() => _FailedResponsibilitiesScreenState();
}

class _FailedResponsibilitiesScreenState extends State<FailedResponsibilitiesScreen> {
  final Map<int, int> failedScores = {
    1: 0, // Never
    2: 5, // Once or twice
    3: 6, // Monthly
    4: 7, // Weekly
    5: 8, // Daily or almost daily
  };

  @override
  Widget build(BuildContext context) {
    // Filter out tobacco and get substances used in last 3 months
    final usedSubstancesLast3Months = widget.questionnaire.getUsedLast3Months()
        .where((substance) => !substance.name.contains('Tobacco'))
        .toList();

    if (usedSubstancesLast3Months.isEmpty) {
      // Skip this question if no qualifying substances
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onNext(widget.questionnaire);
      });
      return Container(); // Return empty container while redirecting
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'During the past three months, how often have you failed to do what was normally expected of you because of your use of [substance]?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstancesLast3Months.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstancesLast3Months[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${substance.name} ${substance.description}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final buttonNumber = i + 1;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  substance.failedResponsibilities =
                                  failedScores[buttonNumber]!;
                                });
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF6E77F6),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: substance.failedResponsibilities ==
                                      failedScores[buttonNumber]
                                      ? const Color(0xFF6E77F6).withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  buttonNumber.toString(),
                                  style: TextStyle(
                                    color: const Color(0xFF6E77F6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E77F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
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
}