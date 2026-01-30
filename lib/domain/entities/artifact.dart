class Artifact {
  final String id;
  final String title;
  final String platform;
  final DateTime releaseDate;
  final String fileUrl;
  final Map<String, String> metadata;

  Artifact({
    required this.id,
    required this.title,
    required this.platform,
    required this.releaseDate,
    required this.fileUrl,
    required this.metadata,
  });

  String? get checksum => metadata['checksum'];
  int? get sizeBytes {
    final val = metadata['sizeBytes'];
    if (val == null) return null;
    return int.tryParse(val);
  }
}
