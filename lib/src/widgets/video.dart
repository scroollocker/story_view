import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/helper/timeout.dart';
import 'package:stories/src/models/story.dart';
import 'package:stories/src/models/story_process.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final int id;
  final Story story;
  final Widget? timeoutWidget;
  final StoryController controller;
  final int? timeout;
  final Widget? loadingWidget;
  final ValueChanged<StoryProcess> onProcess;

  const VideoWidget({
    required this.id,
    required this.story,
    required this.controller,
    required this.onProcess,
    this.timeoutWidget,
    this.timeout,
    this.loadingWidget,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoLoader _videoLoader;
  late TimeoutListen _timeoutListen;
  late ValueNotifier<double> _progressIndicator;
  late ValueNotifier<StoryStatus> _widgetStatuses;
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _timeoutListen = TimeoutListen(widget.timeout ?? 30);
    _progressIndicator = ValueNotifier(0);
    _widgetStatuses = ValueNotifier(StoryStatus.init);
    _videoLoader = VideoLoader(widget.story.url);

    _timeoutListen.addListener(_timerListener);
    _widgetStatuses.addListener(_listener);
    _videoLoader.loadVideo(_videoLoaderComplete, _videoLoaderDonwloading);
    _playerController?.addListener(_videoListener);

    widget.controller.pause = _pause;
    widget.controller.play = _play;
    widget.controller.repeat = _repeat;
    widget.controller.reset = _reset;
  }

  void _videoLoaderComplete() {
    if (_videoLoader.state == LoadState.success) {
      _playerController = VideoPlayerController.file(_videoLoader.videoFile!);
      _playerController!.initialize().then((_) {
        _widgetStatuses.value = StoryStatus.complete;
      });
    } else if (_videoLoader.state == LoadState.loading) {
      _widgetStatuses.value = StoryStatus.loading;
    } else if (_videoLoader.state == LoadState.failure) {
      _widgetStatuses.value = StoryStatus.error;
    }
  }

  void _videoLoaderDonwloading(double progress) {
    _widgetStatuses.value = StoryStatus.downloading;
    _progressIndicator.value = progress;
  }

  void _listener() {
    switch (_widgetStatuses.value) {
      case StoryStatus.loading:
        _pause();
        widget.onProcess
            .call(StoryProcess(id: widget.id, status: StoryStatus.loading));
        _timeoutListen.restartTimer();
        break;
      case StoryStatus.error:
        _pause();
        widget.onProcess.call(StoryProcess(
            id: widget.id, status: StoryStatus.error, error: 'Ошибка'));
        _timeoutListen.cancel();
        break;
      case StoryStatus.timeout:
        _pause();
        widget.onProcess.call(StoryProcess(
            id: widget.id,
            status: StoryStatus.timeout,
            error: 'Первышено время ожидания'));
        _timeoutListen.cancel();
        break;
      case StoryStatus.complete:
        _pause();
        widget.onProcess.call(StoryProcess(
            id: widget.id,
            status: StoryStatus.complete,
            duration: _playerController!.value.duration));
        _timeoutListen.cancel();
        break;
      case StoryStatus.downloading:
        _pause();
        widget.onProcess
            .call(StoryProcess(id: widget.id, status: StoryStatus.downloading));
        _timeoutListen.cancel();
        break;
      case StoryStatus.init:
    }
  }

  void _videoListener() {
    if (_playerController?.value.hasError == true) {
      _widgetStatuses.value = StoryStatus.error;
      widget.onProcess.call(StoryProcess(
          id: widget.id, status: StoryStatus.error, error: 'Ошибка плеера'));
      _timeoutListen.cancel();
    }
  }

  void _timerListener() {
    if (_timeoutListen.value <= 0) {
      _widgetStatuses.value = StoryStatus.timeout;
    }
  }

  void _pause() {
    _playerController?.pause();
  }

  void _play() {
    _playerController?.play();
  }

  void _repeat() {
    _playerController?.seekTo(const Duration(seconds: 0));
    _playerController?.play();
  }

  void _reset() {
    _playerController?.seekTo(const Duration(seconds: 0));
    _playerController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ValueListenableBuilder<StoryStatus>(
        valueListenable: _widgetStatuses,
        builder: (context, value, child) {
          switch (value) {
            case StoryStatus.init:
              return const SizedBox();
            case StoryStatus.loading:
              return const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                ),
              );
            case StoryStatus.error:
              return const Center(
                child: Text(
                  'Произошла непредвиденная ошибка',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            case StoryStatus.timeout:
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Проверьте интернет соединение',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            case StoryStatus.complete:
              double widthAspect =
                  (_playerController!.value.size.width - width) / width;
              double heightAspect =
                  (_playerController!.value.size.height - height) / height;

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
                              aspectRatio: _playerController!.value.aspectRatio,
                              child: VideoPlayer(_playerController!),
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
                      aspectRatio: _playerController!.value.aspectRatio,
                      child: VideoPlayer(_playerController!),
                    ),
                  ),
                ],
              );
            case StoryStatus.downloading:
              return ValueListenableBuilder<double>(
                valueListenable: _progressIndicator,
                builder: (context, value, child) {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: value,
                          color: Colors.blueGrey,
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
                  );
                },
              );
          }
        });
  }

  @override
  void dispose() {
    _timeoutListen.removeListener(_timerListener);
    _playerController?.removeListener(_videoListener);
    _timeoutListen.cancel();
    _playerController?.dispose();
    super.dispose();
  }
}

class VideoLoader {
  String url;
  File? videoFile;
  Map<String, dynamic>? requestHeaders;
  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(
      VoidCallback onComplete, ValueChanged<double> onDownloadProgress) {
    if (videoFile != null) {
      state = LoadState.success;
      onComplete();
      return;
    }

    final fileStream = DefaultCacheManager().getFileStream(url,
        headers: requestHeaders as Map<String, String>?, withProgress: true);
    fileStream.listen((fileResponse) {
      if (fileResponse is DownloadProgress) {
        state = LoadState.downloading;
        onDownloadProgress.call(
            double.parse(fileResponse.progress?.toStringAsFixed(3) ?? '0'));
      } else if (fileResponse is FileInfo) {
        if (videoFile == null) {
          videoFile = fileResponse.file;
          state = LoadState.success;
          onComplete();
        } else {
          state = LoadState.success;
          onComplete();
        }
      }
    });
    fileStream.handleError((err, stacktrace) {
      state = LoadState.failure;
      onComplete();
    });
  }
}
