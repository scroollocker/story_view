import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/story_screen.dart';
import 'package:stories/src/widgets/swipe.dart';
import 'package:stories/stories.dart';

typedef ActionButtonClicked = void Function();

class Stories extends StatefulWidget {
  final List<StoryCell> cells;
  final int timeout;
  final Widget? timeoutWidget;
  final double? cellHeight;
  final double? cellWidht;
  final bool exitButton;
  final Color? statusBarColor;
  final Function(int id, int sroryId)? onWatched;

  const Stories({
    Key? key,
    required this.cells,
    this.timeout = 20,
    this.timeoutWidget,
    this.cellHeight,
    this.cellWidht,
    this.statusBarColor,
    this.onWatched,
    this.exitButton = true,
  }) : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  List<StoryScreen> storyPages = [];
  late List<StoryController> _storyControllers;
  late StoriesController _storiesController;
  late PageController _pageController;

  late int _currentPage;

  void onPageComplete() {
    if (_pageController.page == widget.cells.length - 1) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
    for (var controller in _storyControllers) {
      if (controller.status != null && !controller.status!.isClosed) {
        controller.status?.add(PlaybackState.reset);
      }
    }
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _storiesController = StoriesController();

    _storyControllers =
        List.generate(widget.cells.length, (index) => StoryController(index));

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.removeListener(pageListener);
    _pageController.dispose();
    _storiesController.dispose();
    super.dispose();
  }

  void pageListener() {
    if (_pageController.page! % 1 == 0) {
      _currentPage = _pageController.page!.toInt();
      _storiesController.setPage(_currentPage);
      if (_currentPage != 0) {
        _storyControllers[_currentPage - 1].status?.add(PlaybackState.reset);
      }
      // print('PLAY ${_currentPage}');
      _storyControllers[_currentPage].status?.add(PlaybackState.play);
      // _storyControllers[_currentPage].update?.call();
      if (_currentPage != _storyControllers.length - 1) {
        _storyControllers[_currentPage + 1].status?.add(PlaybackState.reset);
      }
    } else {
      for (var controller in _storyControllers) {
        if (controller.status != null && !controller.status!.isClosed) {
          controller.status?.add(PlaybackState.pause);
        }
      }
    }
  }

  void _onStorySwipeClicked(int initialPage) {
    _currentPage = initialPage;
    _pageController = PageController(initialPage: _currentPage);

    _pageController.addListener(pageListener);
    _storiesController.setPage(_currentPage);
    _storiesController.init = true;
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => StorySwipe(
                statusBarColor: widget.statusBarColor,
                cells: widget.cells,
                exitButton: widget.exitButton,
                initialPage: initialPage,
                onPageComplete: onPageComplete,
                onWatched: widget.onWatched,
                storyControllers: _storyControllers,
                timeout: widget.timeout,
                pageController: _pageController,
                storiesController: _storiesController,
                timeoutWidget: widget.timeoutWidget ?? const SizedBox(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(Tween<Offset>(
                      begin: const Offset(0, 1), end: const Offset(0, 0))
                  .chain(CurveTween(curve: Curves.easeInOut))),
              child: child,
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(5.0).copyWith(
                  left: index == 0 ? 16 : 5,
                  right: index == widget.cells.length - 1 ? 16 : 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.cells[index].iconUrl,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
