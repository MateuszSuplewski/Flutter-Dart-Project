import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../domain/repositories/artifact_repository.dart';
import '../data/repositories/firebase_artifact_repository.dart';

class ArtifactProvider extends StatelessWidget {
  final Widget child;
  const ArtifactProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Provider<ArtifactRepository>(create: (_) => FirebaseArtifactRepository(), child: child);
  }
}