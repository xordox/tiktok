import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  Timer? _timer;
  double _progress = 0.0;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Rebuild to reflect initialization
        videoPlayerController.play();
        videoPlayerController.setVolume(1);
        videoPlayerController.setLooping(true);

        // Start the timer to update progress
        _startProgressTimer();
      });
  }

  void _startProgressTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if (videoPlayerController.value.isInitialized) {
        final currentPosition = videoPlayerController.value.position;
        final totalDuration = videoPlayerController.value.duration;
        if (totalDuration.inMilliseconds > 0) {
          setState(() {
            _progress =
                currentPosition.inMilliseconds / totalDuration.inMilliseconds;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Video Player
        Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(color: Colors.black),
          child: videoPlayerController.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    isPlaying
                        ? videoPlayerController.pause()
                        : videoPlayerController.play();

                    isPlaying = !isPlaying;
                  },
                  child: AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),

        // Linear Progress Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            minHeight: 2.0,
            value: _progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}
