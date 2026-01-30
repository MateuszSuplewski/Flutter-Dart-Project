import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/artifact.dart';

class ArtifactDto {
  final String id;
  final String title;
  final String platform;
  final DateTime releaseDate;
  final String fileUrl;
  final Map<String, String> metadata;
  final String? storagePath;

  ArtifactDto({
    required this.id,
    required this.title,
    required this.platform,
    required this.releaseDate,
    required this.fileUrl,
    required this.metadata,
    this.storagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'platform': platform,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'fileUrl': fileUrl,
      'metadata': metadata,
      if (storagePath != null) 'storagePath': storagePath,
    };
  }

  factory ArtifactDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawMetadata = data['metadata'];
    final Map<String, String> metadataMap = {};

    if (rawMetadata is Map) {
      rawMetadata.forEach((key, value) {
        if (value != null) {
          metadataMap[key.toString()] = value.toString();
        }
      });
    }

    return ArtifactDto(
      id: doc.id,
      title: data['title'] ?? '',
      platform: data['platform'] ?? '',
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'] ?? '',
      metadata: metadataMap,
      storagePath: data['storagePath'] ?? '',
    );
  }

  Artifact toDomain() {
    return Artifact(
      id: id,
      title: title,
      platform: platform,
      releaseDate: releaseDate,
      fileUrl: fileUrl,
      metadata: metadata,
    );
  }
}
