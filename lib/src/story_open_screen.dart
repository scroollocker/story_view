import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/story_screen.dart';
import 'package:stories/stories.dart';

class StoriesOpen extends StatefulWidget {
  final StoryCell cell;
  final int? timeout;
  final Widget? timeoutWidget;
  final double? cellHeight;
  final double? cellWidht;
  final bool exitButton;
  final bool isRepeat;
  final Color statusBarColor;

  const StoriesOpen({
    Key? key,
    required this.cell,
    required this.statusBarColor,
    this.timeout,
    this.timeoutWidget,
    this.cellHeight,
    this.cellWidht,
    this.isRepeat = true,
    this.exitButton = false,
  }) : super(key: key);

  @override
  _StoriesOpenState createState() => _StoriesOpenState();
}

class _StoriesOpenState extends State<StoriesOpen> {
  late StoriesController storiesController;
  late StoryController controller;

  @override
  void initState() {
    super.initState();
    controller = StoryController(0);
    storiesController = StoriesController();
    storiesController.setPage(0);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: widget.statusBarColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: StoryScreen(
        id: 0,
        isOpen: true,
        storyController: controller,
        storiesController: storiesController,
        stories: widget.cell.stories,
        initialPage: 0,
        timeout: widget.timeout,
        timeoutWidget: widget.timeoutWidget,
        exitButton: widget.exitButton,
        isRepeat: widget.isRepeat,
      ),
    );
  }
}
