// ChangeNotifier is used notify the UI whenever the data changed
import 'package:flutter/material.dart';// gives access to Flutter UI and state management tools
import '../models/habit.dart';// defines the HabitModel (means a habit)
// import '../services/firestore_service.dart';

class HabitProvider extends ChangeNotifier { // ChangeNotifier → allows notifying listeners (widgets) when data changes
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();// _firestoreService → handles Firestore database operations

  HabitProvider({required this.userId}) {
    fetchHabits();
  }

  List<HabitModel> _habits = [];
  List<HabitModel> get habits => _habits;// A getter (habits) exposes it to the UI.

  // Fetching Habits from Firestore
  // * Uses Firestore’s real-time stream (.listen) to keep _habits updated.
  void fetchHabits() {
    _firestoreService.getHabits(userId).listen((habitList) {
      _habits = habitList;
      notifyListeners();// Calls notifyListeners() → triggers UI updates
    });
  }

  // Adding or Updating a Habit
  // Saves a new habit or updates an existing one in Firestore.
  // Since Firestore has real-time updates, the _habits list will auto-update via fetchHabits().
  // a helper function
  Future<void> addOrUpdateHabit(HabitModel habit) async {
    await _firestoreService.saveHabit(userId, habit);
  }

  // Delete habit -> Removes a habit by its ID.
  Future<void> deleteHabit(String habitId) async {
    await _firestoreService.deleteHabit(userId, habitId);
  }

  // Toggle completion for specific date
  Future<void> toggleHabitDate(HabitModel habit, DateTime date) async {
    // If the habit is already marked as completed on DATE, it removes it.
    if (habit.completedDates.any((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day)) {
      habit.completedDates.removeWhere((d) =>
      d.year == date.year && d.month == date.month && d.day == date.day);
    } 
    else {
      // Add date if not completed
      habit.completedDates.add(date);
    }
    await _firestoreService.saveHabit(userId, habit);// Updates Firestore afterwards.
  }

 // Quickly toggles today’s completion status
  Future<void> toggleHabitCompletion(HabitModel habit) async {
    await toggleHabitDate(habit, DateTime.now());
  }

  // Filtering Habits by Week
  // Returns habits that were completed within a given week (from weekStart).
  List<HabitModel> getHabitsForWeek(DateTime weekStart) {
    return _habits.where((habit) {
      return habit.completedDates.any((date) =>
      date.isAfter(weekStart) && date.isBefore(weekStart.add(const Duration(days: 7))));
    }).toList();
  }

  // Calculating Overall Completion Rate
  // Computes the average completion percentage across all habits.
  // Each HabitModel must have a completionPercentage property.
  
  double get overallCompletionRate {
    if (_habits.isEmpty) return 0.0;

    double total = 0.0;
    for (var habit in _habits) {
      total += habit.completionPercentage;
    }
    return total / _habits.length;
  }
}