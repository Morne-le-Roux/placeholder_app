import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';
import '../models/task.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskState());

  Future<void> createTask(Task task) async {
    try {
      await sb.from("tasks").insert(task.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await sb.from("tasks").update(task.toMap()).eq("id", task.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await sb
          .from("tasks")
          .update(task.copyWith(deleted: true).toMap())
          .eq("id", task.id);

      await sb
          .from("tasks")
          .update({"deleted": true})
          .eq("parent_task", task.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final response = await sb
          .from("tasks")
          .select("*")
          .eq("user", userId)
          .eq("deleted", false);
      List<Task> allTasks = response.map((e) => Task.fromMap(e)).toList();

      // Build a map of id -> Task for quick lookup
      final Map<String, Task> taskMap = {for (var t in allTasks) t.id: t};
      // List to hold root tasks (no parent)
      final List<Task> rootTasks = [];

      for (final task in allTasks) {
        if (task.parentTask != null) {
          final parent = taskMap[task.parentTask];
          if (parent != null) {
            parent.subTasks.add(task);
          }
        } else {
          rootTasks.add(task);
        }
      }

      return rootTasks;
    } catch (e) {
      rethrow;
    }
  }
}
