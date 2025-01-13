import 'package:flutter/material.dart';
import 'package:tiktok/constatns.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Tiktok",
                  style: TextStyle(
                      fontSize: 35,
                      color: buttonColor,
                      fontWeight: FontWeight.w800),
                ),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 25,),
                Container()
              ],
            )),
      ),
    );
  }
}
