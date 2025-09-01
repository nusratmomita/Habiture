// showing details of a single habit 
import 'package:flutter/material.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import 'calendar_tracking.dart';
import 'habit_statistic.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitModel habit;// HabitDetailScreenState handles the TabController for switching tabs.

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);// length: 2 → two tabs: calendar and statistics
    // vsync: this → provides a ticker for animations (required for TabController).
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today)),
            Tab(icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HabitCalendarTab(habit: widget.habit),
          HabitStatisticsTab(habit: widget.habit),
        ],
      ),
    );
  }
}