import 'package:flutter/material.dart';
import 'package:pr_14_15/pages/home_page.dart';
import 'package:pr_14_15/pages/fav_page.dart';
import 'package:pr_14_15/pages/login_page.dart';
import 'package:pr_14_15/pages/prof_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://jgutkgiriwrywdgqkeze.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpndXRrZ2lyaXdyeXdkZ3FrZXplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQxODgwODQsImV4cCI6MjA0OTc2NDA4NH0.DqenbgAxLIwbm2kNTOY0b2wqCIskH6FH4sRyZsysAAA',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,

      title: 'CakeTime',
      home: FutureBuilder(
      future: Future.value(Supabase.instance.client.auth.currentSession),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final session = snapshot.data; // Получаем текущую сессию
        if (session == null) {
          return LoginPage(); // Пользователь не авторизован
        } else {
          return ProfPage(); // Пользователь авторизован
        }
      },
    ),

    );
  }
}
