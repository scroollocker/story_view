import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/widgets/swipe.dart';
import 'package:stories/stories.dart';

class StoriesOpen extends StatefulWidget {
  final List<StoryCell> cells;
  final int? timeout;
  final Widget? timeoutWidget;
  final double? cellHeight;
  final double? cellWidht;
  final bool? exitButton;
  final bool? isRepeat;

  const StoriesOpen({
    Key? key,
    required this.cells,
    this.timeout,
    this.timeoutWidget,
    this.cellHeight,
    this.cellWidht,
    this.isRepeat = false,
    this.exitButton = true,
  }) : super(key: key);

  @override
  _StoriesOpenState createState() => _StoriesOpenState();
}

class _StoriesOpenState extends State<StoriesOpen> {
  List<StoryScreen> storyPages = [];
  late StoriesController storiesController;

  void onPageComplete() {
    if (storiesController.pageController.page == widget.cells.length - 1) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
    storiesController.pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  void initState() {
    super.initState();

    storiesController = StoriesController(
      pageController: PageController(initialPage: 0),
      storyControllers: List.generate(
        widget.cells.length,
        (_) => StoryController(),
      ),
    );

    for (int i = 0; i < widget.cells.length; i++) {
      storyPages.add(
        StoryScreen(
          stories: widget.cells[i].stories,
          onComplete: onPageComplete,
          controller: storiesController.storyControllers[i],
          timeout: widget.timeout,
          timeoutWidget: widget.timeoutWidget,
          exitButton: widget.exitButton,
          isRepeat: widget.isRepeat,
        ),
      );
    }
  }

  @override
  void dispose() {
    storiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StorySwipe(
      children: storyPages,
      pageController: storiesController.pageController,
      storiesController: storiesController,
    );
  }
}
