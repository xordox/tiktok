import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tiktok/constants.dart';
import 'package:tiktok/controllers/auth_controller.dart';
import 'package:tiktok/controllers/comment_controller.dart';
import 'package:tiktok/controllers/video_controller.dart';
import 'package:tiktok/views/screens/comments_screen.dart';
import 'package:tiktok/views/screens/search_screen.dart';
import 'package:tiktok/views/widgets/circle_animation.dart';
import 'package:tiktok/views/widgets/tabs.dart';
import 'package:tiktok/views/widgets/video_player_item.dart';

class VideoScreen extends ConsumerWidget {
  const VideoScreen({super.key});

  void _showModalBottomSheet(BuildContext context, String id) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CommentScreen(videoId: id);
      },
    );
  }

  Widget buildProfile(String profilePhoto) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 23,
        backgroundImage: NetworkImage(profilePhoto),
      ),
    );
  }

  Widget buildMusicAlbum(String profilePhoto) {
    return const CircleAvatar(
      radius: 23,
      backgroundImage: AssetImage("assets/music.png"),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoList = ref.watch(videoControllerProvider);
    final comments = ref.watch(commentControllerProvider);

    return Scaffold(
        body: Stack(children: [
      videoList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videoList.length,
              controller: PageController(initialPage: 0, viewportFraction: 1),
              itemBuilder: (context, index) {
                ref
                    .read(commentControllerProvider.notifier)
                    .fetchComments(videoList[index].id);
                final data = videoList[index];
                return Stack(
                  children: [
                    VideoPlayerItem(videoUrl: data.videoUrl),
                    Column(
                      children: [
                        const SizedBox(height: 100),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                margin: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height / 5),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildProfile(data.profilePhoto),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () => ref
                                              .read(videoControllerProvider
                                                  .notifier)
                                              .likeVideo(data.id),
                                          child: Icon(
                                            Icons.favorite,
                                            size: 30,
                                            color: data.likes.contains(ref
                                                    .read(
                                                        authControllerProvider)!
                                                    .uid)
                                                ? Colors.red
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          data.likes.length.toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 7),
                                        InkWell(
                                          onTap: () => _showModalBottomSheet(
                                              context, data.id),
                                          child: SvgPicture.asset(
                                            "assets/svg/message.svg",
                                            color: Colors.white,
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          comments.length.toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 7),
                                        InkWell(
                                          onTap: () => Share.shareUri(
                                            Uri.parse(data.videoUrl),
                                          ),
                                          child: SvgPicture.asset(
                                            "assets/svg/share.svg",
                                            color: Colors.white,
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        const Text(
                                          "Share",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 7),
                                        buildMusicAlbum(data.profilePhoto),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
      Positioned(
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            height: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/live_icon.png"),
                const Tabs(),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  ),
                  child: const Icon(
                    Icons.search,
                    size: 30,
                  ),
                )
              ],
            ),
          ))
    ]));
  }
}
