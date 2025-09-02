import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';

class HabitCalendarTab extends StatefulWidget {
  final HabitModel habit;

  const HabitCalendarTab({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitCalendarTab> createState() => _HabitCalendarTabState();
}

class _HabitCalendarTabState extends State<HabitCalendarTab> {
  late DateTime displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    displayedMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1);
    });
  }

  bool _isInStreak(DateTime date) {
    if (widget.habit.completedDates.isEmpty) return false;

    final sortedDates = List<DateTime>.from(widget.habit.completedDates)
      ..sort((a, b) => b.compareTo(a));

    DateTime current = DateTime.now();
    int streakCount = 0;

    for (var completedDate in sortedDates) {
      if (current.isAtSameMomentAs(completedDate) ||
          current.subtract(const Duration(days: 1)).isAtSameMomentAs(completedDate)) {
        streakCount++;
        current = completedDate;
      } else {
        break;
      }
    }

    return widget.habit.completedDates.any(
          (d) => d.year == date.year && d.month == date.month && d.day == date.day,
        ) &&
        date.isAfter(current.subtract(Duration(days: streakCount)));
  }

  int _calculateLongestStreak() {
    if (widget.habit.completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(widget.habit.completedDates)
      ..sort((a, b) => b.compareTo(a));

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i - 1].difference(sortedDates[i]).inDays == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (sortedDates[i - 1].difference(sortedDates[i]).inDays > 1) {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(displayedMonth.year, displayedMonth.month);
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final startingWeekday = firstDay.weekday;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Month & Year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                DateFormat.yMMMM().format(displayedMonth),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text("Mon", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Tue", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Wed", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Thu", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Fri", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Sat", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Sun", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: daysInMonth + startingWeekday - 1,
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) return const SizedBox.shrink();

                final day = index - startingWeekday + 2;
                final date = DateTime(displayedMonth.year, displayedMonth.month, day);
                final isCompleted = widget.habit.completedDates.any(
                  (d) => d.year == date.year && d.month == date.month && d.day == date.day,
                );
                final isInStreak = _isInStreak(date);
                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

                return GestureDetector(
                  onTap: () {
                    Provider.of<HabitProvider>(context, listen: false).toggleHabitDate(widget.habit, date);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: isInStreak
                          ? LinearGradient(
                              colors: [Colors.purple, Colors.deepPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : isCompleted
                              ? LinearGradient(
                                  colors: [Colors.purple.withOpacity(0.4), Colors.purple.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                      color: (!isCompleted && !isInStreak)
                          ? Colors.transparent
                          : null,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : (isCompleted || isInStreak)
                                ? Colors.purple
                                : themeProvider.isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                        width: isToday ? 2.5 : 1.5,
                      ),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: (isCompleted || isInStreak) ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Streak Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Longest streak: ${_calculateLongestStreak()} days',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
