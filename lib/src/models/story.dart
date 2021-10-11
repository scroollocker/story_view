import 'package:flutter/material.dart';

enum MediaType {
  image,
  video,
}

class StoryCell {
  String imagePath;
  List<Story> stories;

  StoryCell({
    required this.imagePath,
    required this.stories,
  });
}

class Story {
  final String path;
  MediaType meadiaType;
  Duration? duration;
  Widget? actionButton;
  Widget? child;

  Story(
    this.path, {
    this.child,
    this.meadiaType = MediaType.image,
    this.duration = const Duration(seconds: 5),
    this.actionButton,
  });
}
