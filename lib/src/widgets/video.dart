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
  const VideoWidget({
    required this.story,
    required this.storyController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoLoad(
      storyController: storyController,
      videoLoader: VideoLoader(story.path),
      backgroundColor: Colors.white,
      indicatorColor: Colors.blue,
    );
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
