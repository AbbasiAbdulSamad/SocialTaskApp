import 'dart:async';
import 'package:flutter/material.dart';

class TaskTimerProvider extends ChangeNotifier {
  int _secondsLeft = 0;
  Timer? _timer;
  Timer? _startDelayTimer;

  int get secondsLeft => _secondsLeft;

  void start(int seconds) {
    // Cancel any existing timers
    _timer?.cancel();
    _startDelayTimer?.cancel();

    _secondsLeft = seconds;
    notifyListeners();

    // ⏳ 2 second delay before countdown starts
    _startDelayTimer = Timer(const Duration(milliseconds: 1500), () {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft <= 0) {
          t.cancel();
          _secondsLeft = 0;
          notifyListeners();
        } else {
          _secondsLeft--;
          notifyListeners();
        }
      });
    });
  }

  void pause() {
    _timer?.cancel();
    _startDelayTimer?.cancel();
  }

  void resume() {
    if (_secondsLeft > 0) {
      start(_secondsLeft); // resume also respects 2 sec delay
    }
  }

  void cancel() {
    _timer?.cancel();
    _startDelayTimer?.cancel();
    _secondsLeft = 0;
    notifyListeners();
  }
}
