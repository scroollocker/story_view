import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stories/src/models/story.dart';

enum LoadState { loading, success, failure }

enum PlaybackState { pause, play, next, previous, onComplete, loading }

class StoriesController extends ScrollController {
  PageController pageController;
  List<StoryController> storyControllers;
  StoriesController(
      {required this.pageController, required this.storyControllers});

  double? get currentPage {
    return pageController.page;
  }

  Future<PlaybackState> currentState(StoryController storyController) {
    return storyController.playbackNotifier.last;
  }

  // void pageInit() {
  //   storyControllers[pageController.page!.toInt()];
  // }

  // void checkRoll() {
  //   double page = currentPage!;
  //   int pageInt = page.toInt();
  //   if (page % 1 != 0) {
  //     try {
  //       storyControllers[pageInt].pause();
  //       storyControllers[pageInt + 1].pause();
  //     } catch (error) {}
  //   } else {
  //     try {
  //       storyControllers[pageInt].play();
  //       storyControllers[pageInt + 1].play();
  //     } catch (error) {}
  //   }
  // }

  void pause(int index) {
    storyControllers[index].pause();
  }

  void play(int index) {
    storyControllers[index].play();
  }

  void next(int index) {
    storyControllers[index].next();
  }

  void previous(int index) {
    storyControllers[index].previous();
  }
}

class StoryController {
  BehaviorSubject<PlaybackState> playbackNotifier =
      BehaviorSubject<PlaybackState>();
  List<Story>? stories;
  AnimationController? animationController;
  PageController? pageController;
  ValueNotifier<int> currentPage = ValueNotifier<int>(0);

  void animComplete(bool isRepeat) {
    animReset();
    if (currentPage.value + 1 < stories!.length) {
      currentPage.value += 1;
      playbackNotifier.add(PlaybackState.play);
    } else {
      if (isRepeat) {
        currentPage.value = 0;
        playbackNotifier.add(PlaybackState.play);
        return;
      }
      playbackNotifier.add(PlaybackState.onComplete);
    }
  }

  void animReset() {
    animationController!.stop();
    animationController!.reset();
  }

  void setDuration(Duration duration) {
    animationController!.duration = duration;
  }

  void pause() {
    playbackNotifier.add(PlaybackState.pause);
    animationController!.stop();
  }

  void play() {
    playbackNotifier.add(PlaybackState.play);
    animationController!.forward();
  }

  void next() {
    animReset();

    if (currentPage.value + 1 < stories!.length) {
      currentPage.value += 1;
    } else {
      playbackNotifier.add(PlaybackState.onComplete);
    }

    playbackNotifier.add(PlaybackState.next);
  }

  void previous() {
    animationController!.stop();
    animationController!.reset();
    if (currentPage.value - 1 >= 0) {
      currentPage.value -= 1;
    }
    if (stories![currentPage.value].meadiaType == MediaType.video) {}
    playbackNotifier.add(PlaybackState.previous);
    play();
  }

  void dispose() {
    animationController!.dispose();
    pageController!.dispose();
    currentPage.dispose();
    playbackNotifier.close();
  }
}
