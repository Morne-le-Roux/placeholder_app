import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:placeholder_app/core/themes/text_form_field_theme.dart';
import 'package:placeholder_app/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder_app/features/auth/views/choose_user.dart';
import 'package:placeholder_app/features/auth/views/login.dart';
import 'package:placeholder_app/core/usecases/init_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/tasks/cubit/task_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await initSupabase();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AuthCubit()),
      BlocProvider(create: (context) => TaskCubit()),
    ],
    child: const MainApp(),
  ));
}

final SupabaseClient supabaseClient = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(inputDecorationTheme: inputDecorationTheme),
      home: supabaseClient.auth.currentSession != null ? ChooseUser() : Login(),
    );
  }
}
