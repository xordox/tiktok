import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/models/user.dart' as model;
import 'package:tiktok/views/screens/authentication/login_screen.dart';
import 'package:tiktok/views/screens/home_screen.dart';
import 'package:flutter/material.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<User?> {
  final Ref ref;

  AuthController(this.ref) : super(firebaseAuth.currentUser) {
    // Listen to auth state changes
    firebaseAuth.authStateChanges().listen((user) {
      state = user;
      _setInitialScreen(user);
      if (user != null) {
        fetchUserDetails(user.uid);
      }
    });
  }

  File? _pickedImage;
  File? get profilePhoto => _pickedImage;

  model.User? _currentUser;
  model.User? get currentUser => _currentUser;

  void _setInitialScreen(User? user) {
    final navigatorKey = ref.read(navigatorKeyProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) {
        log("Navigation context is still null");
        return;
      }

      if (user == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  Future<void> pickImage(BuildContext context) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _pickedImage = File(pickedImage.path);
      ref.read(snackbarProvider).show(
            context,
            "Profile picture",
            "Successfully picked profile picture",
          );
    }
  }

  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);

    TaskSnapshot snap = await uploadTask;

    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> fetchUserDetails(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = model.User.fromSnap(doc);
        log('User details fetched: ${_currentUser!.name}');
      } else {
        log('Document does not exist or contains no data');
      }
    } catch (e) {
      log('Failed to fetch user details: $e');
    }
  }

  Future<bool> registerUser(BuildContext context, String username, String email,
      String password, File? image) async {
    bool isRegistered = false;
    try {
      if (username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          image == null) {
        ref.read(snackbarProvider).show(
              context,
              "Error Register User",
              "Please enter all the fields",
            );
        return false;
      }

      // Create user
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Upload profile image
      String downloadUrl = await _uploadToStorage(image);

      // Create user model
      model.User user = model.User(
        name: username,
        email: email,
        password: password,
        profileImage: downloadUrl,
        uid: userCredential.user!.uid,
      );

      // Save user data in Firestore
      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());

      log("User registered successfully: ${user.name}");
      ref.read(snackbarProvider).show(
            context,
            "Success",
            "User registered successfully",
          );
      return true;
    } catch (e) {
      ref.read(snackbarProvider).show(
            context,
            "Error Register User",
            e.toString(),
          );
      return false;
    }
  }

  Future<void> loginUser(
  BuildContext context,
  String email,
  String password,
  Function onSuccess, // Add the callback parameter
) async {
  try {
    if (email.isNotEmpty && password.isNotEmpty) {
      log("Before signInWithEmailAndPassword");
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("After signInWithEmailAndPassword: ${firebaseAuth.currentUser?.uid}");

      // Re-fetch the current user after login
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception("Failed to retrieve user after login");
      }

      log("Login successful");
      await fetchUserDetails(currentUser.uid);

      // Call the onSuccess callback and pass the context
      onSuccess();
    } else {
      ref.read(snackbarProvider).show(
            context,
            "Error Login User",
            'Please enter all the fields',
          );
    }
  } catch (e) {
    ref.read(snackbarProvider).show(
          context,
          "Error Login User",
          e.toString(),
        );
  }
}


  // Future<void> loginUser(
  //     BuildContext context, String email, String password) async {
  //   try {
  //     if (email.isNotEmpty && password.isNotEmpty) {
  //       log("Before signInWithEmailAndPassword");
  //       await firebaseAuth.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //       log("After signInWithEmailAndPassword: ${firebaseAuth.currentUser?.uid}");

  //       // Re-fetch the current user after login
  //       final currentUser = firebaseAuth.currentUser;
  //       if (currentUser == null) {
  //         throw Exception("Failed to retrieve user after login");
  //       }

  //       log("Login successful");
  //       await fetchUserDetails(currentUser.uid);

  //       _navigateToHome(context); 
  //     } else {
  //       ref.read(snackbarProvider).show(
  //             context,
  //             "Error Login User",
  //             'Please enter all the fields',
  //           );
  //     }
  //   } catch (e) {
  //     ref.read(snackbarProvider).show(
  //           context,
  //           "Error Login User",
  //           e.toString(),
  //         );
  //   }
  // }

  void _navigateToHome(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (route) => false,
  );
}
}

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final snackbarProvider = Provider<SnackbarHelper>((ref) {
  return SnackbarHelper();
});

class SnackbarHelper {
  // Show snackbar in the given BuildContext
  void show(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
