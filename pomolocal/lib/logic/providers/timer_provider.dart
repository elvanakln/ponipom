import 'package:flutter/material.dart';
import 'package:pomolocal/core/constants.dart';
import 'package:pomolocal/core/enums.dart';
import 'package:pomolocal/data/models/session_model.dart';
import 'package:pomolocal/data/models/task_model.dart';
import 'package:pomolocal/data/repositories/session_repository.dart';
import 'package:pomolocal/logic/timer_service.dart';

class TimerProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  late TimerService _timerService;

  TimerState _state = TimerState.idle;
  SessionType _sessionType = SessionType.focus;
  int _completedPomodoros = 0;

  int _focusDuration = AppConstants.defaultFocusDuration;
  int _shortBreak = AppConstants.defaultShortBreak;
  int _longBreak = AppConstants.defaultLongBreak;
  int _longBreakInterval = AppConstants.defaultLongBreakInterval;
  bool _autoStart = false;

  // Aktif görevin kendi süreleri (0 = genel ayarı kullan)
  int _taskFocusDuration = 0;
  int _taskShortBreak = 0;

  VoidCallback? onFocusComplete;

  TimerProvider(this._sessionRepository) {
    _timerService = TimerService(
      onTick: () => notifyListeners(),
      onComplete: _onTimerComplete,
    );
  }

  TimerState get state => _state;
  SessionType get sessionType => _sessionType;
  int get completedPomodoros => _completedPomodoros;
  int get remainingSeconds => _timerService.remainingSeconds;

  /// Aktif odak süresi (görev özel veya genel)
  int get effectiveFocusDuration =>
      _taskFocusDuration > 0 ? _taskFocusDuration : _focusDuration;

  int get effectiveShortBreak =>
      _taskShortBreak > 0 ? _taskShortBreak : _shortBreak;

  int get totalSeconds {
    switch (_sessionType) {
      case SessionType.focus:
        return effectiveFocusDuration * 60;
      case SessionType.shortBreak:
        return effectiveShortBreak * 60;
      case SessionType.longBreak:
        return _longBreak * 60;
    }
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    if (_state == TimerState.idle) return 1.0;
    return remainingSeconds / totalSeconds;
  }

  String get timeDisplay {
    final seconds = _state == TimerState.idle ? totalSeconds : remainingSeconds;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get currentColor {
    switch (_sessionType) {
      case SessionType.focus:
        return AppConstants.focusColor;
      case SessionType.shortBreak:
        return AppConstants.shortBreakColor;
      case SessionType.longBreak:
        return AppConstants.longBreakColor;
    }
  }

  String get currentLabel {
    switch (_sessionType) {
      case SessionType.focus:
        return AppConstants.focusLabel;
      case SessionType.shortBreak:
        return AppConstants.shortBreakLabel;
      case SessionType.longBreak:
        return AppConstants.longBreakLabel;
    }
  }

  void updateSettings({
    required int focusDuration,
    required int shortBreak,
    required int longBreak,
    required int longBreakInterval,
    required bool autoStart,
  }) {
    _focusDuration = focusDuration;
    _shortBreak = shortBreak;
    _longBreak = longBreak;
    _longBreakInterval = longBreakInterval;
    _autoStart = autoStart;

    if (_state == TimerState.idle) {
      notifyListeners();
    }
  }

  /// Aktif görev değiştiğinde çağrılır
  void setActiveTaskDurations(Task? task) {
    _taskFocusDuration = task?.focusDuration ?? 0;
    _taskShortBreak = task?.shortBreak ?? 0;
    if (_state == TimerState.idle) {
      notifyListeners();
    }
  }

  void start() {
    final duration = _getDurationForType(_sessionType);
    _timerService.start(duration);
    _state = TimerState.running;
    notifyListeners();
  }

  void pause() {
    _timerService.pause();
    _state = TimerState.paused;
    notifyListeners();
  }

  void resume() {
    _timerService.resume();
    _state = TimerState.running;
    notifyListeners();
  }

  void reset() {
    final duration = _getDurationForType(_sessionType);
    _timerService.reset(duration);
    _state = TimerState.idle;
    notifyListeners();
  }

  void skipToNext() {
    _timerService.pause();
    _moveToNextSession();
  }

  void _onTimerComplete() {
    final completedType = _sessionType;

    final session = Session(
      startTime: DateTime.now().subtract(
        Duration(minutes: _getDurationForType(completedType)),
      ),
      durationMinutes: _getDurationForType(completedType),
      type: _toSessionTypeEnum(completedType),
      completed: true,
    );
    _sessionRepository.save(session);

    if (completedType == SessionType.focus) {
      _completedPomodoros++;
      onFocusComplete?.call();
    }

    _moveToNextSession();

    if (_autoStart) {
      start();
    }
  }

  void _moveToNextSession() {
    if (_sessionType == SessionType.focus) {
      if (_completedPomodoros > 0 &&
          _completedPomodoros % _longBreakInterval == 0) {
        _sessionType = SessionType.longBreak;
      } else {
        _sessionType = SessionType.shortBreak;
      }
    } else {
      _sessionType = SessionType.focus;
    }

    _state = TimerState.idle;
    notifyListeners();
  }

  int _getDurationForType(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return effectiveFocusDuration;
      case SessionType.shortBreak:
        return effectiveShortBreak;
      case SessionType.longBreak:
        return _longBreak;
    }
  }

  SessionTypeEnum _toSessionTypeEnum(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return SessionTypeEnum.focus;
      case SessionType.shortBreak:
        return SessionTypeEnum.shortBreak;
      case SessionType.longBreak:
        return SessionTypeEnum.longBreak;
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
}
