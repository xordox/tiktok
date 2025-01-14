import 'package:isar/isar.dart';

part 'video_comment.g.dart';

@collection
class VideoComment {
  Id id = Isar.autoIncrement; // Auto-incremented ID

  @Index()
  late String videoId;

  late String username;

  late String imageUrl;

  late String comment;

  late DateTime timestamp;

  VideoComment({
    required this.videoId,
    required this.username,
    required this.imageUrl,
    required this.comment,
    required this.timestamp,
  });
}