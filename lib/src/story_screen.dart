import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/widgets/animated_bar.dart';
import 'package:stories/src/widgets/story_item.dart';
import 'package:stories/src/widgets/swipe.dart';
import 'package:stories/stories.dart';

import 'package:rxdart/rxdart.dart';

typedef ActionButtonClicked = void Function();

class Stories extends StatefulWidget {
  final List<StoryCell> cells;
  final List<Story> stories;
  final Color backgroundColor;
  final Color indicatorbgndColor;
  final Color indicatorColor;

  const Stories({
    Key? key,
    required this.cells,
    required this.stories,
    this.backgroundColor = Colors.white,
    this.indicatorbgndColor = Colors.white,
    this.indicatorColor = Colors.blue,
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
          stories: _getStories(widget.cells[i]),
          onComplete: onPageComplete,
          controller: storiesController.storyControllers[i],
        ),
      );
    }
  }

  @override
  void dispose() {
    storiesController.dispose();
    super.dispose();
  }

  List<Story> _getStories(dynamic elem) {
    return widget.stories.where((e) => e.cell == elem).toList();
  }

  @override
  Widget build(BuildContext context) {
    _onStorySwipeClicked(int initialPage) {
      storiesController.pageController =
          PageController(initialPage: initialPage);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorySwipe(
            children: storyPages,
            pageController: storiesController.pageController,
            storiesController: storiesController,
          ),
        ),
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.cells.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _onStorySwipeClicked(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.cells[index].imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  final VoidCallback? onComplete;
  final StoryController controller;

  const StoryScreen({
    required this.stories,
    required this.controller,
    Key? key,
    this.onComplete,
  });

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.pageController = PageController();
    widget.controller.playbackNotifier = BehaviorSubject<PlaybackState>();
    widget.controller.animationController = AnimationController(vsync: this);
    widget.controller.currentPage = ValueNotifier<int>(0);
    widget.controller.stories = widget.stories;
    widget.controller.currentPage.value = 0;
    widget.controller.animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.controller.animComplete();
      }
    });

    widget.controller.playbackNotifier.listen((state) {
      if (state == PlaybackState.onComplete) {
        _onComplete();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.currentPage.value = 0;

    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    widget.controller.setMediaSize(width, height);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          _onTapUp(details);
        },
        onLongPressStart: (details) {
          widget.controller.pause();
        },
        onLongPressUp: () {
          widget.controller.play();
        },
        child: ValueListenableBuilder(
          valueListenable: widget.controller.currentPage,
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                StoryItem(
                  story: widget.stories[value as int],
                  storyController: widget.controller,
                ),
                Positioned(
                  top: 40.0,
                  left: 10.0,
                  right: 10.0,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: widget.stories
                            .asMap()
                            .map((i, e) {
                              return MapEntry(
                                i,
                                AnimatedBar(
                                  animController:
                                      widget.controller.animationController!,
                                  position: i,
                                  currentIndex: value,
                                ),
                              );
                            })
                            .values
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 60,
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Material(
                      color: Colors.transparent,
                      child: Center(
                        child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close,
                                color: Color(0xffB6BCC3))),
                      ),
                    ),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white24),
                  ),
                ),
                widget.stories[widget.controller.currentPage.value]
                        .actionButton ??
                    Container(),
                widget.stories[widget.controller.currentPage.value].child ??
                    Container(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  void _onTapUp(TapUpDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      widget.controller.previous();
    } else if (dx > 2 * screenWidth / 3) {
      widget.controller.next();
    }
  }
}
