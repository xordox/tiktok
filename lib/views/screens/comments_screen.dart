import 'dart:async';
import 'dart:developer';
import 'dart:math' as Math;

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
  Timer? _botTimer;
  String botUrl =
      "https://media.istockphoto.com/id/2177271654/vector/illustration-of-robot-icon-in-flat-style-illustration-of-childrens-toy.jpg?s=2048x2048&w=is&k=20&c=QfEiKopoGW3xtjAqO6yCxUCHbCqdmebsNo7RSQpm7g4=";

  // Resets the bot timer
  void _resetBotTimer() {
    _botTimer?.cancel(); // Cancel any existing timer
    _botTimer =
        Timer(const Duration(seconds: 5), _postBotComment); // Start a new timer
  }

  // Posts a bot comment
  void _postBotComment() {
    final botComments = [
      "Great video!",
      "This is so interesting!",
      "Awesome content!",
      "Keep it up!",
      "Loved this part!",
      "Can't wait for more!",
    ];
    final randomComment =
        botComments[Math.Random().nextInt(botComments.length)];
    _addComment(comment: randomComment, isBot: true);
  }

  @override
  void initState() {
    super.initState();
    _isar = isar;
    getUserProfileDetails();
    _getCommentsForVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    _botTimer?.cancel();
    super.dispose();
  }

  getUserProfileDetails() async {
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(authController.user.uid).get();
    imgUrl = (userDoc.data()! as dynamic)['profileImage'];
    userName = (userDoc.data()! as dynamic)['name'];

    log("imgUrl: $imgUrl ");
    log(" userName: $userName");
  }

  Future<void> _addComment(
      {required String comment, bool isBot = false}) async {
    log("before adding");
    final newComment = VideoComment(
      videoId: widget.videoId,
      username: isBot ? "Bot" : userName,
      comment: comment,
      timestamp: DateTime.now(),
      imageUrl: isBot ? botUrl : imgUrl,
    );
    log("after adding");

    await _isar.writeTxn(() async {
      final id = await _isar.videoComments.put(newComment);
      log("Comment added with ID: $id");
    });

    _controller.clear();
    _resetBotTimer(); // Reset the timer whenever a comment is added
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
                      _addComment(comment: _controller.text.trim());
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
