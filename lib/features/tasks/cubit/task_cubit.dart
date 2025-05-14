import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';
import '../models/task.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskState());

  Future<void> createTask(Task task) async {
    try {
      await pb.collection("tasks").create(body: task.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await pb.collection("tasks").update(task.id, body: task.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await pb
          .collection("tasks")
          .update(task.id, body: task.copyWith(deleted: true).toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final response = await pb
          .collection("tasks")
          .getFullList(filter: "user_id = '$userId' && deleted != true");
      return response.map((e) => Task.fromMap(e.toJson())).toList();
    } catch (e) {
      rethrow;
    }
  }
}
