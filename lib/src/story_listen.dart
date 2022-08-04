import 'package:flutter/cupertino.dart';
import 'package:stories/src/models/story_process.dart';
import 'package:stories/src/models/story_ready.dart';
import 'package:stories/stories.dart';

class StoryListen extends ChangeNotifier {
  List<StoryReady> _stories = [];
  int _currentStory = 0;

  bool mounted = true;

  StoryListen(this._stories, this._currentStory);

  List<StoryReady> get stories => _stories;
  int get currentStory => _currentStory;

  StoryStatus get currentStatus => stories[currentStory].status;
  MediaType get mediaType => _stories[currentStory].story.meadiaType;

  Duration getCurrentDuration() {
    return stories[_currentStory].duration ?? const Duration(seconds: 5);
  }

  void pageIncrement() {
    if (!mounted) return;
    _currentStory++;
    for (var element in _stories) {
      if (element.id == currentStory && currentStatus == StoryStatus.complete) {
        // print('COMPLETE LISTEN ${currentStatus}');
        notifyListeners();
        break;
      }
    }
  }

  void pageDecrement() {
    if (!mounted) return;
    _currentStory--;
    for (var element in _stories) {
      if (element.id == currentStory && currentStatus == StoryStatus.complete) {
        notifyListeners();
        break;
      }
    }
  }

  void changePage({required int id}) {
    if (!mounted) return;
    _currentStory = id;
    for (var element in _stories) {
      if (element.id == currentStory && currentStatus == StoryStatus.complete) {
        notifyListeners();
        break;
      }
    }
  }

  void changeValue(
      {required StoryStatus status, required int id, Duration? duration}) {
    if (!mounted) return;
    if (_stories[id].status != status) {
      _stories[id].id = id;
      _stories[id].status = status;
      _stories[id].duration = duration ?? _stories[id].duration;
      if (currentStory == id) {
        notifyListeners();
      }
    }
  }

  void dis() {
    mounted = false;
    dispose();
  }
}
