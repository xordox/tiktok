import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tiktok/constatns.dart';
import 'package:tiktok/views/widgets/text_input_field.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _emailControlelr = TextEditingController();
  final TextEditingController _passwordControlelr = TextEditingController();
  final TextEditingController _userNameControlelr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tiktok",
                  style: TextStyle(
                      fontSize: 35,
                      color: buttonColor,
                      fontWeight: FontWeight.w800),
                ),
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 25,
                ),
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage(
                          "https://media.istockphoto.com/id/1388644810/photo/happy-caucasian-young-man-using-smart-phone-cellphone-for-calls-social-media-mobile.jpg?s=612x612&w=is&k=20&c=PUZXtvF8m_u85NGfqxQFWio8l2mxyRweWfps3ACCRJY="),
                      backgroundColor: Colors.black,
                    ),
                    Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add_a_photo)))
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                      textEditingController: _userNameControlelr,
                      labelText: "User Name",
                      icon: Icons.person),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                      textEditingController: _emailControlelr,
                      labelText: "Email",
                      icon: Icons.email),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                      textEditingController: _passwordControlelr,
                      labelText: "Password",
                      isObscure: true,
                      icon: Icons.password),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Center(
                      child: Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 20),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 20, color: buttonColor),
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
