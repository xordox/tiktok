import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/controllers/auth_controller.dart';
import 'package:tiktok/views/screens/authentication/login_screen.dart';
import 'package:tiktok/views/widgets/text_input_field.dart';

class RegisterScreen extends ConsumerWidget {
  RegisterScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    fontWeight: FontWeight.w800,
                  ),
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
                    Container(
                      width: 128, // Width of the circle
                      height: 128, // Height of the circle
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color of the circle
                        shape: BoxShape.circle, // Makes the container circular
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ], // Add a shadow for a nice effect
                      ),
                      child: authController.profilePhoto == null
                          ? const Center(
                              child: Icon(
                                Icons.person, // Icon inside the circle
                                color: Colors.black, // Color of the icon
                                size: 50, // Size of the icon
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                authController.profilePhoto!,
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () => authController.pickImage(context),
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    textEditingController: _userNameController,
                    labelText: "User Name",
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    textEditingController: _emailController,
                    labelText: "Email",
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    textEditingController: _passwordController,
                    labelText: "Password",
                    isObscure: true,
                    icon: Icons.password,
                  ),
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
                    onTap: () async {
                      bool isRegistered = await authController.registerUser(
                        context,
                        _userNameController.text,
                        _emailController.text,
                        _passwordController.text,
                        authController.profilePhoto,
                      );
                      if (isRegistered) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: const Center(
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
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
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 20, color: buttonColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// class RegisterScreen extends ConsumerWidget {
//   RegisterScreen({super.key});

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _userNameController = TextEditingController();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authController = ref.read(authControllerProvider.notifier);

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Tiktok",
//                   style: TextStyle(
//                     fontSize: 35,
//                     color: buttonColor,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const Text(
//                   "Sign Up",
//                   style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(
//                   height: 25,
//                 ),
//                 Stack(
//                   children: [
//                     Container(
//                       width: 128, // Width of the circle
//                       height: 128, // Height of the circle
//                       decoration: BoxDecoration(
//                         color: Colors.white, // Background color of the circle
//                         shape: BoxShape.circle, // Makes the container circular
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ], // Add a shadow for a nice effect
//                       ),
//                       child: Center(
//                         child: authController.profilePhoto == null
//                             ? const Center(
//                                 child: Icon(
//                                   Icons.person, // Icon inside the circle
//                                   color: Colors.black, // Color of the icon
//                                   size: 50, // Size of the icon
//                                 ),
//                               )
//                             : ClipOval(
//                                 child: Image.file(
//                                   authController.profilePhoto!,
//                                   width: 128,
//                                   height: 128,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: -10,
//                       left: 80,
//                       child: IconButton(
//                         onPressed: () => authController.pickImage(context),
//                         icon: const Icon(Icons.add_a_photo),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 25,
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextInputField(
//                     textEditingController: _userNameController,
//                     labelText: "User Name",
//                     icon: Icons.person,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 25,
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextInputField(
//                     textEditingController: _emailController,
//                     labelText: "Email",
//                     icon: Icons.email,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 25,
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextInputField(
//                     textEditingController: _passwordController,
//                     labelText: "Password",
//                     isObscure: true,
//                     icon: Icons.password,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: buttonColor,
//                     borderRadius: const BorderRadius.all(Radius.circular(5)),
//                   ),
//                   child: InkWell(
//                     onTap: () async {
//                       bool isRegistered = await authController.registerUser(
//                         context,
//                         _userNameController.text,
//                         _emailController.text,
//                         _passwordController.text,
//                         authController.profilePhoto,
//                       );
//                       if (isRegistered) {
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const LoginScreen()),
//                           (route) => false,
//                         );
//                       }
//                     },
//                     child: const Center(
//                       child: Text(
//                         "Register",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 25,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Already have an account? ",
//                       style: TextStyle(fontSize: 20),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text(
//                         "Login",
//                         style: TextStyle(fontSize: 20, color: buttonColor),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
