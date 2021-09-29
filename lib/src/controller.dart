import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';

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

  void checkRoll() {
    double page = currentPage!;
    int pageInt = page.toInt();
    if (page % 1 != 0) {
      storyControllers[pageInt].pause();
      try {
        storyControllers[pageInt + 1].pause();
      } catch (error) {}
    } else {
      storyControllers[pageInt].play();
      try {
        storyControllers[pageInt + 1].play();
      } catch (error) {}
    }
  }

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
