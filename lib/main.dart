import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:placeholder/core/themes/text_form_field_theme.dart';
import 'package:placeholder/core/usecases/init_hydrated_bloc.dart';
import 'package:placeholder/core/usecases/init_pb.dart';
import 'package:placeholder/core/usecases/init_sentry.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/views/choose_user.dart';
import 'package:placeholder/features/auth/views/login.dart';
import 'package:placeholder/features/release_notes/cubit/release_notes_cubit.dart';
import 'package:pocketbase/pocketbase.dart';

import 'features/tasks/cubit/task_cubit.dart';

late PocketBase pb;
late AuthStore authStore;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHydratedBloc();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  if (kDebugMode) await dotenv.load(fileName: "staging.env");
  if (!kDebugMode) await dotenv.load(fileName: "prod.env");
  await initPB();

  await initSentry(
    mainApp: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => TaskCubit()),
        BlocProvider(create: (context) => ReleaseNotesCubit()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        primarySwatch: Colors.deepOrange,
        primaryColor: Colors.deepOrange,
        colorScheme: ColorScheme.fromSeed(
          surface: const Color.fromARGB(255, 25, 25, 25),
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: inputDecorationTheme,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: Builder(
        builder: (context) {
          if (pb.authStore.isValid) {
            pb.collection("users").authRefresh();
            context.read<AuthCubit>().createLoginEvent();
            return ChooseUser();
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
