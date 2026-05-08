import '../db/app_database.dart';
import '../models/note.dart';

class NotesService {
  NotesService({AppDatabase? database})
      : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<List<Note>> loadNotes() async {
    final rows = await _db.readNotes();
    return rows.map(Note.fromMap).toList();
  }

  Future<void> createNote({required String title, required String body}) {
    return _db.insertNote(title: title, body: body);
  }

  Future<void> deleteAllNotes() => _db.deleteAllNotes();
}
