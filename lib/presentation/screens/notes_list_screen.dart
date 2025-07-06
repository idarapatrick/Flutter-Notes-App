import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../blocs/notes/notes_bloc.dart';
import '../blocs/notes/notes_event.dart';
import '../blocs/notes/notes_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/theme/theme_cubit.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesError) {
          // Also show a SnackBar for immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('My Notes'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'theme') {
                    final cubit = context.read<ThemeCubit>();
                    final mode = cubit.state;
                    cubit.setTheme(
                      mode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    );
                  } else if (value == 'profile') {
                    Navigator.of(context).pushNamed('/profile');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'theme',
                    child: Text('Toggle Theme'),
                  ),
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile/Settings'),
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                ),
                if (state is NotesError) ...[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      color: Colors.red[50],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SelectableText(
                          state.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddNoteDialog(context),
            tooltip: 'Add Note',
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotesState state) {
    if (state is NotesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is NotesEmpty) {
      return const Center(
        child: Text(
          'Nothing here yet—tap ➕ to add a note.',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (state is NotesLoaded) {
      final filteredNotes = _searchQuery.isEmpty
          ? state.notes
          : state.notes
                .where(
                  (note) => note.text.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return _buildNoteCard(context, note);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(
          note.text.length > 100
              ? note.text.substring(0, 100) + '...'
              : note.text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Last updated: ${note.updatedAt.toLocal().toString().substring(0, 16)}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        onTap: () => _showNoteDetailDialog(context, note),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Edit',
              onPressed: () => _showEditNoteDialog(context, note),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _showDeleteDialog(context, note),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    final notesBloc = context.read<NotesBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: notesBloc,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Add Note',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
            width: 300,
            child: TextField(
              controller: controller,
              autofocus: true,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                hintText: 'Type your note here...',
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  dialogContext.read<NotesBloc>().add(
                    AddNote(controller.text.trim()),
                  );
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    final controller = TextEditingController(text: note.text);
    final notesBloc = context.read<NotesBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: notesBloc,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Edit Note',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Edit your note...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  dialogContext.read<NotesBloc>().add(
                    UpdateNote(id: note.id, text: controller.text.trim()),
                  );
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Note', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () {
              context.read<NotesBloc>().add(DeleteNote(note.id));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showNoteDetailDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Note',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              note.text,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
