import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/controllers/comment_controller.dart';
import 'package:tiktok/main.dart';
import 'package:tiktok/models/video_comment.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentScreen extends StatefulWidget {
  final String videoId;

  const CommentScreen({required this.videoId, super.key});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _controller = TextEditingController();
  late Isar _isar;
  late String imgUrl;
  late String userName;

  @override
  void initState() {
    super.initState();
    _isar = isar; // Use the global Isar instance
    getUserProfileDetails();
    _getCommentsForVideo();
  }

  getUserProfileDetails() async {
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(authController.user.uid).get();
    imgUrl = (userDoc.data()! as dynamic)['profileImage'];
    userName = (userDoc.data()! as dynamic)['name'];

    log("imgUrl: $imgUrl ");
    log(" userName: $userName");
  }

  Future<void> _addComment(String message) async {
    log("before adding");
    final newComment = VideoComment(
      videoId: widget.videoId,
      username: userName,
      comment: message,
      timestamp: DateTime.now(),
      imageUrl: imgUrl,
    );
    log("after adding");

    await _isar.writeTxn(() async {
      final id = await _isar.videoComments.put(newComment);
      log("Comment added with ID: $id");
    });

    _controller.clear();
    setState(() {});
  }

  Future<List<VideoComment>> _getCommentsForVideo() async {
    final comments = await _isar.videoComments
        .filter()
        .videoIdEqualTo(widget.videoId)
        .findAll();

    log("Comments fetched: ${comments.length}");
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<VideoComment>>(
              future: _getCommentsForVideo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No comments yet!"));
                }

                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment.username),
                      subtitle: Text(comment.comment),
                      trailing: Text(
                        "${comment.timestamp.hour}:${comment.timestamp.minute}",
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Add a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _addComment(_controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
