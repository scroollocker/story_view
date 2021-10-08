import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';

class ImageWiget extends StatefulWidget {
  final Story story;
  final StoryController storyController;

  const ImageWiget({
    Key? key,
    required this.story,
    required this.storyController,
  }) : super(key: key);

  @override
  _ImageWigetState createState() => _ImageWigetState();
}

class _ImageWigetState extends State<ImageWiget> {
  @override
  void initState() {
    super.initState();
    widget.storyController.animationController!.duration =
        widget.story.duration ?? const Duration(seconds: 5);
    widget.storyController.play();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.story.path,
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Image.asset(
            widget.story.path,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }
}
