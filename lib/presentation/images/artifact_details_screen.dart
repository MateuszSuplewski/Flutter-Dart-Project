import 'package:flutter/material.dart';
import '../../domain/entities/artifact.dart';

class ArtifactDetailsScreen extends StatelessWidget {
  final Artifact artifact;

  const ArtifactDetailsScreen({super.key, required this.artifact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(artifact.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platforma: ${artifact.platform}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Data wydania: ${artifact.releaseDate.toIso8601String().split('T')[0]}',
            ),
            // Hex Viewer functionality removed
          ],
        ),
      ),
    );
  }
}
