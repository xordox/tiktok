import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tiktok/constants.dart';
import 'package:tiktok/controllers/auth_controller.dart';
import 'package:tiktok/controllers/video_controller.dart';
import 'package:tiktok/views/screens/comments_screen.dart';
import 'package:tiktok/views/widgets/circle_animation.dart';
import 'package:tiktok/views/widgets/video_player_item.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatelessWidget {
  VideoScreen({super.key});

  final VideoController videoController = Get.put(VideoController());

  buildProfile(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                clipBehavior: Clip.hardEdge,
                child: Image(
                  image: NetworkImage(profilePhoto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(11),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.grey,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(profilePhoto),
                  fit: BoxFit.cover,
                ),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Obx(() {
        return PageView.builder(
            itemCount: videoController.videoList.length,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            itemBuilder: (context, index) {
              final data = videoController.videoList[index];
              return Stack(
                children: [
                  VideoPlayerItem(videoUrl: data.videoUrl),
                  Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Expanded(
                          child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    data.userName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data.caption,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.music_note,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        data.songName,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            margin: EdgeInsets.only(top: size.height / 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildProfile(data.profilePhoto),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          videoController.likeVideo(data.id),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 40,
                                        color: data.likes.contains(
                                                authController.user.uid)
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      data.likes.length.toString(),
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentScreen(
                                                    id: authController.user.uid,
                                                  ))),
                                      child: const Icon(
                                        Icons.comment,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    const Text(
                                      "2",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Share.shareUri(
                                            Uri.parse(data.videoUrl));
                                      },
                                      child: const Icon(
                                        Icons.share,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    const Text(
                                      "4",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    CircleAnimation(
                                      child: buildMusicAlbum(data.profilePhoto),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ],
              );
            });
      }),
    );
  }
}
