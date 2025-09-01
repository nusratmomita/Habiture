import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/habit.dart';

class HabitStatisticsTab extends StatelessWidget {
  final HabitModel habit;

  const HabitStatisticsTab({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate weekly (7 days) and monthly (4 weeks) data from the habit model
    final weeklyData = _generateWeeklyData();
    final monthlyData = _generateMonthlyData();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ---------------- WEEKLY PROGRESS ----------------
          _buildSectionTitle('Weekly Progress', theme),
          _buildBarChart(weeklyData, theme),
          const SizedBox(height: 24),

          // ---------------- MONTHLY PROGRESS ----------------
          _buildSectionTitle('Monthly Progress', theme),
          _buildLineChart(monthlyData, theme),
          const SizedBox(height: 24),

          // ---------------- STATS CARDS ----------------
          Row(
            children: [
              // Current streak card
              _buildStatCard(
                'Current Streak',
                '${habit.currentStreak} days',
                Icons.local_fire_department,
                const Color.fromARGB(255, 255, 0, 157),
                theme,
              ),
              const SizedBox(width: 16),

              // Longest streak card
              _buildStatCard(
                'Longest Streak',
                '${habit.longestStreak} days',
                Icons.timeline,
                Colors.purple,
                theme,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly completion percentage card
          _buildStatCard(
            'Weekly Completion',
            '${habit.completionPercentage.toStringAsFixed(0)}%',
            Icons.check_circle,
            const Color.fromARGB(255, 243, 33, 121),
            theme,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  // ---------- Section Title ----------
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------- Stats Card ----------
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    ThemeData theme, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null, // expands if fullWidth = true
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header (icon + label)
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Value (streak count or percentage)
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
          minY: 0,
          maxY: 1.2, // only two values: 0 (not done) or 1 (done)
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: 8,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipColor: (group) => theme.colorScheme.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Map index to day of week
                final dayName = [
                  'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
                ][group.x.toInt()];

                return BarTooltipItem(
                  '${dayName}\n${rod.toY == 1 ? 'Completed' : 'Not completed'}',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  children: [
                    TextSpan(
                      text: rod.toY == 1 ? '✅' : '❌',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
          // Bars for each day
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
                  color: value > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error.withOpacity(0.3),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                  // highlight today with a border
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
          // Axis labels
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dayNames[value.toInt()],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: value.toInt() == DateTime.now().weekday % 7
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: value.toInt() == DateTime.now().weekday % 7
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
                reservedSize: 20,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return Text('0', style: theme.textTheme.bodySmall);
                  if (value == 1) return Text('1', style: theme.textTheme.bodySmall);
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // Grid & borders
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
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
          maxY: data.reduce((a, b) => a > b ? a : b) + 2, // auto scale
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: 8,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipColor: (touchedSpot) => theme.colorScheme.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()} days streak',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          // Line graph
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .map(
                    (index, value) =>
                        MapEntry(index, FlSpot(index.toDouble(), value)),
                  )
                  .values
                  .toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              // Dots for each data point
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: theme.colorScheme.onPrimary,
                  );
                },
              ),
            ),
          ],
          // Axis labels
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Week ${value.toInt() + 1}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall,
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------- Generate Weekly Data (Sun - Sat) ----------
  List<double> _generateWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday)); // start of week (Sunday)
    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return habit.completedDates.any(
        (d) =>
            d.year == date.year &&
            d.month == date.month &&
            d.day == date.day,
      ) ? 1.0 : 0.0;
    });
  }

  // ---------- Generate Monthly Data (last 4 weeks) ----------
  List<double> _generateMonthlyData() {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final weekStart = now.subtract(Duration(days: (3 - index) * 7));
      int streak = 0;

      // count streak inside the week
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        if (habit.completedDates.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
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
