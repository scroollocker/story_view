import 'package:flutter/material.dart';

import 'story_cell.dart';

enum MediaType {
  image,
  video,
}

enum SourceType {
  asset,
  url,
}

class Story {
  final String path;
  final StoryCell cell;
  SourceType sourceType;
  MediaType meadiaType;
  Duration? duration;
  Widget? actionButton;
  Widget? child;

  Story(
    this.path,
    this.cell, {
    this.child,
    this.meadiaType = MediaType.image,
    this.sourceType = SourceType.url,
    this.duration = const Duration(seconds: 5),
    this.actionButton,
  });
}
