import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = await authService.register(
        _nameController.text,
        _usernameController.text,
        _passwordController.text,
      );
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context); // Go back to wrapper (which will see logged in user)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Failed. Username might be taken.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
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
                        onPressed: _register,
                        child: const Text('Register'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
