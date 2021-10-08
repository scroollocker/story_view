import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';
import 'package:stories/src/widgets/image.dart';
import 'package:stories/src/widgets/video.dart';

class StoryItem extends StatefulWidget {
  final Story story;
  final StoryController storyController;
  const StoryItem({
    required this.story,
    required this.storyController,
    Key? key,
  }) : super(key: key);

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.story.meadiaType == MediaType.image) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ImageWiget(
              key: UniqueKey(),
              story: widget.story,
              storyController: widget.storyController,
            ),
          ),
        ],
      );
    }
    if (widget.story.meadiaType == MediaType.video) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: VideoWidget(
          key: UniqueKey(),
          story: widget.story,
          storyController: widget.storyController,
        ),
      );
    }
    return Container();
  }
}
