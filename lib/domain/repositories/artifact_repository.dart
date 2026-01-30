import 'dart:io';
import '../entities/artifact.dart';

abstract class ArtifactRepository {
  Future<void> uploadArtifact({
    required String title,
    required String platform,
    required DateTime releaseDate,
    required File file,
    Function(double)? onProgress,
  });

  Future<List<Artifact>> getArtifacts();
}
