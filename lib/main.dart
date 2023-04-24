import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:project_alpha/cubits/chat_model/chat_model_cubit.dart';
import 'package:project_alpha/utils/constants.dart';
import 'package:project_alpha/utils/gpt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_alpha/pages/splash_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_alpha/cubits/profiles/profiles_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:developer';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  OpenAI.apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";

  // log("helloworld");
  // await GPT().test();
  // await GPT().testChat();

  await Supabase.initialize(
    url: SupabaseProjectURL,
    anonKey: SupabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ChatModelsCubit>(
            create: (context) => ChatModelsCubit(),
          ),
          BlocProvider<ProfilesCubit>(
            create: (context) => ProfilesCubit(),
          )
        ],
        child: MaterialApp(
          title: 'SupaChat',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: const SplashPage(),
        ));
  }
}
