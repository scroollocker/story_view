import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stories/src/models/story_process.dart';
import 'package:stories/src/models/story.dart';

class ImageWiget extends StatefulWidget {
  final int id;
  final Story story;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final ValueChanged<StoryProcess> onProcess;

  const ImageWiget({
    Key? key,
    required this.id,
    required this.story,
    required this.onProcess,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<ImageWiget> createState() => _ImageWigetState();
}

class _ImageWigetState extends State<ImageWiget> {
  late bool isComplete;

  @override
  void initState() {
    super.initState();
    isComplete = false;
  }

  Widget getAssetImage(Story story) {
    _onProcess(StoryStatus.complete);
    return ClipRRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.story.url,
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Image.asset(
            widget.story.url,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  void _onProcess(StoryStatus st, {dynamic error}) {
    if (st == StoryStatus.complete) {
      isComplete = true;
      widget.onProcess.call(StoryProcess(
        id: widget.id,
        error: error,
        duration: widget.story.duration,
        status: st,
      ));
    }
    if (!isComplete) {
      widget.onProcess.call(StoryProcess(
        id: widget.id,
        error: error,
        duration: widget.story.duration,
        status: st,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.story.url.contains('http')
        ? CachedNetworkImage(
            imageUrl: widget.story.url,
            errorWidget: (context, url, error) {
              _onProcess(StoryStatus.error, error: error);
              return widget.errorWidget ??
                  const Center(
                    child: Text(
                      'Проверьте интернет соединение',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
            },
            progressIndicatorBuilder: (context, url, progress) {
              _onProcess(StoryStatus.loading);
              return Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress.progress,
                    color: Colors.blueGrey,
                    strokeWidth: 3.0,
                  ),
                ),
              );
            },
            imageBuilder: (context, imageProvider) {
              _onProcess(StoryStatus.complete);

              if (widget.story.backType != null) {
                return Image(
                  alignment: Alignment.bottomCenter,
                  image: imageProvider,
                  fit: BoxFit.fitWidth,
                );
              }
              return ClipRRect(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : getAssetImage(widget.story);
  }
}
