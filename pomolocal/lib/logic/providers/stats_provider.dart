import 'package:flutter/material.dart';
import 'package:pomolocal/data/models/session_model.dart';
import 'package:pomolocal/data/repositories/session_repository.dart';

class StatsProvider extends ChangeNotifier {
  final SessionRepository _repository;

  List<Session> _todaySessions = [];
  List<Session> _weekSessions = [];

  StatsProvider(this._repository) {
    refresh();
  }

  List<Session> get todaySessions => _todaySessions;
  List<Session> get weekSessions => _weekSessions;

  int get todayFocusCount =>
      _todaySessions.where((s) => s.type == SessionTypeEnum.focus && s.completed).length;

  int get todayFocusMinutes => _todaySessions
      .where((s) => s.type == SessionTypeEnum.focus && s.completed)
      .fold(0, (sum, s) => sum + s.durationMinutes);

  int get weekFocusCount =>
      _weekSessions.where((s) => s.type == SessionTypeEnum.focus && s.completed).length;

  int get weekFocusMinutes => _weekSessions
      .where((s) => s.type == SessionTypeEnum.focus && s.completed)
      .fold(0, (sum, s) => sum + s.durationMinutes);

  /// Returns a map of weekday (1=Mon, 7=Sun) to focus minutes
  Map<int, int> get weeklyBreakdown {
    final map = <int, int>{};
    for (var i = 1; i <= 7; i++) {
      map[i] = 0;
    }
    for (final s in _weekSessions) {
      if (s.type == SessionTypeEnum.focus && s.completed) {
        final day = s.startTime.weekday;
        map[day] = (map[day] ?? 0) + s.durationMinutes;
      }
    }
    return map;
  }

  void refresh() {
    _todaySessions = _repository.getToday();
    _weekSessions = _repository.getWeek();
    notifyListeners();
  }
}
