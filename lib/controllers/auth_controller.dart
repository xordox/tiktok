import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok/constatns.dart';
import 'package:tiktok/models/user.dart' as model;

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<File?> _pickedImage;
  File? get profilePhoto => _pickedImage.value;

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar("Profile picture", "successfully picked profile picture");
    }
    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }

  //upload to firebase storage
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

  //register user
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        //save user to auth and firebase firestore
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
        Get.snackbar("Error Register User", 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar("Error Register User", e.toString());
    }
  }

  void loginUser(String email, String password) async{
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await  firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        log("login successful");
      } else {
        Get.snackbar("Error login User", 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar("Error login User", e.toString());
    }
  }
}
