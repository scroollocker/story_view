import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final int id;
  final Story story;
  final Widget? timeoutWidget;
  final StoryController controller;
  final int? timeout;
  final Widget? loadingWidget;

  final Function(int id, Duration duration)? onReady;
  final Function(int id)? onLoading;
  final Function(dynamic error)? onError;

  const VideoWidget({
    required this.id,
    required this.story,
    required this.controller,
    this.timeoutWidget,
    this.timeout,
    this.onReady,
    this.onLoading,
    this.onError,
    this.loadingWidget,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  StreamSubscription? _streamSubscription;
  late VideoLoader videoLoader;

  VideoPlayerController? playerController;
  int _timer = 20;
  int timeout = 20;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timeout = widget.timeout ?? 20;
    _timer = timeout;

    videoLoader = VideoLoader(widget.story.path);

    widget.controller.pause = _pause;
    widget.controller.play = _play;
    widget.controller.repeat = _repeat;
    widget.controller.reset = _reset;

    videoLoader.loadVideo(() {
      if (videoLoader.state == LoadState.success) {
        playerController = VideoPlayerController.file(videoLoader.videoFile!);

        playerController!.initialize().then((_) {
          widget.onReady?.call(widget.id, playerController!.value.duration);
          setState(() {});
        });
      } else if (videoLoader.state == LoadState.loading) {
        widget.onLoading?.call(widget.id);
        setState(() {});
      } else if (videoLoader.state == LoadState.failure) {
        widget.onError?.call('Ошибка');
        setState(() {});
      }
    });
  }

  void _pause() {
    playerController?.pause();
  }

  void _play() {
    playerController?.play();
  }

  void _repeat() {
    playerController?.seekTo(const Duration(seconds: 0));
    playerController?.play();
  }

  void _reset() {
    playerController?.seekTo(const Duration(seconds: 0));
    playerController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (videoLoader.state == LoadState.success &&
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: AspectRatio(
                      aspectRatio: playerController!.value.aspectRatio,
                      child: VideoPlayer(playerController!),
                    ),
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
    if (videoLoader.state == LoadState.loading) {
      if (_timer != 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timer == 0) {
            setState(() {});
            timer.cancel();
          } else {
            if (videoLoader.state == LoadState.loading) {
              _timer--;
            } else {
              _timer = widget.timeout ?? timeout;
              timer.cancel();
            }
          }
        });
        if (widget.loadingWidget != null) {
          return widget.loadingWidget!;
        }
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
