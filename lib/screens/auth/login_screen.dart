import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_button.dart';
import '../../routes.dart';

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

      final supabase = Supabase.instance.client;

      // Supabase sign-in
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        setState(() => _error = 'Invalid email or password.');
        return;
      }

      // SUCCESS → Go to home screen
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);

    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Sign-in error: $e');
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

            _loading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      CustomButton(label: 'Sign In', onPressed: _signIn),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.signup),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),

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
