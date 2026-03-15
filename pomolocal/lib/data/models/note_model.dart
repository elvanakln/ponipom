import 'package:hive/hive.dart';

class Note extends HiveObject {
  String id;
  DateTime date;
  String content;
  DateTime createdAt;

  Note({
    String? id,
    required this.date,
    required this.content,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Date key for grouping (yyyy-MM-dd)
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'content': content,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Note.fromMap(Map<dynamic, dynamic> map) => Note(
        id: map['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        content: map['content'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 2;

  @override
  Note read(BinaryReader reader) {
    final map = reader.readMap();
    return Note.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeMap(obj.toMap());
  }
}
