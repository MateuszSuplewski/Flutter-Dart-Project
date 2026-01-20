import 'package:flutter/material.dart';
import 'package:flutter_project_app/presentation/auth/register_screen.dart';
import 'package:provider/provider.dart';
import '../../core/auth_provider.dart';
import '../../domain/auth_failures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                                await authProvider.loginEmail(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim());
                              } on Failure catch (f) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(f.message)),
                                );
                              }
                            }
                          },
                          child: const Text('Zaloguj'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await authProvider.loginAnonymous();
                            } on Failure catch (f) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(f.message)),
                              );
                            }
                          },
                          child: const Text('Wejdź jako Gość'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen())
                            );
                          },
                          child: const Text('Utwórz nowe konto'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
