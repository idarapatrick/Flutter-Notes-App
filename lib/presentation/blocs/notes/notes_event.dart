import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

class FetchNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final String text;
  const AddNote(this.text);
  @override
  List<Object?> get props => [text];
}

class UpdateNote extends NotesEvent {
  final String id;
  final String text;
  const UpdateNote({required this.id, required this.text});
  @override
  List<Object?> get props => [id, text];
}

class DeleteNote extends NotesEvent {
  final String id;
  const DeleteNote(this.id);
  @override
  List<Object?> get props => [id];
}
