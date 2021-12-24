import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/widgets/swipe.dart';
import 'package:stories/stories.dart';

typedef ActionButtonClicked = void Function();

class StoriesOpen extends StatefulWidget {
  final List<StoryCell> cells;
  final int? timeout;
  final Widget? timeoutWidget;
  final double? cellHeight;
  final double? cellWidht;

  const StoriesOpen({
    Key? key,
    required this.cells,
    this.timeout,
    this.timeoutWidget,
    this.cellHeight,
    this.cellWidht,
  }) : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
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
