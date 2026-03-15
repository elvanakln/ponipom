import 'package:hive/hive.dart';
import 'package:pomolocal/core/constants.dart';

class Settings extends HiveObject {
  int focusDuration;
  int shortBreak;
  int longBreak;
  int longBreakInterval;
  bool autoStart;
  bool notificationsEnabled;

  Settings({
    required this.focusDuration,
    required this.shortBreak,
    required this.longBreak,
    required this.longBreakInterval,
    required this.autoStart,
    required this.notificationsEnabled,
  });

  Settings.defaults()
      : focusDuration = AppConstants.defaultFocusDuration,
        shortBreak = AppConstants.defaultShortBreak,
        longBreak = AppConstants.defaultLongBreak,
        longBreakInterval = AppConstants.defaultLongBreakInterval,
        autoStart = false,
        notificationsEnabled = true;

  Map<String, dynamic> toMap() => {
        'focusDuration': focusDuration,
        'shortBreak': shortBreak,
        'longBreak': longBreak,
        'longBreakInterval': longBreakInterval,
        'autoStart': autoStart,
        'notificationsEnabled': notificationsEnabled,
      };

  factory Settings.fromMap(Map<dynamic, dynamic> map) => Settings(
        focusDuration: map['focusDuration'] as int,
        shortBreak: map['shortBreak'] as int,
        longBreak: map['longBreak'] as int,
        longBreakInterval: map['longBreakInterval'] as int,
        autoStart: map['autoStart'] as bool,
        notificationsEnabled: map['notificationsEnabled'] as bool,
      );
}

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final map = reader.readMap();
    return Settings.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeMap(obj.toMap());
  }
}
