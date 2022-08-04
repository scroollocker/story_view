import 'dart:async';

import 'package:flutter/material.dart';

enum LoadState { loading, success, failure, downloading }

enum PlaybackState {
  init,
  pause,
  play,
  next,
  previous,
  onComplete,
  loading,
  reset,
  wait,
  repeat
}

class StoriesController extends ScrollController {
  int? _currentPage;
  bool? init;
  int? get id => _currentPage;
  VoidCallback? play;
  VoidCallback? pause;
  VoidCallback? next;
  VoidCallback? previous;
  VoidCallback? close;
  VoidCallback? reset;

  void setPage(int value) => _currentPage = value;
}

class StoryController {
  int _id;
  get id => _id;

  StreamController<PlaybackState>? status;
  VoidCallback? pause;
  VoidCallback? play;
  VoidCallback? repeat;
  VoidCallback? next;
  VoidCallback? previous;
  VoidCallback? reset;
  StoryController(this._id);

  void setStory(int value) => _id = value;
}
