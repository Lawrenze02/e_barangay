import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = await authService.login(
        _usernameController.text,
        _passwordController.text,
      );
      setState(() => _isLoading = false);

      if (success) {
         // Navigation is handled by AuthWrapper in main.dart, but we might need to pop or ensure state updates
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Credentials')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('eBarangay Scheduler', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                      ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Create an Account'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
