import 'package:flutter/cupertino.dart';
import 'package:stories/src/models/story.dart';

class StoryListen extends ChangeNotifier {
  List<StoryReady> _stories = [];
  int _currentPage = 0;

  StoryListen(this._stories, this._currentPage);

  List<StoryReady> get stories => _stories;
  int get currentPage => _currentPage;

  Duration getCurrentDuration() {
    return stories[_currentPage].duration ?? const Duration(seconds: 5);
  }

  void pageIncrement() {
    _currentPage++;
    for (var element in _stories) {
      if (element.id == currentPage && element.status == StoryStatus.ready) {
        notifyListeners();
        break;
      }
    }
  }

  void pageDecrement() {
    _currentPage--;
    for (var element in _stories) {
      if (element.id == currentPage && element.status == StoryStatus.ready) {
        notifyListeners();
        break;
      }
    }
  }

  void changePage({required int currentPage}) {
    _currentPage = currentPage;
    for (var element in _stories) {
      if (element.id == currentPage && element.status == StoryStatus.ready) {
        notifyListeners();
        break;
      }
    }
  }

  void changeValue(
      {required StoryStatus status, required int id, Duration? duration}) {
    _stories[id].id = id;
    _stories[id].status = status;
    _stories[id].duration = duration;
    if (currentPage == id) {
      notifyListeners();
    }
  }
}
