import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/controllers/comment_controller.dart';
import 'package:tiktok/models/video_comment.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String videoId;

  const CommentScreen({required this.videoId, super.key});

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final TextEditingController _controller = TextEditingController();
  late String imgUrl;
  late String userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserProfileDetails();
    ref.read(commentControllerProvider.notifier).fetchComments(widget.videoId);
  }

  getUserProfileDetails() async {
    DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .get();
    setState(() {
      imgUrl = (userDoc.data()! as dynamic)['profileImage'];
      userName = (userDoc.data()! as dynamic)['name'];
      isLoading = false;
    });

    log("imgUrl: $imgUrl ");
    log(" userName: $userName");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: (Radius.circular(30.0))),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Text(
                    "${comments.length} comments",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.clear,
                        size: 25,
                        color: Colors.grey[700],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: comments.isEmpty
                  ? const Center(child: Text("No comments yet!"))
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final VideoComment comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(comment.imageUrl),
                            backgroundColor: Colors.grey[300],
                          ),
                          title: Text(
                            comment.username,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          subtitle: Text(
                            comment.comment,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                          trailing: Text(
                            "${comment.timestamp.hour}:${comment.timestamp.minute}",
                          ),
                        );
                      },
                    ),
            ),
            Divider(
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: isLoading
                        ? const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(imgUrl),
                            radius: 20,
                          ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, // Align text vertically
                                horizontal: 15.0,
                              ),
                              hintText: "Add comment...",
                              hintStyle: TextStyle(
                                color: Colors.black54,
                              ),
                              border: InputBorder.none, // Remove default border
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              ref
                                  .read(commentControllerProvider.notifier)
                                  .addComment(
                                    videoId: widget.videoId,
                                    username: userName,
                                    comment: _controller.text.trim(),
                                    imageUrl: imgUrl,
                                  );
                              _controller.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
