import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_button.dart';
import '../../routes.dart';
import '../../services/local_storage.dart';
import '../../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _email.text.trim();
      final password = _password.text;

      if (email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Please enter email and password.');
        return;
      }

      // Access Supabase service
      final supa = Provider.of<SupabaseService>(context, listen: false);
      final res = await supa.signIn(email, password);

      if (res.user == null || res.user!.id.isEmpty) {
        setState(() => _error = 'Invalid credentials.');
        return;
      }

      // Save user ID locally
      await LocalStorage.saveUserId(res.user!.id);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() => _error = 'Sign in error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InputField(controller: _email, label: 'Email'),
            const SizedBox(height: 12),
            InputField(controller: _password, label: 'Password', obscure: true),
            const SizedBox(height: 16),
            
            if (_loading)
              const CircularProgressIndicator()
            else ...[
              CustomButton(label: 'Sign In', onPressed: _signIn),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.signup),
                child: const Text('Create account'),
              ),
            ],

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
