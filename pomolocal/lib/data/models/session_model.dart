import 'package:hive/hive.dart';

class Session extends HiveObject {
  String id;
  DateTime startTime;
  int durationMinutes;
  SessionTypeEnum type;
  bool completed;

  Session({
    String? id,
    required this.startTime,
    required this.durationMinutes,
    required this.type,
    required this.completed,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() => {
        'id': id,
        'startTime': startTime.millisecondsSinceEpoch,
        'durationMinutes': durationMinutes,
        'type': type.index,
        'completed': completed,
      };

  factory Session.fromMap(Map<dynamic, dynamic> map) => Session(
        id: map['id'] as String,
        startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
        durationMinutes: map['durationMinutes'] as int,
        type: SessionTypeEnum.values[map['type'] as int],
        completed: map['completed'] as bool,
      );
}

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 0;

  @override
  Session read(BinaryReader reader) {
    final map = reader.readMap();
    return Session.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer.writeMap(obj.toMap());
  }
}

enum SessionTypeEnum {
  focus,
  shortBreak,
  longBreak,
}
