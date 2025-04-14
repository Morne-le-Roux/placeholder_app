import 'package:placeholder_app/features/tasks/models/task.dart';

bool isTaskDoneToday(Task task) {
  bool isTaskDoneToday = false;
  DateTime now = DateTime.now();
  DateTime? taskDate = DateTime.tryParse(task.createdAt);
  if (taskDate == null) return false;
  if (taskDate.year == now.year &&
      taskDate.month == now.month &&
      taskDate.day == now.day) {
    isTaskDoneToday = true;
  }
  return isTaskDoneToday;
}
