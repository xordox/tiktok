// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  String userName;
  String uid;
  String id;
  List likes;
  int commentCount;
  int shareCount;
  String songName;
  String caption;
  String thumbnail;
  String videoUrl;
  String profilePhoto;

  Video({
    required this.userName,
    required this.uid,
    required this.id,
    required this.likes,
    required this.commentCount,
    required this.shareCount,
    required this.songName,
    required this.caption,
    required this.thumbnail,
    required this.videoUrl,
    required this.profilePhoto,
  });

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "uid": uid,
        "profilePhoto": profilePhoto,
        "id": id,
        "likes": likes,
        "commentCount": commentCount,
        "shareCount": shareCount,
        "songName": songName,
        "caption": caption,
        "videoUrl": videoUrl,
        "thumbnail": thumbnail,
      };

  static Video fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Video(
        userName: snapshot["userName"],
        uid: snapshot["uid"],
        id: snapshot["id"],
        likes: snapshot["likes"],
        commentCount: snapshot["ommentCount"],
        shareCount: snapshot["shareCount"],
        songName: snapshot["songName"],
        caption: snapshot["caption"],
        thumbnail: snapshot["thumbnail"],
        videoUrl: snapshot["videoUrl"],
        profilePhoto: snapshot["profilePhoto"]);
  }
}
