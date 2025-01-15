import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/models/video.dart';
import 'package:tiktok/controllers/auth_controller.dart'; // Import auth_controller

// Provider for the VideoController
final videoControllerProvider =
    StateNotifierProvider<VideoController, List<Video>>((ref) {
  return VideoController(ref); // Pass ref to the constructor
});

class VideoController extends StateNotifier<List<Video>> {
  final Ref ref;

  VideoController(this.ref) : super([]) {
    _loadVideos();
  }

  final FirebaseFirestore _firestore = firestore;

  /// Loads the list of videos and listens to changes in real-time
  void _loadVideos() {
    _firestore.collection('videos').snapshots().listen((QuerySnapshot query) {
      List<Video> videos = query.docs.map((doc) => Video.fromSnap(doc)).toList();
      state = videos;
    });
  }

  /// Handles liking and unliking a video
  Future<void> likeVideo(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('videos').doc(id).get();
      
      // Access current user through the authControllerProvider
      var user = ref.read(authControllerProvider);
      if (user == null) {
        // Handle the case where the user is not logged in
        print("User is not logged in");
        return;
      }
      var uid = user.uid;  // Get user UID

      var likes = (doc.data()! as dynamic)['likes'] as List;

      if (likes.contains(uid)) {
        // Unlike the video
        await _firestore.collection('videos').doc(id).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        // Like the video
        await _firestore.collection('videos').doc(id).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print("Error liking video: $e");
    }
  }
}





