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
  // Data for weekly progress chart (7 days)
  List<int> weeklyData = List.filled(7, 0);

  // Current streak count
  int streak = 0;

  // List of upcoming goals
  List<Map<String, dynamic>> upcomingGoals = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  /// Load all habits from Firestore to populate chart, streak, and upcoming goals
  Future<void> _loadHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("habits")
        .get();

    if (habitsSnapshot.docs.isEmpty) return;

    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );

    List<Map<String, dynamic>> goals = [];

    for (var doc in habitsSnapshot.docs) {
      final habit = doc.data();
      final List<dynamic> completedDates = habit["completedDates"] ?? [];

      // Convert completed dates to DateTime
      final completed = completedDates
          .map<DateTime>((d) {
            if (d is Timestamp) return d.toDate();
            return DateTime.tryParse(d.toString()) ?? DateTime.now();
          })
          .toList();

      // Prepare weekly chart data
      final week = last7Days
          .map((day) => completed.any((c) => _isSameDay(c, day)) ? 1 : 0)
          .toList();

      // Merge individual habit data into global weeklyData
      for (int i = 0; i < week.length; i++) {
        if (week[i] == 1) weeklyData[i] = 1;
      }

      // Calculate streak
      streak = _calculateStreak(completed);

      // Add upcoming goals
      goals.add({
        "title": habit["title"] ?? "",
        "frequency": habit["frequency"] ?? "",
        "description": habit["description"] ?? "",
      });
    }

    setState(() {
      upcomingGoals = goals;
    });
  }

  /// Helper: check if two DateTime objects are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Helper: calculate consecutive streak based on completed dates
  int _calculateStreak(List<DateTime> completed) {
    int count = 0;
    DateTime today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = DateTime(today.year, today.month, today.day - i);
      if (completed.any((c) => _isSameDay(c, day))) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Progress"),
        backgroundColor: const Color.fromARGB(255, 202, 182, 237),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Progress Section
            // const Text(
            //     "Weekly Progress",
            //     style: TextStyle(
            //       fontSize: 22,
            //       fontWeight: FontWeight.bold,
            //       color: Color.fromARGB(255, 255, 255, 255), // <-- correct
            //     ),
            //   ),
            const SizedBox(height: 16),

            // Card container for chart
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.purple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                height: 220,
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
                    barGroups: List.generate(weeklyData.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[index].toDouble(),
                            color: weeklyData[index] == 1
                                ? Colors.deepPurple
                                : Colors.redAccent,
                            width: 20,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Streak Section
            const Text(
              "Current Streak",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.orange.shade50,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 40),
                title: Text(
                  "$streak Days",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Keep it up!"),
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming Goals Section
            const Text(
              "Upcoming Goals",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // List of upcoming goals
            ...upcomingGoals.map((goal) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Color.fromARGB(255, 150, 0, 127)),
                  title: Text(goal["title"] ?? ""),
                  subtitle: Text(
                      "Goal: ${goal["frequency"] ?? ""}\n${goal["description"] ?? ""}"),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
