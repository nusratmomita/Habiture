import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/habit.dart';

class HabitStatisticsTab extends StatelessWidget {
  final HabitModel habit;

  const HabitStatisticsTab({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weeklyData = _generateWeeklyData();
    final monthlyData = _generateMonthlyData();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Weekly Progress ----------
          _buildSectionTitle('Weekly Progress', theme),
          _buildBarChart(weeklyData, theme),
          const SizedBox(height: 30),

          // ---------- Monthly Progress ----------
          _buildSectionTitle('Monthly Progress', theme),
          _buildLineChart(monthlyData, theme),
          const SizedBox(height: 30),

          // ---------- Stats Cards Row ----------
          _buildSectionTitle('Your Stats', theme),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${habit.currentStreak} days',
                  Icons.local_fire_department,
                  const Color(0xFFFF009D),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Longest Streak',
                  '${habit.longestStreak} days',
                  Icons.timeline,
                  Colors.purple,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Weekly Completion',
                  '${habit.completionPercentage.toStringAsFixed(0)}%',
                  Icons.check_circle,
                  const Color(0xFFF32179),
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Section Title ----------
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  // ---------- Stat Card ----------
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    ThemeData theme, {
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: iconColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + title
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.2),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Value
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Weekly Bar Chart ----------
  Widget _buildBarChart(List<double> data, ThemeData theme) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, _, rod, __) {
                final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                return BarTooltipItem(
                  '${days[group.x.toInt()]}\n${rod.toY == 1 ? 'Completed ✅' : 'Missed ❌'}',
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                );
              },
              // tooltipBgColor: theme.colorScheme.primary,
            ),
          ),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            final isToday = index == DateTime.now().weekday % 7;
            return BarChartGroupData(
              x: index,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: value > 0 ? theme.colorScheme.primary : Colors.redAccent,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                  borderSide: isToday
                      ? BorderSide(color: theme.colorScheme.secondary, width: 2)
                      : BorderSide.none,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1,
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: value.toInt() == DateTime.now().weekday % 7
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: value.toInt() == DateTime.now().weekday % 7
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                },
                reservedSize: 20,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ---------- Monthly Line Chart ----------
  Widget _buildLineChart(List<double> data, ThemeData theme) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: data.reduce((a, b) => a > b ? a : b) + 2,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.15),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  'Week ${value.toInt() + 1}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall,
                ),
                reservedSize: 28,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
          ),
        ),
      ),
    );
  }

  // ---------- Generate Weekly Data ----------
  List<double> _generateWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return habit.completedDates.any(
        (d) => d.year == date.year && d.month == date.month && d.day == date.day,
      )
          ? 1.0
          : 0.0;
    });
  }

  // ---------- Generate Monthly Data ----------
  List<double> _generateMonthlyData() {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final weekStart = now.subtract(Duration(days: (3 - index) * 7));
      int streak = 0;
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        if (habit.completedDates.any(
          (d) => d.year == date.year && d.month == date.month && d.day == date.day,
        )) {
          streak++;
        } else {
          break;
        }
      }
      return streak.toDouble();
    });
  }
}
