import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/habit_card.dart';
import 'add_edit_habit.dart';
import 'habit_details.dart';

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({Key? key}) : super(key: key);

  // Navigate to the Add/Edit Habit screen
  void _navigateToAddHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditHabitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.uid;

    // If no user is logged in, show a message
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see your habits")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        actions: [
          // Add habit button in the AppBar
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddHabit(context),
          ),
        ],
      ),
      // StreamBuilder listens to Firestore for real-time habit updates
      body: StreamBuilder<List<HabitModel>>(
        stream: FirestoreService().getHabits(userId),
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If no habits are found, show an empty state UI
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    "No habits yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Start building your habits today!",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToAddHabit(context),
                    child: const Text("Add Your First Habit"),
                  ),
                ],
              ),
            );
          }

          // If habits exist, display them in a list
          final habits = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              // Each habit is displayed using a custom HabitCard widget
              return HabitCard(habit: habit);
            },
          );
        },
      ),
    );
  }
}
