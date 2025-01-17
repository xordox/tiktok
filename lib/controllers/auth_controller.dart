import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

final isLoadingProvider = StateProvider<bool>((ref) => false);

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
          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
    final isLoading = ref.read(isLoadingProvider.notifier);
    isLoading.state = true; // Start loading

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
    } finally {
      isLoading.state = false; // Stop loading
    }
  }

  Future<void> signInWithGoogle(
    BuildContext context,
    Function onSuccess,
  ) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          model.User newUser = model.User(
            name: user.displayName ?? "Anonymous",
            email: user.email ?? "",
            profileImage: user.photoURL ?? "",
            password: "",
            uid: user.uid,
          );
          await firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toJson());
        }
        fetchUserDetails(user.uid);
        onSuccess();
      }
    } catch (e) {
      log(e.toString());
      ref.read(snackbarProvider).show(
            context,
            "Error Login Google",
            e.toString(),
          );
    }
  }

  Future<void> loginUser(
    BuildContext context,
    String email,
    String password,
    Function onSuccess,
  ) async {
    final isLoading = ref.read(isLoadingProvider.notifier);

    try {
      if (email.isEmpty || password.isEmpty) {
        ref.read(snackbarProvider).show(
              context,
              "Error Login User",
              'Please enter all the fields',
            );
        return;
      }

      isLoading.state = true; // Set loading state to true

      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception("Failed to retrieve user after login");
      }

      await fetchUserDetails(currentUser.uid);

      onSuccess();
    } catch (e) {
      ref.read(snackbarProvider).show(
            context,
            "Error Login User",
            e.toString(),
          );
    } finally {
      isLoading.state = false; // Reset loading state
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await firebaseAuth.signOut();
      // navigate to the login screen after logout
      _navigateToLogin(context);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToLogin(BuildContext context) {
    final navigatorKey = Navigator.of(context);
    navigatorKey.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
