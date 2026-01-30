import 'package:flutter/material.dart';
import 'package:flutter_project_app/presentation/images/menu_images_screen.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Witaj ${user?.email ?? ""} ${user?.uid ?? ""}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signOut();
              },
              child: const Text('Wyloguj'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ImagesMenu()),
                );
              },
              child: const Text('Repozytorium'),
            ),
          ],
        ),
      ),
    );
  }
}
