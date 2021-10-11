import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatelessWidget {
  final StoryController storyController;
  final Story story;
  final Widget? timeoutWidget;
  final int? timeout;
  const VideoWidget({
    required this.story,
    required this.storyController,
    this.timeoutWidget,
    this.timeout,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoLoad(
      storyController: storyController,
      videoLoader: VideoLoader(story.path),
    );
  }
}

class VideoLoad extends StatefulWidget {
  final StoryController storyController;
  final VideoLoader videoLoader;
  final Widget? timeoutWidget;
  final int? timeout;
  const VideoLoad({
    required this.storyController,
    required this.videoLoader,
    this.timeoutWidget,
    this.timeout,
    Key? key,
  }) : super(key: key);

  @override
  _VideoLoadState createState() => _VideoLoadState();
}

class _VideoLoadState extends State<VideoLoad> {
  StreamSubscription? _streamSubscription;

  VideoPlayerController? playerController;
  int _timer = 20;
  int timeout = 20;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timeout = widget.timeout ?? 20;
    _timer = timeout;

    widget.storyController.pause();
    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        playerController =
            VideoPlayerController.file(widget.videoLoader.videoFile!);

        playerController!.initialize().then((v) {
          widget.storyController.animationController!.duration =
              playerController!.value.duration;
          setState(() {});
          widget.storyController.play();
        });

        _streamSubscription =
            widget.storyController.playbackNotifier.listen((playbackState) {
          if (playbackState == PlaybackState.pause) {
            playerController!.pause();
            widget.storyController.animationController!.stop();
          } else if (playbackState == PlaybackState.previous) {
            playerController!.seekTo(const Duration(seconds: 0));
            playerController!.play();
            widget.storyController.animationController!.forward();
          } else {
            playerController!.play();
            widget.storyController.animationController!.forward();
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
    if (widget.videoLoader.state == LoadState.loading) {
      if (_timer != 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timer == 0) {
            setState(() {});
            timer.cancel();
          } else {
            if (widget.videoLoader.state == LoadState.loading) {
              _timer--;
            } else {
              _timer = widget.timeout ?? timeout;
              timer.cancel();
            }
          }
        });
        return Container(
          color: Colors.black,
          child: const Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Colors.blueGrey,
                strokeWidth: 2.0,
              ),
            ),
          ),
        );
      }
    }

    if (_timer == 0) {
      return widget.timeoutWidget ??
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Text(
                "Проверьте интернет соединение",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
    }
    //else {
    // print(_timer);
    // if (_timer <= timeout - 5) {
    //   return Container(
    //     width: double.infinity,
    //     height: double.infinity,
    //     color: Colors.black,
    //     child: const Center(
    //         child: SizedBox(
    //       width: 50,
    //       height: 50,
    //       child: RefreshProgressIndicator(
    //         color: Colors.grey,
    //         strokeWidth: 5.0,
    //       ),
    //     )),
    //   );
    // }
    //}
    return Container(
      color: Colors.black,
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}

class VideoLoader {
  String url;
  File? videoFile;
  Map<String, dynamic>? requestHeaders;
  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if (videoFile != null) {
      state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager()
        .getFileStream(url, headers: requestHeaders as Map<String, String>?);

    fileStream.listen((fileResponse) {
      if (fileResponse is FileInfo) {
        if (videoFile == null) {
          state = LoadState.success;

          videoFile = fileResponse.file;
          onComplete();
        }
      }
    });
  }
}
