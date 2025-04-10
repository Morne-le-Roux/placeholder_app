import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder_app/core/usecases/nav.dart';
import 'package:placeholder_app/features/auth/models/p_h_user.dart';
import 'package:uuid/uuid.dart';

import '../../../core/usecases/snack.dart';
import '../../../core/widgets/buttons/large_rounded_button.dart';
import '../../../main.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/task_cubit.dart';
import '../models/task.dart';

class CreateTaskBottomSheet extends StatefulWidget {
  const CreateTaskBottomSheet({super.key, required this.phUser});

  final PHUser phUser;

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  late Task task;
  AuthCubit get authCubit => context.read<AuthCubit>();
  TaskCubit get taskCubit => context.read<TaskCubit>();

  bool isLoading = false;

  @override
  void initState() {
    task = Task(
      id: Uuid().v4(),
      userId: widget.phUser.id,
      authorId: authCubit.state.phUser?.id ?? "",
      accountHolderId: supabaseClient.auth.currentUser?.id ?? "",
      title: "",
      content: "",
      recurring: false,
      createdAt: DateTime.now().toString(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Create Task for ${widget.phUser.name}"),
            Gap(20),
            TextFormField(
              validator: (value) => value!.isEmpty ? "Title is required" : null,
              decoration: InputDecoration(labelText: "Title"),
              initialValue: task.title,
              onChanged: (value) =>
                  setState(() => task = task.copyWith(title: value)),
            ),
            Gap(20),
            TextFormField(
              decoration: InputDecoration(labelText: "Description"),
              initialValue: task.content,
              maxLines: 5,
              onChanged: (value) =>
                  setState(() => task = task.copyWith(content: value)),
            ),
            Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recurring"),
                Switch(
                    value: task.recurring,
                    onChanged: (value) =>
                        setState(() => task = task.copyWith(recurring: value))),
              ],
            ),
            Gap(20),
            LargeRoundedButton(
              text: "Create Task",
              isLoading: isLoading,
              isValid: task.title.isNotEmpty,
              onPressed: () async {
                try {
                  setState(() => isLoading = true);
                  await taskCubit.createTask(task);
                  setState(() => isLoading = false);
                  Nav.pop(context);
                } catch (e) {
                  setState(() => isLoading = false);
                  snack(context, e.toString());
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
