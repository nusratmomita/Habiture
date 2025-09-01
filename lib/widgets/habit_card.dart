import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../screens/habit/habit_details.dart';
import '../screens/habit/add_edit_habit.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentWeek = List.generate(
        7, (index) => DateTime(now.year, now.month, now.day - now.weekday + index));

    final primaryPurple = Color(0xFF6A1B9A);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _navigateToDetailScreen(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [primaryPurple.withOpacity(0.1), Colors.purple.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                  ),
                  const SizedBox(height: 6),

                  // Frequency
                  Text(
                    'Every ${habit.frequency}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),

                  // Days of week
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map(
                          (day) => Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple.shade100.withOpacity(0.3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.substring(0, 1),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),

                  // Completion indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: currentWeek.map((date) {
                      final isCompleted = habit.completedDates.any((d) =>
                          d.year == date.year &&
                          d.month == date.month &&
                          d.day == date.day);
                      final isMissed = date.isBefore(DateTime.now()) && !isCompleted;

                      Color bgColor;
                      if (isCompleted) {
                        bgColor = Colors.purple;
                      } else if (isMissed) {
                        bgColor = Colors.redAccent;
                      } else {
                        bgColor = Colors.grey.shade300;
                      }

                      return GestureDetector(
                        onTap: () {
                          Provider.of<HabitProvider>(context, listen: false)
                              .toggleHabitDate(habit, date);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            date.day.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Streak & Completion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.whatshot,
                              color: Colors.deepPurple, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            '${habit.currentStreak} days streak',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.deepPurple, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            '${habit.completionPercentage.toStringAsFixed(0)}% complete',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Edit & Delete buttons
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_square, size: 24, color: primaryPurple),
                      onPressed: () => _navigateToEditScreen(context),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete_forever, size: 24, color: Colors.deepPurple),
                      onPressed: () => _confirmDeleteHabit(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HabitDetailScreen(habit: habit)),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditHabitScreen(
          habitId: habit.id,
          existingTitle: habit.title,
          existingDescription: habit.description,
          existingCompletedDates: habit.completedDates,
        ),
      ),
    );
  }

  void _confirmDeleteHabit(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Habit', style: Theme.of(context).textTheme.titleLarge),
          content: Text('Are you sure you want to delete this habit?',
              style: Theme.of(context).textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
