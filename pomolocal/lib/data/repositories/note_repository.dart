import 'package:hive/hive.dart';
import 'package:pomolocal/data/models/note_model.dart';

class NoteRepository {
  final Box<Note> _box;

  NoteRepository(this._box);

  Future<void> save(Note note) async {
    await _box.put(note.id, note);
  }

  List<Note> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Note> getByDate(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _box.values.where((n) => n.dateKey == key).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns dates that have at least one note
  Set<String> getDatesWithNotes() {
    return _box.values.map((n) => n.dateKey).toSet();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> update(Note note) async {
    await _box.put(note.id, note);
  }
}
