import 'dart:io';
import '../../core/usecase.dart';
import '../repositories/artifact_repository.dart';

class UploadArtifactUseCase implements UseCase<void, UploadArtifactParams> {
  final ArtifactRepository repository;

  UploadArtifactUseCase(this.repository);

  @override
  Future<void> call(UploadArtifactParams params) {
    return repository.uploadArtifact(
      title: params.title,
      platform: params.platform,
      releaseDate: params.releaseDate,
      file: params.file,
      onProgress: params.onProgress,
    );
  }
}

class UploadArtifactParams {
  final String title;
  final String platform;
  final DateTime releaseDate;
  final File file;
  final Function(double)? onProgress;

  UploadArtifactParams({
    required this.title,
    required this.platform,
    required this.releaseDate,
    required this.file,
    this.onProgress,
  });
}
