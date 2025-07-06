import '../entities/note.dart';

abstract class NoteRepository {
  /// Fetch all notes for the current user, ordered by updatedAt descending.
  Future<List<Note>> fetchNotes();

  /// Add a new note for the current user.
  Future<void> addNote(String text);

  /// Update a note by ID for the current user.
  Future<void> updateNote(String id, String text);

  /// Delete a note by ID for the current user.
  Future<void> deleteNote(String id);
}
