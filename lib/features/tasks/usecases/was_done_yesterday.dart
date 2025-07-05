import 'package:placeholder/features/tasks/models/task.dart';

bool wasTaskDoneYesterday(Task task) {
  if (!task.recurring) return true;

  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final creationDate = DateTime.parse(task.createdAt);

  // If task was created today or yesterday, it shouldn't be marked as not done
  if (creationDate.isAfter(yesterday)) return true;

  final bool wasDoneYesterday =
      task.recurring &&
      task.lastDone != null &&
      DateTime.parse(task.lastDone!).day == yesterday.day &&
      DateTime.parse(task.lastDone!).month == yesterday.month &&
      DateTime.parse(task.lastDone!).year == yesterday.year;

  return wasDoneYesterday;
}
