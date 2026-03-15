import 'package:hive/hive.dart';
import 'package:pomolocal/data/models/session_model.dart';

class SessionRepository {
  final Box<Session> _box;

  SessionRepository(this._box);

  Future<void> save(Session session) async {
    await _box.put(session.id, session);
  }

  List<Session> getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _box.values
        .where((s) =>
            s.startTime.isAfter(startOfDay) && s.startTime.isBefore(endOfDay))
        .toList();
  }

  List<Session> getWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return _box.values.where((s) => s.startTime.isAfter(start)).toList();
  }

  List<Session> getAll() {
    return _box.values.toList();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
