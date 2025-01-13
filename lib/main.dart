import 'package:flutter/material.dart';
import 'package:tiktok/constatns.dart';
import 'package:tiktok/views/screens/authentication/login_screen.dart';
import 'package:tiktok/views/screens/authentication/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme:
          ThemeData.dark().copyWith(scaffoldBackgroundColor: backgroundColor),
      home: RegisterScreen(),
    );
  }
}
