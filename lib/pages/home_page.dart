import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../models/note.dart';
import '../navigation/app_routes.dart';
import '../services/notes_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _notesService = NotesService();
  bool _loading = true;
  Object? _error;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    if (AppDatabase.instance.sessionUserId == null) {
      _loading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return;
    }
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notes = await _notesService.loadNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).pushNamed(AppRoutes.create);
    if (mounted) _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    if (AppDatabase.instance.sessionUserId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Notas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              AppDatabase.instance.signOut();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Limpar',
            onPressed: () async {
              await _notesService.deleteAllNotes();
              if (mounted) _loadNotes();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('$_error'));
    }
    if (_notes.isEmpty) {
      return const Center(
        child: Text('Nenhuma nota encontrada.'),
      );
    }

    final metaStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = _notes[index];
          final createdAt = note.createdAt;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.body,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Criado em: ${createdAt.toLocal().toString().split('.').first}',
                    style: metaStyle?.copyWith(fontSize: 12) ??
                        const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
