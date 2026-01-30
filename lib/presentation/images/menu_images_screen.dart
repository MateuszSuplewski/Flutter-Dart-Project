import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project_app/core/auth_provider.dart';
import 'package:provider/provider.dart';
import 'upload_images_screen.dart';
import 'artifact_list_screen.dart';

class ImagesMenu extends StatelessWidget {
  const ImagesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu obrazów')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDesktop && isAdmin)
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Prześlij nowy obraz'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UploadImagesScreen(),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Lista Artefaktów'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ArtifactListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
