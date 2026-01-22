import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/artifact.dart';

class ArtifactDto {
  final String id;
  final String title;
  final String platform;
  final DateTime releaseDate;
  final String fileUrl;
  final String? checksum;
  final int? sizeBytes;
  final String? storagePath;

  ArtifactDto({
    required this.id,
    required this.title,
    required this.platform,
    required this.releaseDate,
    required this.fileUrl,
    this.checksum,
    this.sizeBytes,
    this.storagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'platform': platform,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'fileUrl': fileUrl,
      if (checksum != null) 'checksum': checksum,
      if (sizeBytes != null) 'sizeBytes': sizeBytes,
      if (storagePath != null) 'storagePath': storagePath,
    };
  }

  factory ArtifactDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final metadata = data['metadata'] as Map<String, dynamic>?;

    return ArtifactDto(
      id: doc.id,
      title: data['title'] ?? '',
      platform: data['platform'] ?? '',
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'] ?? '',
      checksum: metadata?['checksum'] ?? '',
      sizeBytes: metadata?['sizeBytes'] ?? '',
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
      checksum: checksum,
      sizeBytes: sizeBytes,
    );
  }
}
