// ! NOT CLEAR
class DateUtilsHelper {
  /// Check if two DateTime objects represent the same calendar day
  /// Compares year, month, and day
  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Calculate current streak from a list of completed dates
  /// A streak is the number of consecutive days up to today that a habit was completed
  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0; // No completed dates means streak is 0

    // Sort the dates in descending order (most recent first)
    List<DateTime> sortedDates = List.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDay = DateTime.now(); // Start counting from today

    for (DateTime date in sortedDates) {
      if (isSameDay(date, currentDay)) {
        // If the habit was completed today, increment streak
        streak++;
        // Move to the previous day to continue streak calculation
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else if (date.isBefore(currentDay)) {
        // If the next date is before the expected day in the streak, break the loop
        break;
      }
    }
    return streak;
  }

  /// Format a DateTime object as a string in the format "dd MMM yyyy"
  /// Example: 05 Sep 2025
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)} ${date.year}";
  }

  /// Helper method to convert month number to abbreviated month name
  static String _monthName(int month) {
    const names = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return names[month - 1];
  }
}
