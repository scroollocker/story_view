import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stories/src/controller.dart';
import 'package:stories/src/models/story.dart';

class ImageWiget extends StatefulWidget {
  final Story story;
  final StoryController storyController;

  const ImageWiget({
    Key? key,
    required this.story,
    required this.storyController,
  }) : super(key: key);

  @override
  State<ImageWiget> createState() => _ImageWigetState();
}

class _ImageWigetState extends State<ImageWiget> {
  Widget getImage(Story story) {
    return CachedNetworkImage(
      imageUrl: story.path,
      errorWidget: (context, url, error) {
        return const Center(
          child: Text(
            'Проверьте интернет соединение',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      progressIndicatorBuilder: (context, url, progress) {
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
      },
      imageBuilder: (context, imageProvider) {
        widget.storyController.play();
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
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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

  @override
  void initState() {
    super.initState();
    widget.storyController.animationController!.duration =
        widget.story.duration ?? const Duration(seconds: 5);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ImageLoad(
    //   imageLoader: ImageLoader(story.path),
    //   story: story,
    //   storyController: storyController,
    // );
    return Container(
      color: Colors.black,
      child: getImage(widget.story),
    );
  }
}

// class ImageLoad extends StatefulWidget {
//   final ImageLoader imageLoader;
//   final StoryController storyController;
//   final Story story;

//   const ImageLoad(
//       {required this.imageLoader,
//       required this.story,
//       required this.storyController,
//       Key? key})
//       : super(key: key);

//   @override
//   _ImageLoadState createState() => _ImageLoadState();
// }

// class _ImageLoadState extends State<ImageLoad> {
//   ui.Image? currentFrame;
//   @override
//   void initState() {
//     super.initState();
//     widget.storyController.animationController!.duration =
//         widget.story.duration ?? const Duration(seconds: 5);
//     widget.storyController.play();
//     widget.imageLoader.loadImage(() async {
//       if (mounted) {
//         if (widget.imageLoader.state == LoadState.success) {
//           widget.storyController.play();
//           forward();
//         } else if (widget.imageLoader.state == LoadState.loading) {
//           setState(() {});
//         } else if (widget.imageLoader.state == LoadState.failure) {
//           setState(() {});
//         }
//       }
//     });
//   }

//   void forward() async {
//     if (widget.storyController.playbackNotifier.valueWrapper!.value ==
//         PlaybackState.pause) {
//       return;
//     }

//     final nextFrame = await widget.imageLoader.frames!.getNextFrame();

//     currentFrame = nextFrame.image;

//     setState(() {});
//   }

//   Widget view(LoadState loadState) {
//     if (loadState == LoadState.loading) {
//       return ClipRRect(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Positioned.fill(
//               child: Image.asset(
//                 widget.story.path,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             BackdropFilter(
//               filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//               ),
//             ),
//             Image.asset(
//               widget.story.path,
//               fit: BoxFit.fitWidth,
//             ),
//           ],
//         ),
//       );
//     }

//     if (loadState == LoadState.failure) {
//       return Container(
//         color: Colors.black,
//         child: const Center(
//           child: Text('Проверьте соединение с интернетом',
//               style: TextStyle(color: Colors.white)),
//         ),
//       );
//     }
//     return Container(
//       color: Colors.black,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return view(widget.imageLoader.state);
//   }
// }

// class ImageLoader {
//   ui.Codec? frames;
//   String url;
//   Map<String, dynamic>? requestHeaders;
//   LoadState state = LoadState.loading;
//   ImageLoader(this.url, {this.requestHeaders});

//   void loadImage(VoidCallback onComplete) {
//     if (frames != null) {
//       state = LoadState.success;
//       onComplete();
//     }

//     final fileStream = DefaultCacheManager()
//         .getFileStream(url, headers: requestHeaders as Map<String, String>?);

//     fileStream.listen(
//       (fileResponse) {
//         if (fileResponse is! FileInfo) return;

//         if (frames != null) {
//           return;
//         }

//         final imageBytes = fileResponse.file.readAsBytesSync();

//         state = LoadState.success;

//         PaintingBinding.instance!.instantiateImageCodec(imageBytes).then(
//             (codec) {
//           frames = codec;
//           onComplete();
//         }, onError: (error) {
//           state = LoadState.failure;
//           onComplete();
//         });
//       },
//       onError: (error) {
//         state = LoadState.failure;
//         onComplete();
//       },
//     );
//   }
// }
