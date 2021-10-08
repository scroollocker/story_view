import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/story_screen.dart';
import 'package:vector_math/vector_math.dart' as rad;

class StorySwipe extends StatefulWidget {
  final List<StoryScreen> children;
  final PageController pageController;
  final StoriesController storiesController;

  StorySwipe({
    Key? key,
    required this.children,
    required this.pageController,
    required this.storiesController,
  })  : assert(children.isNotEmpty),
        super(key: key);

  @override
  _StorySwipeState createState() => _StorySwipeState();
}

class _StorySwipeState extends State<StorySwipe> {
  double currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();

    widget.pageController.addListener(() {
      setState(() {
        currentPageValue = widget.pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: IgnorePointer(
        ignoring: currentPageValue % 1 != 0 ? true : false,
        child: PageView.builder(
          controller: widget.pageController,
          itemCount: widget.children.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            double value;

            if (widget.pageController.position.haveDimensions == false) {
              value = index.toDouble();
            } else {
              value = widget.pageController.page!;
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dx < -5) {
                      widget.pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    }
                    if (details.delta.dx > 5) {
                      widget.pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    }
                  },
                  child: _SwipeWidget(
                    index: index,
                    pageNotifier: value,
                    child: widget.children[index],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

num degToRad(num deg) => deg * (pi / 180.0);

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
    final opacity = lerpDouble(0, 1, t.abs())!.clamp(0.0, 1.0);
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    transform.rotateY(-rad.radians(rotationY!));
    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
