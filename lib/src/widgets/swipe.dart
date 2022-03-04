import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/helper/behavior_helper.dart';
import 'package:stories/src/models/story.dart';
import 'package:stories/src/story_screen.dart';
import 'package:vector_math/vector_math.dart' as rad;

class StorySwipe extends StatefulWidget {
  final List<StoryCell> cells;
  final List<StoryController> storyControllers;
  final int initialPage;
  final int timeout;
  final Widget timeoutWidget;
  final bool exitButton;
  final PageController pageController;
  final StoriesController storiesController;
  final VoidCallback onPageComplete;

  const StorySwipe({
    Key? key,
    required this.pageController,
    required this.storiesController,
    required this.cells,
    required this.storyControllers,
    required this.initialPage,
    required this.timeout,
    required this.timeoutWidget,
    required this.exitButton,
    required this.onPageComplete,
  }) : super(key: key);

  @override
  _StorySwipeState createState() => _StorySwipeState();
}

class _StorySwipeState extends State<StorySwipe> {
  double currentPageValue = 0.0;
  late PageController _pageController;
  List<StoryScreen> storyPages = [];

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController;
    _pageController.addListener(listener);

    storyPages = List.generate(
      widget.cells.length,
      (i) => StoryScreen(
        id: i,
        storyController: widget.storyControllers[i],
        storiesController: widget.storiesController,
        stories: widget.cells[i].stories,
        onComplete: widget.onPageComplete,
        initialPage: widget.initialPage,
        timeout: widget.timeout,
        timeoutWidget: widget.timeoutWidget,
        exitButton: widget.exitButton,
      ),
    );
  }

  void listener() {
    setState(() {
      currentPageValue = _pageController.page!;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: storyPages.length,
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            double value;
            widget.storyControllers[index].setId(index);
            if (_pageController.position.haveDimensions == false) {
              value = index.toDouble();
            } else {
              value = _pageController.page!;
            }

            return _SwipeWidget(
              index: index,
              pageNotifier: value,
              child: storyPages[index],
            );
          },
        ),
      ),
    );
  }
}

class _SwipeWidget extends StatelessWidget {
  final int index;
  final double pageNotifier;
  final Widget child;

  const _SwipeWidget({
    Key? key,
    required this.index,
    required this.pageNotifier,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLeaving = (index - pageNotifier) <= 0;
    final t = (index - pageNotifier);
    final rotationY = lerpDouble(0, 90, t);
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    transform.rotateY(-rad.radians(rotationY!));
    return Transform(
        alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
        transform: transform,
        child: child);
  }
}
