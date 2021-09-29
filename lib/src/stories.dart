import 'dart:async';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';
import 'package:stories/src/models/story_cell.dart';
import 'package:vector_math/vector_math.dart' as rad;

import 'package:video_player/video_player.dart';
import 'package:story_view/story_view.dart';

class Stories extends StatefulWidget {
  final List<StoryCell> cells;
  final List<Story> stories;
  final Color backgroundColor;
  final Color indicatorColor;
  final double? cellSize;

  const Stories(
      {Key? key,
      required this.cells,
      required this.stories,
      required this.backgroundColor,
      required this.indicatorColor,
      this.cellSize})
      : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  List<StoryPage> storyPages = [];
  late StoriesController storiesController;

  double opacity = 0;

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
        StoryPage(
          stories: _getStories(widget.cells[i]),
          onPageComplete: onPageComplete,
          backgroundColor: widget.backgroundColor,
          indicatorColor: widget.indicatorColor,
          storyController: storiesController.storyControllers[i],
        ),
      );
    }
  }

  @override
  void dispose() {
    storiesController.pageController.dispose();
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

      storiesController.pageController.addListener(() {
        storiesController.checkRoll();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorySwipe(
            children: storyPages,
            pageController: storiesController.pageController,
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.cellSize ?? 70,
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
              ));
        },
      ),
    );
  }
}

////////////////////////////////////
//          StoryPage
////////////////////////////////////

class StoryPage extends StatefulWidget {
  final List<Story> stories;
  final Color backgroundColor;
  final Color indicatorColor;
  final void Function() onPageComplete;
  final StoryController storyController;

  StoryPage({
    Key? key,
    required this.stories,
    required this.onPageComplete,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.storyController,
  }) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StoryView(
          storyItems: toStoryItems(widget.stories, widget.storyController),
          onComplete: () {
            widget.onPageComplete();
          },
          inline: false,
          progressPosition: ProgressPosition.top,
          repeat: false,
          controller: widget.storyController,
        ),
        Positioned(
            right: 20,
            top: 75,
            child: Container(
              width: 35,
              height: 35,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Color(0xffB6BCC3))),
                ),
              ),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white24),
            ))
      ],
    );
  }

  List<StoryItem> toStoryItems(
      List<Story> stories, StoryController storyController) {
    List<StoryItem> storyItems = [];
    for (int i = 0; i < stories.length; i++) {
      switch (stories[i].meadiaType) {
        case MediaType.image:
          {
            switch (stories[i].sourceType) {
              case SourceType.asset:
                {
                  storyItems.add(StoryItem(ImageWidget(stories[i].path),
                      duration: stories[i].duration));
                  break;
                }
              case SourceType.url:
                {
                  storyItems.add(StoryItem(
                      ImageWidget(stories[i].path, isNetworkImage: true),
                      duration: stories[i].duration));
                  break;
                }
              default:
                break;
            }

            break;
          }
        case MediaType.video:
          {
            storyItems.add(VideoWidget(
                    key: Key('video-$i'),
                    url: stories[i].path,
                    storyController: storyController,
                    backgroundColor: widget.backgroundColor,
                    indicatorColor: widget.indicatorColor)
                .storyItemVideo);
            break;
          }
        default:
          break;
      }
    }
    return storyItems;
  }
}

////////////////////////////////////
//            Swipe
////////////////////////////////////

class StorySwipe extends StatefulWidget {
  final List<StoryPage> children;
  final PageController pageController;

  StorySwipe({
    Key? key,
    required this.children,
    required this.pageController,
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

  void next() {
    setState(() {
      currentPageValue = widget.pageController.page!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        double value;

        if (widget.pageController.position.haveDimensions == false) {
          value = index.toDouble();
        } else {
          value = widget.pageController.page!;
        }
        return _SwipeWidget(
          index: index,
          pageNotifier: value,
          child: widget.children[index],
        );
      },
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

////////////////////////////////////
//         ImageWidget
////////////////////////////////////

class ImageWidget extends StatelessWidget {
  final String path;
  final bool isNetworkImage;
  const ImageWidget(this.path, {Key? key, this.isNetworkImage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Stack(
              children: [
                Positioned.fill(child: Image.asset(path, fit: BoxFit.cover)),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(path),
        ],
      ),
    );
  }
}

////////////////////////////////////
//         VideoWidget
////////////////////////////////////

class VideoWidget {
  Key? key;
  final String url;
  final Color backgroundColor;
  final Color indicatorColor;
  final StoryController storyController;
  Map<String, dynamic>? requestHeaders;
  Duration? duration;
  bool? shown;

  VideoWidget({
    required this.url,
    required this.storyController,
    required this.backgroundColor,
    required this.indicatorColor,
    this.key,
    this.requestHeaders,
    this.duration,
    this.shown = false,
  });

  StoryItem get storyItemVideo {
    return StoryItem(
        Container(
          key: key,
          child: Stack(
            children: <Widget>[
              VideoLoad(
                storyController: storyController,
                videoLoader: VideoLoader(url, requestHeaders: requestHeaders),
                backgroundColor: backgroundColor,
                indicatorColor: indicatorColor,
              ),
            ],
          ),
        ),
        shown: shown!,
        duration: duration ?? const Duration(seconds: 10));
  }
}

class VideoLoad extends StatefulWidget {
  final StoryController storyController;
  final VideoLoader videoLoader;
  final Color backgroundColor;
  final Color indicatorColor;
  const VideoLoad({
    required this.storyController,
    required this.videoLoader,
    required this.backgroundColor,
    required this.indicatorColor,
    Key? key,
  }) : super(key: key);

  @override
  _VideoLoadState createState() => _VideoLoadState();
}

class _VideoLoadState extends State<VideoLoad> {
  Future<void>? playerLoader;

  StreamSubscription? _streamSubscription;

  VideoPlayerController? playerController;
  @override
  void initState() {
    super.initState();

    widget.storyController.pause();

    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        playerController =
            VideoPlayerController.file(widget.videoLoader.videoFile!);

        playerController!.initialize().then((v) {
          setState(() {});
          widget.storyController.play();
        });

        _streamSubscription =
            widget.storyController.playbackNotifier.listen((playbackState) {
          if (playbackState == PlaybackState.pause) {
            playerController!.pause();
          } else {
            playerController!.play();
          }
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (widget.videoLoader.state == LoadState.success &&
        playerController!.value.isInitialized) {
      double widthAspect = (playerController!.value.size.width - width) / width;
      double heightAspect =
          (playerController!.value.size.height - height) / height;

      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            child: Stack(
              children: [
                Positioned.fill(
                  left: -widthAspect * width / 2,
                  right: -widthAspect * width / 2,
                  top: -heightAspect * height / 2,
                  bottom: -heightAspect * height / 2,
                  child: AspectRatio(
                    aspectRatio: playerController!.value.aspectRatio,
                    child: VideoPlayer(playerController!),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: AspectRatio(
              aspectRatio: playerController!.value.aspectRatio,
              child: VideoPlayer(playerController!),
            ),
          ),
        ],
      );
    }

    return widget.videoLoader.state == LoadState.loading
        ? Container(
            width: double.infinity,
            height: double.infinity,
            color: widget.backgroundColor,
            child: Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.indicatorColor),
                  strokeWidth: 3,
                ),
              ),
            ),
          )
        : const Center(
            child: Text(
            "Media failed to load.",
            style: TextStyle(
              color: Colors.white,
            ),
          ));
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
