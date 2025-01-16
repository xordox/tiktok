import 'dart:async';
import 'dart:developer';
import 'dart:math' as Math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:tiktok/main.dart';
import 'package:tiktok/models/video_comment.dart';
import 'package:tiktok/constants.dart';

final commentControllerProvider =
    StateNotifierProvider<CommentController, List<VideoComment>>((ref) {
  final isar = ref.watch(isarProvider).maybeWhen(
        data: (isar) => isar,
        orElse: () => null,
      );
  return CommentController(isar);
});

class CommentController extends StateNotifier<List<VideoComment>> {
  final Isar? isar;
  Timer? _botTimer;
  String botUrl =
      "https://cdn.pixabay.com/photo/2017/01/31/17/43/android-2025857_1280.png";

  CommentController(this.isar) : super([]);

  // Fetch comments for a video
  Future<void> fetchComments(String videoId) async {
    if (isar == null) return;
    final comments =
        await isar!.videoComments.filter().videoIdEqualTo(videoId).findAll();
    state = comments;
    log("Fetched ${comments.length} comments for video $videoId");
  }

  // Add a comment
  Future<void> addComment(
      {required String videoId,
      required String username,
      required String comment,
      required String imageUrl,
      bool isBot = false}) async {
    if (isar == null) return;

    final newComment = VideoComment(
      videoId: videoId,
      username: isBot ? "Bot" : username,
      comment: comment,
      timestamp: DateTime.now(),
      imageUrl: isBot ? botUrl : imageUrl,
    );

    await isar!.writeTxn(() async {
      await isar!.videoComments.put(newComment);
    });

    // Refresh the comments
    fetchComments(videoId);

    // Reset bot timer
    if (!isBot) _resetBotTimer(videoId);
  }

  // Handle bot comments
  void _resetBotTimer(String videoId) {
    _botTimer?.cancel();
    _botTimer = Timer(const Duration(seconds: 5), () {
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
      addComment(
        videoId: videoId,
        username: "Bot",
        comment: randomComment,
        imageUrl: botUrl,
        isBot: true,
      );
    });
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }
}
