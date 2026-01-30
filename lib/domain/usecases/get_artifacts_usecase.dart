import '../../core/usecase.dart';
import '../entities/artifact.dart';
import '../repositories/artifact_repository.dart';

class GetArtifactsUseCase implements UseCase<List<Artifact>, NoParams> {
  final ArtifactRepository repository;

  GetArtifactsUseCase(this.repository);

  @override
  Future<List<Artifact>> call(NoParams params) {
    return repository.getArtifacts();
  }
}
