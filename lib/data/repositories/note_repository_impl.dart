import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteRepositoryImpl implements NoteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NoteRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('notes');

  @override
  Future<List<Note>> fetchNotes() async {
    if (_userId == null) return [];
    final query = await _notesCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('updatedAt', descending: true)
        .get();
    return query.docs
        .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addNote(String text) async {
    print('addNote called, userId=$_userId');
    if (_userId == null) throw Exception('User not authenticated');
    final now = DateTime.now();
    try {
      await _notesCollection.add({
        'text': text,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'userId': _userId,
      });
      print('Note added successfully');
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateNote(String id, String text) async {
    if (_userId == null) return;
    await _notesCollection.doc(id).update({
      'text': text,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deleteNote(String id) async {
    if (_userId == null) return;
    await _notesCollection.doc(id).delete();
  }
}
