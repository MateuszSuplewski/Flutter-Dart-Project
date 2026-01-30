import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/artifact.dart';
import '../../core/auth_provider.dart';
import '../../domain/repositories/artifact_repository.dart';

class ArtifactDetailsScreen extends StatefulWidget {
  final Artifact artifact;

  const ArtifactDetailsScreen({super.key, required this.artifact});

  @override
  State<ArtifactDetailsScreen> createState() => _ArtifactDetailsScreenState();
}

class _ArtifactDetailsScreenState extends State<ArtifactDetailsScreen> {
  late Artifact _currentArtifact;

  @override
  void initState() {
    super.initState();
    _currentArtifact = widget.artifact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentArtifact.title)),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final isAnonymous = authProvider.currentUser?.isAnonymous ?? true;
          final isAdmin = authProvider.isAdmin;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platforma: ${_currentArtifact.platform}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Data wydania: ${_currentArtifact.releaseDate.toIso8601String().split('T')[0]}',
                ),
                const SizedBox(height: 24),
                if (!isAnonymous) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metadane',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _currentArtifact.metadata.isEmpty
                        ? const Text('Brak metadanych.')
                        : ListView.builder(
                            itemCount: _currentArtifact.metadata.length,
                            itemBuilder: (context, index) {
                              final key = _currentArtifact.metadata.keys
                                  .elementAt(index);
                              final value = _currentArtifact.metadata[key]!;
                              return ListTile(
                                title: Text('$key: $value'),
                                trailing: isAdmin ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showAddEditDialog(
                                        context,
                                        key,
                                        value,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteMetadata(key),
                                    ),
                                  ],
                                ) : null,
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final isAdmin = authProvider.isAdmin;
          if (!isAdmin) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _showAddEditDialog(context, null, null),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Future<void> _deleteMetadata(String key) async {
    final repo = Provider.of<ArtifactRepository>(context, listen: false);
    final newMetadata = Map<String, String>.from(_currentArtifact.metadata);
    newMetadata.remove(key);

    try {
      await repo.updateMetadata(_currentArtifact.id, newMetadata);
      setState(() {
        _currentArtifact = Artifact(
          id: _currentArtifact.id,
          title: _currentArtifact.title,
          platform: _currentArtifact.platform,
          releaseDate: _currentArtifact.releaseDate,
          fileUrl: _currentArtifact.fileUrl,
          metadata: newMetadata,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usunięto metadaną')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    }
  }

  void _showAddEditDialog(
    BuildContext context,
    String? existingKey,
    String? existingValue,
  ) {
    final keyController = TextEditingController(text: existingKey ?? '');
    final valueController = TextEditingController(text: existingValue ?? '');
    final isEditing = existingKey != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edytuj metadaną' : 'Dodaj metadaną'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(labelText: 'Klucz'),
                enabled: !isEditing,
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Wartość'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                final key = keyController.text.trim();
                final value = valueController.text.trim();

                if (key.isNotEmpty && value.isNotEmpty) {
                  final repo = Provider.of<ArtifactRepository>(
                    context,
                    listen: false,
                  );
                  final newMetadata = Map<String, String>.from(
                    _currentArtifact.metadata,
                  );

                  newMetadata[key] = value;

                  try {
                    await repo.updateMetadata(_currentArtifact.id, newMetadata);

                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {
                        _currentArtifact = Artifact(
                          id: _currentArtifact.id,
                          title: _currentArtifact.title,
                          platform: _currentArtifact.platform,
                          releaseDate: _currentArtifact.releaseDate,
                          fileUrl: _currentArtifact.fileUrl,
                          metadata: newMetadata,
                        );
                      });
                    }
                  } catch (e) {
                    // Handle error
                  }
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }
}
