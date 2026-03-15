import 'package:flutter/material.dart';
import 'package:pomolocal/core/enums.dart';
import 'package:pomolocal/core/theme.dart';
import 'package:pomolocal/data/models/settings_model.dart';
import 'package:pomolocal/data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  late Settings _settings;

  SettingsProvider(this._repository) {
    _settings = _repository.get();
  }

  Settings get settings => _settings;

  int get focusDuration => _settings.focusDuration;
  int get shortBreak => _settings.shortBreak;
  int get longBreak => _settings.longBreak;
  int get longBreakInterval => _settings.longBreakInterval;
  bool get autoStart => _settings.autoStart;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  AppThemeMode get themeMode => AppThemeMode.values[_settings.themeMode];
  TimerDisplayStyle get timerDisplayStyle =>
      TimerDisplayStyle.values[_settings.timerDisplayStyle];

  Future<void> update({
    int? focusDuration,
    int? shortBreak,
    int? longBreak,
    int? longBreakInterval,
    bool? autoStart,
    bool? notificationsEnabled,
    AppThemeMode? themeMode,
    TimerDisplayStyle? timerDisplayStyle,
  }) async {
    _settings.focusDuration = focusDuration ?? _settings.focusDuration;
    _settings.shortBreak = shortBreak ?? _settings.shortBreak;
    _settings.longBreak = longBreak ?? _settings.longBreak;
    _settings.longBreakInterval = longBreakInterval ?? _settings.longBreakInterval;
    _settings.autoStart = autoStart ?? _settings.autoStart;
    _settings.notificationsEnabled = notificationsEnabled ?? _settings.notificationsEnabled;
    if (themeMode != null) _settings.themeMode = themeMode.index;
    if (timerDisplayStyle != null) {
      _settings.timerDisplayStyle = timerDisplayStyle.index;
    }

    await _repository.save(_settings);
    notifyListeners();
  }
}
