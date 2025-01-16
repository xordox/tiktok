import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  String name;
  String profileImage;
  String email;
  String password;
  String uid;

  User({
    required this.name,
    required this.profileImage,
    required this.email,
    required this.password,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profileImage': profileImage,
      'email': email,
      'password': password,
      'uid': uid,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      profileImage: map['profileImage'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      uid: map['uid'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'profileImage': profileImage,
        'email': email,
        'password': password,
        'uid': uid,
      };

  static User fromSnap(DocumentSnapshot snap) {
    final snapshot = snap.data() as Map<String, dynamic>;
    return User(
      name: snapshot['name'] as String,
      profileImage: snapshot['profileImage'] as String,
      email: snapshot['email'] as String,
      password: snapshot['password'] as String,
      uid: snapshot['uid'] as String,
    );
  }
}
