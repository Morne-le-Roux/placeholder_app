import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:placeholder/core/themes/text_form_field_theme.dart';
import 'package:placeholder/core/usecases/init_pb.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/views/choose_user.dart';
import 'package:placeholder/features/auth/views/login.dart';
import 'package:placeholder/features/payment/usecases/init_rc.dart';
import 'package:pocketbase/pocketbase.dart';

import 'features/tasks/cubit/task_cubit.dart';

late PocketBase pb;
late AuthStore authStore;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initPB();
  await initRC();

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
          primarySwatch: Colors.deepOrange,
          primaryColor: Colors.deepOrange,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              color: Colors.white, surfaceTintColor: Colors.transparent)),
      darkTheme: ThemeData(
          primarySwatch: Colors.deepOrange,
          primaryColor: Colors.deepOrange,
          inputDecorationTheme: inputDecorationTheme,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
              color: Colors.black, surfaceTintColor: Colors.transparent)),
      themeMode: ThemeMode.dark,
      home: pb.authStore.token.isNotEmpty ? ChooseUser() : Login(),
    );
  }
}
