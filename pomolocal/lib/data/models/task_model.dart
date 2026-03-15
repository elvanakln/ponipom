import 'package:hive/hive.dart';

class Task extends HiveObject {
  String id;
  String title;
  String category;
  bool completed;
  int order;
  DateTime createdAt;

  int pomodorosTarget; // hedef pomodoro sayısı
  int pomodorosSpent;  // tamamlanan pomodoro sayısı
  int focusDuration;   // bu görev için odak süresi (dk), 0 = genel ayar
  int shortBreak;      // bu görev için kısa mola (dk), 0 = genel ayar
  int colorValue;      // renk değeri (0 = varsayılan)
  String notes;        // görev notları

  Task({
    String? id,
    required this.title,
    this.category = '',
    this.completed = false,
    this.order = 0,
    this.pomodorosTarget = 4,
    this.pomodorosSpent = 0,
    this.focusDuration = 0,
    this.shortBreak = 0,
    this.colorValue = 0,
    this.notes = '',
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Renk döndürür, 0 ise null (varsayılan kullanılacak)
  int? get taskColor => colorValue != 0 ? colorValue : null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'completed': completed,
        'order': order,
        'pomodorosTarget': pomodorosTarget,
        'pomodorosSpent': pomodorosSpent,
        'focusDuration': focusDuration,
        'shortBreak': shortBreak,
        'colorValue': colorValue,
        'notes': notes,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Task.fromMap(Map<dynamic, dynamic> map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        category: map['category'] as String? ?? '',
        completed: map['completed'] as bool,
        order: map['order'] as int? ?? 0,
        pomodorosTarget: map['pomodorosTarget'] as int? ?? 4,
        pomodorosSpent: map['pomodorosSpent'] as int? ?? 0,
        focusDuration: map['focusDuration'] as int? ?? 0,
        shortBreak: map['shortBreak'] as int? ?? 0,
        colorValue: map['colorValue'] as int? ?? 0,
        notes: map['notes'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final map = reader.readMap();
    return Task.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeMap(obj.toMap());
  }
}

/// Görev renk seçenekleri
class TaskColors {
  TaskColors._();

  static const List<int> presets = [
    0,          // varsayılan (tema rengi)
    0xFFE53935, // kırmızı
    0xFFFF9800, // turuncu
    0xFFFFC107, // sarı
    0xFF43A047, // yeşil
    0xFF1E88E5, // mavi
    0xFF8E24AA, // mor
    0xFFE91E63, // pembe
    0xFF00897B, // teal
    0xFF6D4C41, // kahverengi
  ];

  static const List<String> names = [
    'Varsayılan',
    'Kırmızı',
    'Turuncu',
    'Sarı',
    'Yeşil',
    'Mavi',
    'Mor',
    'Pembe',
    'Teal',
    'Kahverengi',
  ];
}
