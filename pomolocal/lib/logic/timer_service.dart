import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  final VoidCallback onTick;
  final VoidCallback onComplete;

  TimerService({required this.onTick, required this.onComplete});

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _timer?.isActive ?? false;

  void start(int durationMinutes) {
    _remainingSeconds = durationMinutes * 60;
    _resume();
  }

  void _resume() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      onTick();
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        onComplete();
      }
    });
  }

  void pause() {
    _timer?.cancel();
  }

  void resume() {
    if (_remainingSeconds > 0) _resume();
  }

  void reset(int durationMinutes) {
    _timer?.cancel();
    _remainingSeconds = durationMinutes * 60;
    onTick();
  }

  void dispose() {
    _timer?.cancel();
  }
}
