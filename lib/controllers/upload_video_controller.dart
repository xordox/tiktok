import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/models/video.dart';
import 'package:video_compress/video_compress.dart';

final uploadVideoProvider =
    StateNotifierProvider<VideoUploadNotifier, UploadState>((ref) {
  return VideoUploadNotifier();
});

class UploadState {
  final bool isUploading;
  final String? errorMessage;

  UploadState({this.isUploading = false, this.errorMessage});

  UploadState copyWith({bool? isUploading, String? errorMessage}) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage,
    );
  }
}

class VideoUploadNotifier extends StateNotifier<UploadState> {
  VideoUploadNotifier() : super(UploadState());

  final FirebaseFirestore _firestore = firestore;
  final FirebaseStorage _firebaseStorage = firebaseStorage;
  final FirebaseAuth _firebaseAuth = firebaseAuth;

  Future<File> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file!;
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = _firebaseStorage.ref().child('videos').child(id);
    UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    log("Video URL: $downloadUrl");
    return downloadUrl;
  }

  Future<File> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = _firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    log("Thumbnail URL: $downloadUrl");
    return downloadUrl;
  }

  Future<void> uploadVideo(String songName, String caption, String videoPath) async {
    try {
      state = state.copyWith(isUploading: true);

      String uid = _firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      // Generate unique video ID
      var allDocs = await _firestore.collection('videos').get();
      int len = allDocs.docs.length;
      String videoId = "Video $len";

      // Upload video and thumbnail
      String videoUrl = await _uploadVideoToStorage(videoId, videoPath);
      String thumbnail = await _uploadImageToStorage(videoId, videoPath);

      // Create video object
      Video video = Video(
        userName: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: videoId,
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profileImage'],
        thumbnail: thumbnail,
      );

      // Save to Firestore
      await _firestore.collection('videos').doc(videoId).set(video.toJson());
      log("Video uploaded successfully: ${video.toJson()}");

      state = state.copyWith(isUploading: false);
    } catch (e) {
      log("Error uploading video: $e");
      state = state.copyWith(isUploading: false, errorMessage: e.toString());
    }
  }
}





