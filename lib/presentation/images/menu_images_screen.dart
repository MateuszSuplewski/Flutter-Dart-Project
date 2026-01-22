import 'dart:io';
import 'package:flutter/material.dart';
import 'upload_images_screen.dart';

class ImagesMenu extends StatelessWidget {
  const ImagesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu obrazów')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDesktop)
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
            const Text('Placeholder...'),
          ],
        ),
      ),
    );
  }
}
