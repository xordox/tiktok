import 'dart:developer';
import 'dart:io';

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
    });
  }

  File? _pickedImage;
  File? get profilePhoto => _pickedImage;

  void _setInitialScreen(User? user) {
    final context = ref.read(navigatorKeyProvider).currentContext!;
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
  }

  Future<void> pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _pickedImage = File(pickedImage.path);
      ref
          .read(snackbarProvider)
          .show("Profile picture", "Successfully picked profile picture");
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

  Future<void> registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          password: password,
          profileImage: downloadUrl,
          uid: userCredential.user!.uid,
        );
        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());
      } else {
        ref
            .read(snackbarProvider)
            .show("Error Register User", 'Please enter all the fields');
      }
    } catch (e) {
      ref.read(snackbarProvider).show("Error Register User", e.toString());
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        log("Before signInWithEmailAndPassword");
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        log("After signInWithEmailAndPassword: ${firebaseAuth.currentUser?.uid}");
        log("Current Context: ${ref.read(navigatorKeyProvider).currentContext}");

        // Re-fetch the current user after login
        final currentUser = firebaseAuth.currentUser;
        if (currentUser == null) {
          throw Exception("Failed to retrieve user after login");
        }

        log("Login successful");
        _navigateToHome(); // Explicitly navigate to HomeScreen
      } else {
        ref.read(snackbarProvider).show(
              "Error Login User",
              'Please enter all the fields',
            );
      }
    } catch (e) {
      ref.read(snackbarProvider).show("Error Login User", e.toString());
    }
  }

  void _navigateToHome() {
    final navigatorKey = ref.read(navigatorKeyProvider);
    final context = navigatorKey.currentContext;

    if (context == null) {
      log("Navigation context is null");
      return;
    }

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
  void show(String title, String message) {
    print('$title: $message');
  }
}




