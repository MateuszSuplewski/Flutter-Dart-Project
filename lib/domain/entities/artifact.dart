class Artifact {
  final String id;
  final String title;
  final String platform;
  final DateTime releaseDate;
  final String fileUrl;
  final String? checksum;
  final int? sizeBytes;

  Artifact({
    required this.id,
    required this.title,
    required this.platform,
    required this.releaseDate,
    required this.fileUrl,
    this.checksum,
    this.sizeBytes,
  });
}
