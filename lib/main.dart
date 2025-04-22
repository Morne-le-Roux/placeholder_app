import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:placeholder/core/themes/text_form_field_theme.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/views/choose_user.dart';
import 'package:placeholder/features/auth/views/login.dart';
import 'package:pocketbase/pocketbase.dart';

import 'features/tasks/cubit/task_cubit.dart';

late PocketBase pb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AuthCubit()),
      BlocProvider(create: (context) => TaskCubit()),
    ],
    child: const MainApp(),
  ));
}

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
      home: pb.authStore.token.isNotEmpty ? ChooseUser() : Login(),
    );
  }
}
