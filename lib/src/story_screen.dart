import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';
import 'package:stories/src/models/story_process.dart';
import 'package:stories/src/models/story_ready.dart';
import 'package:stories/src/story_listen.dart';
import 'package:stories/src/widgets/animated_bar.dart';
import 'package:stories/src/widgets/story_item.dart';

class StoryScreen extends StatefulWidget {
  final int id;
  final List<Story> stories;
  final StoryController storyController;
  final StoriesController storiesController;
  final int initialPage;
  final int initialStory;
  final VoidCallback? onComplete;
  final Widget? timeoutWidget;
  final int? timeout;
  final bool exitButton;
  final bool isRepeat;
  final bool isOpen;
  final Function(int id)? onWatched;

  const StoryScreen({
    Key? key,
    required this.id,
    required this.stories,
    required this.storyController,
    required this.storiesController,
    this.timeoutWidget,
    this.initialStory = 0,
    this.initialPage = 0,
    this.timeout,
    this.isRepeat = false,
    this.exitButton = true,
    this.onComplete,
    this.isOpen = false,
    this.onWatched,
  }) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late StoryListen _storyListen;

  @override
  void initState() {
    super.initState();

    _storyListen = StoryListen(
        List.generate(widget.stories.length,
            (index) => StoryReady(story: widget.stories[index])),
        widget.initialStory);

    widget.storyController.status = StreamController<PlaybackState>();

    _storyListen.addListener(storyListener);
    widget.storyController.status?.stream.listen((event) {
      switch (event) {
        case PlaybackState.play:
          _play();
          break;
        case PlaybackState.pause:
          _pause();
          break;
        case PlaybackState.next:
          _nextPage();
          break;
        case PlaybackState.previous:
          _previousPage();
          break;
        case PlaybackState.reset:
          _reset();
          break;
        case PlaybackState.repeat:
          _repeat();
          break;
        case PlaybackState.wait:
          break;
        default:
          _reset();
          break;
      }
    });

    _pageController = PageController(initialPage: widget.initialStory);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.storyController.status?.add(PlaybackState.next);
      }
    });
  }

  void _play() {
    // print('PLAY ${_storyListen.currentStory}');
    if (_storyListen.currentStatus == StoryStatus.complete) {
      try {
        _animationController.forward();
        if (_storyListen.mediaType == MediaType.video) {
          widget.storyController.play?.call();
        }
      } catch (_) {
        _animationController.reset();
      }
    }
  }

  void _pause() {
    if (_storyListen.currentStatus == StoryStatus.complete) {
      try {
        _animationController.stop();
        if (_storyListen.mediaType == MediaType.video) {
          widget.storyController.pause?.call();
        }
      } catch (_) {
        _animationController.reset();
      }
    }
  }

  void _repeat() {
    try {
      _animationController.reset();
      _animationController.forward();
      if (_storyListen.mediaType == MediaType.video) {
        widget.storyController.repeat?.call();
      }
    } catch (_) {}
  }

  void _reset() {
    try {
      _animationController.reset();
      if (_storyListen.mediaType == MediaType.video) {
        widget.storyController.reset?.call();
      }
    } catch (_) {}
  }

  void _nextPage() {
    widget.onWatched?.call(_storyListen.currentStory);
    if (_storyListen.currentStory == widget.stories.length - 1) {
      if (widget.isRepeat) {
        _storyListen.changePage(id: 0);
        _pageController.jumpToPage(0);
      } else {
        widget.onComplete?.call();
      }
    } else {
      _storyListen.pageIncrement();
      _pageController.jumpToPage(_storyListen.currentStory);
    }
  }

  void _previousPage() {
    if (_storyListen.currentStory == 0) {
      _storyListen.changePage(id: 0);
      _pageController.jumpToPage(0);
    } else {
      _storyListen.pageDecrement();
      _pageController.jumpToPage(_storyListen.currentStory);
    }
  }

  void storyListener() {
    if (widget.storiesController.id == widget.storyController.id &&
        _storyListen.currentStatus == StoryStatus.complete) {
      _animationController.duration = _storyListen.getCurrentDuration();
      widget.storyController.status?.add(PlaybackState.repeat);
    }
  }

  @override
  void dispose() {
    widget.storyController.status?.close();
    _storyListen.removeListener(storyListener);
    _storyListen.dis();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (!widget.isOpen) {
            if (details.delta.dy > 15) {
              Navigator.of(context).pop();
            }
          }
        },
        onTapDown: (details) =>
            widget.storyController.status?.add(PlaybackState.pause),
        onTapUp: (details) =>
            widget.storyController.status?.add(PlaybackState.play),
        onLongPressStart: (details) =>
            widget.storyController.status?.add(PlaybackState.pause),
        onLongPressUp: () =>
            widget.storyController.status?.add(PlaybackState.play),
        child: PageView.builder(
          itemCount: widget.stories.length,
          scrollDirection: Axis.horizontal,
          allowImplicitScrolling: true,
          pageSnapping: true,
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Stack(
                  children: [
                    StoryItem(
                      id: index,
                      storyController: widget.storyController,
                      story: widget.stories[index],
                      timeout: widget.timeout,
                      timeoutWidget: widget.timeoutWidget,
                      onProcess: (process) {
                        _storyListen.changeValue(
                            id: process.id,
                            status: process.status,
                            duration: process.duration);
                      },
                      // onLoading: (id) {
                      //   _storyListen.changeValue(
                      //       id: id, status: StoryStatus.loading);
                      //   // print('LOADING');
                      // },
                      // onReady: (id, duration) async {
                      //   _storyListen.changeValue(
                      //       id: id,
                      //       status: StoryStatus.ready,
                      //       duration: duration);
                      // if (id == (widget.initialStory) ||
                      //     id == (widget.initialStory + 1) ||
                      //     id == (widget.initialStory - 1)) {
                      //   await Future.delayed(
                      //       const Duration(milliseconds: 100));
                      //   _storyListen.changeValue(
                      //       id: id,
                      //       status: StoryStatus.ready,
                      //       duration: duration);
                      // } else {
                      //   _storyListen.changeValue(
                      //       id: id,
                      //       status: StoryStatus.ready,
                      //       duration: duration);
                      // }
                      // print('READY');
                      // },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.storyController.status
                                ?.add(PlaybackState.previous),
                            child: SizedBox(
                              width: mediaWidth / 3,
                              height: double.infinity,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.storyController.status
                                ?.add(PlaybackState.next),
                            child: SizedBox(
                              width: mediaWidth / 3,
                              height: double.infinity,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 20.0 + MediaQuery.of(context).padding.top,
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
                                  animController: _animationController,
                                  position: i,
                                  currentIndex: index,
                                ),
                              );
                            })
                            .values
                            .toList(),
                      ),
                    ],
                  ),
                ),
                if (widget.exitButton)
                  Positioned(
                    right: 5,
                    top: 50 + MediaQuery.of(context).padding.top,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white24),
                            child: const Material(
                              color: Colors.transparent,
                              child: Center(
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                widget.stories[index].actionButton ?? const SizedBox(),
                widget.stories[index].child ?? const SizedBox(),
              ],
            );
          },
        ),
      ),
    );
  }
}
