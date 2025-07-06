import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_event.dart';
import 'notes_state.dart';
import '../../../domain/repositories/note_repository.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository noteRepository;

  NotesBloc({required this.noteRepository}) : super(NotesInitial()) {
    on<FetchNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        final notes = await noteRepository.fetchNotes();
        if (notes.isEmpty) {
          emit(NotesEmpty());
        } else {
          emit(NotesLoaded(notes));
        }
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<AddNote>((event, emit) async {
      try {
        await noteRepository.addNote(event.text);
        add(FetchNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<UpdateNote>((event, emit) async {
      try {
        await noteRepository.updateNote(event.id, event.text);
        add(FetchNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });

    on<DeleteNote>((event, emit) async {
      try {
        await noteRepository.deleteNote(event.id);
        add(FetchNotes());
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    });
  }
}
