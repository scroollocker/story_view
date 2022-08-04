import 'package:stories/src/models/story_process.dart';
import 'package:stories/src/models/story.dart';

class StoryReady {
  int? id;
  StoryStatus status;
  Duration? duration;
  final Story story;

  StoryReady(
      {this.id,
      this.status = StoryStatus.loading,
      this.duration,
      required this.story});
}
