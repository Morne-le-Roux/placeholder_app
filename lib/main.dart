import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:placeholder/core/themes/text_form_field_theme.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/views/choose_user.dart';
import 'package:placeholder/features/auth/views/login.dart';
import 'package:placeholder/core/usecases/init_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/tasks/cubit/task_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  switch (kDebugMode) {
    case true:
      await dotenv.load(fileName: "staging.env");
      break;
    case false:
      await dotenv.load(fileName: "prod.env");
      break;
  }

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          inputDecorationTheme: inputDecorationTheme,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              color: Colors.white, surfaceTintColor: Colors.transparent)),
      darkTheme: ThemeData(
          inputDecorationTheme: inputDecorationTheme,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
              color: Colors.black, surfaceTintColor: Colors.transparent)),
      themeMode: ThemeMode.system,
      home: supabaseClient.auth.currentSession != null ? ChooseUser() : Login(),
    );
  }
}
