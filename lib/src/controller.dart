import 'dart:async';

import 'package:flutter/material.dart';

enum LoadState { loading, success, failure }

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
  int? _initialPage;
  bool? init;
  get initPage => _initialPage;
  VoidCallback? play;
  VoidCallback? pause;
  VoidCallback? next;
  VoidCallback? previous;
  VoidCallback? close;
  VoidCallback? reset;
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

  void setId(int value) {
    _id = value;
  }
}
