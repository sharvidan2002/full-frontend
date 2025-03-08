// mood_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // Mood data
  final List<MoodEntry> _moodHistory = [];
  MoodType _selectedMood = MoodType.neutral;
  String _moodNote = '';
  final TextEditingController _noteController = TextEditingController();

  // Journal entries
  final List<JournalEntry> _journalEntries = [];
  final TextEditingController _journalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add some sample mood data
    _moodHistory.addAll([
      MoodEntry(
        date: DateTime.now().subtract(const Duration(days: 6)),
        mood: MoodType.veryHappy,
        note: "Completed my exercise routine and felt great!",
      ),
      MoodEntry(
        date: DateTime.now().subtract(const Duration(days: 5)),
        mood: MoodType.happy,
        note: "Good day overall, managed cravings well",
      ),
      MoodEntry(
        date: DateTime.now().subtract(const Duration(days: 4)),
        mood: MoodType.neutral,
        note: "Average day",
      ),
      MoodEntry(
        date: DateTime.now().subtract(const Duration(days: 3)),
        mood: MoodType.sad,
        note: "Struggled with some triggers today",
      ),
      MoodEntry(
        date: DateTime.now().subtract(const Duration(days: 2)),
        mood: MoodType.happy,
        note: "Support group meeting went well",
      ),
      MoodEntry(
        date: DateTime.now().subtract(const Duration(days: 1)),
        mood: MoodType.happy,
        note: "Feeling positive today",
      ),
    ]);

    // Add sample journal entries
    _journalEntries.addAll([
      JournalEntry(
        date: DateTime.now().subtract(const Duration(days: 3)),
        text: "Today was challenging. I encountered a trigger while out with friends, but I used my coping strategies and got through it.",
      ),
      JournalEntry(
        date: DateTime.now().subtract(const Duration(days: 1)),
        text: "I'm starting to notice a pattern with my cravings - they tend to happen most in the evening. I'll work on having better evening routines.",
      ),
    ]);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Mood Tracker',
            style: TextStyle(
              color: Color(0xFF6E77F6),
              fontSize: 24,
            ),
          ),
          // leading: IconButton(
          //   icon: const Icon(
          //     Icons.arrow_back_ios,
          //     color: Color(0xFF6E77F6),
          //   ),
          //   onPressed: () => Navigator.pop(context),
          // ),
        ),
        body: SafeArea(
        child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Today's Mood Section
    Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "How are you feeling today?",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    _buildMoodSelector(),
    const SizedBox(height: 16),
    TextField(
    controller: _noteController,
    decoration: InputDecoration(
    hintText: "Add a note (optional)",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    maxLines: 2,
    onChanged: (value) {
    _moodNote = value;
    },
    ),
    const SizedBox(height: 16),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: _saveMood,
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6E77F6),
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    child: const Text("Save Mood"),
    ),
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 24),

    // Mood History Section
    const Text(
    "Mood History",
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    _buildMoodHistory(),

    const SizedBox(height: 32),

    // Journal Section
    Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Recovery Journal",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    TextField(
    controller: _journalController,
    decoration: InputDecoration(
    hintText: "Write about your journey today...",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    maxLines: 4,
    ),
    const SizedBox(height: 16),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: _saveJournalEntry,
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6E77F6),
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    child: const Text("Save Entry"),),
    ),
    ],
    ),
    ),
    ),

      const SizedBox(height: 16),

      // Journal Entries
      if (_journalEntries.isNotEmpty) ...[
        const Text(
          "Previous Entries",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._journalEntries.map((entry) => _buildJournalEntry(entry)).toList(),
      ],

      const SizedBox(height: 32),
    ],
    ),
        ),
        ),
        ),
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMoodOption(MoodType.verySad),
        _buildMoodOption(MoodType.sad),
        _buildMoodOption(MoodType.neutral),
        _buildMoodOption(MoodType.happy),
        _buildMoodOption(MoodType.veryHappy),
      ],
    );
  }

  Widget _buildMoodOption(MoodType mood) {
    final bool isSelected = _selectedMood == mood;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: const Color(0xFF6E77F6), width: 2) : null,
        ),
        child: Text(
          _getMoodEmoji(mood),
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.verySad: return '😢';
      case MoodType.sad: return '😔';
      case MoodType.neutral: return '😐';
      case MoodType.happy: return '😊';
      case MoodType.veryHappy: return '😁';
    }
  }

  void _saveMood() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        _moodHistory.add(MoodEntry(
          date: DateTime.now(),
          mood: _selectedMood,
          note: _noteController.text,
        ));

        // Reset the inputs
        _noteController.clear();
        _selectedMood = MoodType.neutral;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note about your mood')),
      );
    }
  }

  void _saveJournalEntry() {
    if (_journalController.text.isNotEmpty) {
      setState(() {
        _journalEntries.add(JournalEntry(
          date: DateTime.now(),
          text: _journalController.text,
        ));

        // Reset the input
        _journalController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something in your journal entry')),
      );
    }
  }

  Widget _buildMoodHistory() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _moodHistory.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final entry = _moodHistory[_moodHistory.length - 1 - index]; // Reverse the order
          return _buildMoodHistoryItem(entry);
        },
      ),
    );
  }

  Widget _buildMoodHistoryItem(MoodEntry entry) {
    return GestureDetector(
      onTap: () {
        _showMoodDetails(entry);
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMoodEmoji(entry.mood),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d').format(entry.date),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodDetails(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(DateFormat('MMM d, yyyy').format(entry.date)),
          ],
        ),
        content: Text(entry.note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalEntry(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d, yyyy').format(entry.date),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

enum MoodType {
  verySad,
  sad,
  neutral,
  happy,
  veryHappy,
}

class MoodEntry {
  final DateTime date;
  final MoodType mood;
  final String note;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.note,
  });
}

class JournalEntry {
  final DateTime date;
  final String text;

  JournalEntry({
    required this.date,
    required this.text,
  });
}