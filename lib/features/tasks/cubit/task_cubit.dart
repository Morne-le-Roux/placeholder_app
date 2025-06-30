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
      return response.map((e) => Task.fromMap(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
