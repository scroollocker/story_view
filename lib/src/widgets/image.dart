import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stories/src/models/story.dart';

class ImageWiget extends StatefulWidget {
  final int id;
  final Story story;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Function(int id, Duration? duration)? onReady;
  final Function(int id)? onLoading;
  final Function(dynamic error)? onError;

  const ImageWiget({
    Key? key,
    required this.id,
    required this.story,
    this.loadingWidget,
    this.errorWidget,
    this.onReady,
    this.onError,
    this.onLoading,
  }) : super(key: key);

  @override
  State<ImageWiget> createState() => _ImageWigetState();
}

class _ImageWigetState extends State<ImageWiget> {
  Widget getImage(Story story) {
    return CachedNetworkImage(
      imageUrl: story.path,
      errorWidget: (context, url, error) {
        widget.onError?.call(error);
        if (widget.errorWidget != null) {
          return widget.errorWidget!;
        } else {
          return const Center(
            child: Text(
              'Проверьте интернет соединение',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
      progressIndicatorBuilder: (context, url, progress) {
        widget.onLoading?.call(widget.id);
        if (widget.loadingWidget != null) {
          return widget.loadingWidget!;
        } else {
          return Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress.progress,
                color: Colors.blueGrey,
                strokeWidth: 2.0,
              ),
            ),
          );
        }
      },
      imageBuilder: (context, imageProvider) {
        widget.onReady?.call(widget.id, story.duration);
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
    );
  }

  Widget getAssetImage(Story story) {
    widget.onReady?.call(widget.id, story.duration);
    return ClipRRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.story.path,
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
            widget.story.path,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: widget.story.path.contains('http')
          ? getImage(widget.story)
          : getAssetImage(widget.story),
    );
  }
}
