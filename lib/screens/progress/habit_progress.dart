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
  List<int> weeklyData = List.filled(7, 0); // Mon-Sun
  int streak = 0;
  List<Map<String, dynamic>> upcomingGoals = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

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

    // last 7 days for chart
    final last7Days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );

    // Collect habits into list
    List<Map<String, dynamic>> goals = [];

    for (var doc in habitsSnapshot.docs) {
      final habit = doc.data();

      // Handle completedDates (if missing, just empty)
      final List<dynamic> completedDates = habit["completedDates"] ?? [];
      final completed = completedDates
          .map<DateTime>((d) {
            if (d is Timestamp) return d.toDate();
            return DateTime.tryParse(d.toString()) ?? DateTime.now();
          })
          .toList();

      // Weekly data → mark if habit was completed in last 7 days
      final week = last7Days
          .map((day) => completed.any((c) => _isSameDay(c, day)) ? 1 : 0)
          .toList();

      // Merge with global weeklyData (if multiple habits exist)
      for (int i = 0; i < week.length; i++) {
        if (week[i] == 1) weeklyData[i] = 1;
      }

      // Streak (for now just based on one habit; you can extend this later)
      streak = _calculateStreak(completed);

      // Add to upcoming goals list
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
        title: const Text("Your Progresses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Progress",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Chart
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: List.generate(weeklyData.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyData[index].toDouble(),
                          color: weeklyData[index] == 1
                              ? const Color.fromARGB(255, 175, 76, 175)
                              : Colors.redAccent,
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

            const Text(
              "Your Current Streak",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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

            const Text(
              "Upcoming Goals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
