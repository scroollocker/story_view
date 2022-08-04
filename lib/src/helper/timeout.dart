import 'dart:async';
import 'package:flutter/cupertino.dart';

class TimeoutListen extends ChangeNotifier {
  final int _timeout;
  Timer? _timer;
  int _value = 20;

  TimeoutListen(this._timeout);

  int get timeout => _timeout;
  int get value => _value;

  void startTimer() {
    _timer = _initTimer();
  }

  void restartTimer() {
    cancel();
    _timer = _initTimer();
  }

  void cancel() {
    _timer?.cancel();
  }

  Timer _initTimer() {
    return Timer.periodic(Duration(seconds: _timeout), (timer) {
      if (timer.tick == _timeout) {
        notifyListeners();
        cancel();
      } else {
        _value = _timeout - timer.tick;
      }
    });
  }
}
