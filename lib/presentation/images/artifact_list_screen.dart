import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/artifact_repository.dart';
import '../../domain/usecases/get_artifacts_usecase.dart';
import '../../core/usecase.dart';
import '../../domain/entities/artifact.dart';
import 'artifact_details_screen.dart';

class ArtifactListScreen extends StatefulWidget {
  const ArtifactListScreen({super.key});

  @override
  State<ArtifactListScreen> createState() => _ArtifactListScreenState();
}

class _ArtifactListScreenState extends State<ArtifactListScreen> {
  late Future<List<Artifact>> _artifactsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArtifacts();
  }

  void _loadArtifacts() {
    final repository = Provider.of<ArtifactRepository>(context, listen: false);
    final getArtifactsUseCase = GetArtifactsUseCase(repository);
    setState(() {
      _artifactsFuture = getArtifactsUseCase(NoParams());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Artefaktów'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadArtifacts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Odświeżanie listy...')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Artifact>>(
        future: _artifactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak artefaktów.'));
          }

          final artifacts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _loadArtifacts();
            },
            child: ListView.builder(
              itemCount: artifacts.length,
              itemBuilder: (context, index) {
                final artifact = artifacts[index];
                return ListTile(
                  title: Text(artifact.title),
                  subtitle: Text(artifact.platform),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ArtifactDetailsScreen(artifact: artifact),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
