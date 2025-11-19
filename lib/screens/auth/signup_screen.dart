import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_button.dart';
import '../../routes.dart';
import '../../services/local_storage.dart';
import '../../services/supabase_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _email.text.trim();
      final password = _password.text;

      if (email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Please fill all fields.');
        return;
      }

      // Access SupabaseService through Provider
      final supa = Provider.of<SupabaseService>(context, listen: false);

      final res = await supa.signUp(email, password);

      if (res.user == null || res.user!.id.isEmpty) {
        setState(() => _error = 'Sign up failed. Try another email.');
        return;
      }

      // Save Supabase user ID locally
      await LocalStorage.saveUserId(res.user!.id);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() => _error = 'Sign up error: $e');
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
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InputField(controller: _email, label: 'Email'),
            const SizedBox(height: 12),
            InputField(controller: _password, label: 'Password', obscure: true),
            const SizedBox(height: 16),

            _loading
                ? const CircularProgressIndicator()
                : CustomButton(label: 'Create account', onPressed: _signUp),

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
