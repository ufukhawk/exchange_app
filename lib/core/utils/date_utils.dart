class AppDateUtils {
  static List<DateTime> getWeekDays(DateTime date) {
    final DateTime startOfWeek =
        date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }
}
