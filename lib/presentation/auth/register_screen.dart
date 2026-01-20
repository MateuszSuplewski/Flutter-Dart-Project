import 'package:flutter/material.dart';
import 'package:flutter_project_app/presentation/home_screen.dart';
import 'package:provider/provider.dart';
import '../../core/auth_provider.dart';
import '../../domain/auth_failures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejestracja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wpisz email';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                  if (!emailRegex.hasMatch(val)) return 'Niepoprawny format email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wpisz hasło';
                  if (val.length < 6) return 'Hasło musi mieć min. 8 znaków';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              authProvider.loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await authProvider.registerEmail(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen())
                                );
                              } on Failure catch (f) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(f.message)),
                                );
                              }
                            }
                          },
                          child: const Text('Zarejestruj'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Masz już konto? Zaloguj się'),
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
