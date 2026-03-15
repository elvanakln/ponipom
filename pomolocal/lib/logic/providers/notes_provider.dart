import 'package:flutter/material.dart';
import 'package:pomolocal/data/models/note_model.dart';
import 'package:pomolocal/data/repositories/note_repository.dart';

class NotesProvider extends ChangeNotifier {
  final NoteRepository _repository;

  DateTime _selectedDate = DateTime.now();
  List<Note> _notesForDate = [];
  Set<String> _datesWithNotes = {};

  NotesProvider(this._repository) {
    refresh();
  }

  DateTime get selectedDate => _selectedDate;
  List<Note> get notesForDate => _notesForDate;
  Set<String> get datesWithNotes => _datesWithNotes;

  void selectDate(DateTime date) {
    _selectedDate = date;
    _notesForDate = _repository.getByDate(date);
    notifyListeners();
  }

  Future<void> addNote(String content, {DateTime? date}) async {
    final note = Note(
      date: date ?? _selectedDate,
      content: content,
    );
    await _repository.save(note);
    refresh();
  }

  Future<void> updateNote(Note note, String newContent) async {
    note.content = newContent;
    await _repository.update(note);
    refresh();
  }

  Future<void> deleteNote(String id) async {
    await _repository.delete(id);
    refresh();
  }

  void refresh() {
    _notesForDate = _repository.getByDate(_selectedDate);
    _datesWithNotes = _repository.getDatesWithNotes();
    notifyListeners();
  }
}
