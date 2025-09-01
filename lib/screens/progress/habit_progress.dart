import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Data for the weekly chart (7 days, Mon-Sun)
  List<int> weeklyData = List.filled(7, 0);

  // Current streak count
  int streak = 0;

  // List of upcoming goals (habits with title, description, frequency)
  List<Map<String, dynamic>> upcomingGoals = [];

  @override
  void initState() {
    super.initState();
    // Load habits when screen initializes
    _loadHabits();
  }

  /// Load all habits from Firestore and prepare data for chart, streak, and upcoming goals
  Future<void> _loadHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Exit if user not logged in

    // Fetch habits from Firestore for this user
    final habitsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("habits")
        .get();

    if (habitsSnapshot.docs.isEmpty) return;

    final now = DateTime.now();

    // Generate last 7 days (from 6 days ago to today) for chart display
    final last7Days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );

    // Temporary list to hold upcoming goals
    List<Map<String, dynamic>> goals = [];

    // Iterate through each habit document
    for (var doc in habitsSnapshot.docs) {
      final habit = doc.data();

      // Handle completedDates safely (may not exist)
      final List<dynamic> completedDates = habit["completedDates"] ?? [];

      // Convert all dates to DateTime objects
      final completed = completedDates
          .map<DateTime>((d) {
            if (d is Timestamp) return d.toDate();
            return DateTime.tryParse(d.toString()) ?? DateTime.now();
          })
          .toList();

      // Prepare weekly data: 1 if completed on that day, 0 otherwise
      final week = last7Days
          .map((day) => completed.any((c) => _isSameDay(c, day)) ? 1 : 0)
          .toList();

      // Merge this habit's week data into global weeklyData
      for (int i = 0; i < week.length; i++) {
        if (week[i] == 1) weeklyData[i] = 1;
      }

      // Calculate streak based on this habit's completed dates
      streak = _calculateStreak(completed);

      // Add habit info to upcoming goals list
      goals.add({
        "title": habit["title"] ?? "",
        "frequency": habit["frequency"] ?? "",
        "description": habit["description"] ?? "",
      });
    }

    // Update state to trigger UI rebuild
    setState(() {
      upcomingGoals = goals;
    });
  }

  /// Check if two DateTime objects fall on the same calendar day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calculate current streak: consecutive days with completed habits
  int _calculateStreak(List<DateTime> completed) {
    int count = 0;
    DateTime today = DateTime.now();

    // Check up to last 30 days
    for (int i = 0; i < 30; i++) {
      final day = DateTime(today.year, today.month, today.day - i);
      if (completed.any((c) => _isSameDay(c, day))) {
        count++;
      } else {
        break; // Streak ends at first day missed
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Progresses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Progress Chart Title
            const Text(
              "Weekly Progress",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Bar chart showing last 7 days of completion
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.2,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ["M", "T", "W", "T", "F", "S", "S"];
                          if (value.toInt() < 0 || value.toInt() >= days.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  // Create a bar for each day
                  barGroups: List.generate(weeklyData.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyData[index].toDouble(),
                          color: weeklyData[index] == 1
                              ? const Color.fromARGB(255, 175, 76, 175) // completed
                              : Colors.redAccent, // not completed
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Current Streak Section
            const Text(
              "Your Current Streak",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 40),
                title: Text(
                  "$streak Days",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("you got this"),
              ),
            ),

            const SizedBox(height: 30),

            // Upcoming Goals Section Title
            const Text(
              "Upcoming Goals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List of upcoming goals
            Expanded(
              child: ListView(
                children: upcomingGoals.map((goal) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle_outline,
                        color: Color.fromARGB(255, 150, 0, 127)),
                    title: Text(goal["title"] ?? ""),
                    subtitle: Text(
                      "Goal: ${goal["frequency"] ?? ""}\n${goal["description"] ?? ""}",
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
