import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../../domain/repositories/artifact_repository.dart';
import '../../domain/entities/artifact.dart';
import '../dtos/artifact_dto.dart';

class FirebaseArtifactRepository implements ArtifactRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseArtifactRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> uploadArtifact({
    required String title,
    required String platform,
    required DateTime releaseDate,
    required File file,
    Function(double)? onProgress,
  }) async {
    final String uuid = const Uuid().v4();
    final String extension = p.extension(file.path);
    final String fileName = '$uuid$extension';
    final Reference storageRef = _storage.ref().child('raw_images/$fileName');
    final UploadTask uploadTask = storageRef.putFile(file);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
    }

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    await _firestore.collection('artifacts').add({
      'title': title,
      'platform': platform,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'fileUrl': downloadUrl,
      'storagePath': 'raw_images/$fileName',
    });
  }

  @override
  Future<List<Artifact>> getArtifacts() async {
    final snapshot = await _firestore.collection('artifacts').get();
    return snapshot.docs
        .map((doc) => ArtifactDto.fromFirestore(doc).toDomain())
        .toList();
  }
}
