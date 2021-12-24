import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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
  final int? timeout;
  final Widget? timeoutWidget;
  final double? cellHeight;
  final double? cellWidht;

  const Stories({
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
      height: widget.cellHeight ?? 70,
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
                child: widget.cells[index].imagePath.contains('http')
                    ? CachedNetworkImage(
                        imageUrl: widget.cells[index].imagePath,
                        errorWidget: (context, url, error) {
                          return Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.black);
                        },
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            width: widget.cellWidht ?? 70,
                            height: widget.cellHeight ?? 70,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        widget.cells[index].imagePath,
                        height: widget.cellHeight ?? 70,
                        width: widget.cellWidht ?? 70,
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
  final Widget? timeoutWidget;
  final int? timeout;

  const StoryScreen({
    required this.stories,
    required this.controller,
    this.timeoutWidget,
    this.timeout,
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
    widget.controller.animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          widget.controller.pause();
        },
        onTapUp: (details) {
          widget.controller.play();
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
                  timeout: widget.timeout,
                  timeoutWidget: widget.timeoutWidget,
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
                    const SizedBox(),
                widget.stories[widget.controller.currentPage.value].child ??
                    const SizedBox(),
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
