import 'package:app_admin/screens/home_screen.dart';
import 'package:app_admin/screens/addform_screen.dart';
import 'package:app_admin/screens/editform_screen.dart';
import 'package:app_admin/screens/reset_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/screens/signin_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDzQglNf8EWoU5UwcOpgFRYGQQjUSf_7wI",
          appId: "1:97960709902:web:c71ac79178d2948ae6515f",
          messagingSenderId: "97960709902",
          projectId: "signin-1fb34"));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const SignInScreen(),
    );
  }
}
