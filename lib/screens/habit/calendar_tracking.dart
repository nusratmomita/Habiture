// a calendar view for a single habit, showing which days it was completed and streaks.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // for month formatting
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
  late DateTime displayedMonth;// which month is currently shown

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    displayedMonth = DateTime(now.year, now.month);// Initially shows the current month
  }

  // Moves the calendar to the previous or next month by adjusting displayedMonth
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

  // Check Streak
  // Determines if a date is part of the habit’s current streak.
  // Compares each completed date to today, counting consecutive completions
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

    return widget.habit.completedDates.any((d) =>
    d.year == date.year &&
        d.month == date.month &&
        d.day == date.day) &&
        date.isAfter(current.subtract(Duration(days: streakCount)));
  }

  // Calculate Longest Streak
  //   Sorts completedDates in descending order.

  // Iterates through dates to find maximum consecutive days
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
    final daysInMonth =
    DateUtils.getDaysInMonth(displayedMonth.year, displayedMonth.month);
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final startingWeekday = firstDay.weekday;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Month & Year header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                DateFormat.yMMMM().format(displayedMonth), // e.g. "August 2025"
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text("Mon"), Text("Tue"), Text("Wed"),
              Text("Thu"), Text("Fri"), Text("Sat"), Text("Sun"),
            ],
          ),

          const SizedBox(height: 8),

          // Calendar Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: daysInMonth + startingWeekday - 1,
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox.shrink();
                }

                final day = index - startingWeekday + 2;
                final date =
                DateTime(displayedMonth.year, displayedMonth.month, day);
                final isCompleted = widget.habit.completedDates.any((d) =>
                d.year == date.year &&
                    d.month == date.month &&
                    d.day == date.day);
                final isInStreak = _isInStreak(date);
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;

                return GestureDetector(
                  onTap: () {
                    Provider.of<HabitProvider>(context, listen: false)
                        .toggleHabitDate(widget.habit, date);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isInStreak
                          ? Colors.green.withOpacity(0.8)
                          : isCompleted
                          ? Colors.green.withOpacity(0.4)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : (isCompleted || isInStreak)
                            ? Colors.green
                            : themeProvider.isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: (isCompleted || isInStreak)
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Streak Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.habit.currentStreak} day streak',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Longest streak: ${_calculateLongestStreak()} days',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}
