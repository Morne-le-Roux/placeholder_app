import 'package:intl/intl.dart';

/// Returns a localized, human-friendly date string for the given [dateString].
/// - If the date is today, returns 'Today'.
/// - If the date was yesterday, returns 'Yesterday'.
/// - If the date is tomorrow, returns 'Tomorrow'.
/// - If the date is in the current week, returns the weekday name (e.g., 'Monday').
/// - Otherwise, returns the date in the user's locale format (no time).
String formatFriendlyDate(String dateString, {String? locale}) {
  final now = DateTime.now();
  final date = DateTime.parse(dateString);
  final localDate = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  // Use device's locale if none provided
  final effectiveLocale = locale ?? Intl.getCurrentLocale();

  if (localDate == today) {
    return 'Today';
  } else if (localDate == yesterday) {
    return 'Yesterday';
  } else if (localDate == tomorrow) {
    return 'Tomorrow';
  }

  // Check if date is in the current week (Monday-Sunday)
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  if (localDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      localDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
    return DateFormat.EEEE(effectiveLocale).format(localDate); // e.g., 'Monday'
  }

  // Default: localized date string (no time)
  return DateFormat.yMMMd(effectiveLocale).format(localDate);
}
