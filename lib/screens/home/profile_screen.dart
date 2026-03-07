import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/language_provider.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient client = Supabase.instance.client;

  User? user;
  bool isLoading = true;
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    _loadUser();

    _authSub = client.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (!mounted) return;

      setState(() {
        user = session?.user;
        isLoading = false;
      });

      if (session == null) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  Future<void> _loadUser() async {
    final session = client.auth.currentSession;

    setState(() {
      user = session?.user;
      isLoading = false;
    });

    if (session == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(loc.text('no_user_session'))),
      );
    }

    final metadata = user!.userMetadata ?? {};
    final fullName = metadata['full_name'] ?? loc.text('no_name_set');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 251, 252),
      appBar: AppBar(
        title: Text(loc.text('profile')),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 251, 251, 252),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          // 🌍 Language Switch Button
         IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final provider =
                  Provider.of<LanguageProvider>(context, listen: false);

              if (provider.locale.languageCode == 'en') {
                provider.changeLanguage('ar');
              } else {
                provider.changeLanguage('en');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[300],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _infoCard(loc.text('full_name'), fullName, Icons.person),
            _infoCard(
              loc.text('email'),
              user!.email ?? loc.text('no_email'),
              Icons.email,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _changePasswordDialog,
              icon: const Icon(Icons.lock_reset),
              label: Text(loc.text('change_password')),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(loc.text('logout')),
            ),
          ],
        ),
      ),
    );
  }
  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Future<void> _logout() async {
    final loc = AppLocalizations.of(context);

    try {
      await client.auth.signOut(scope: SignOutScope.local);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.text('logout_failed'))),
      );
    }
  }

  Future<void> _changePasswordDialog() async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.text('change_password')),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: loc.text('new_password'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;

              try {
                await client.auth.updateUser(
                  UserAttributes(password: controller.text),
                );
                if (mounted) Navigator.pop(context);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(loc.text('password_update_failed'))),
                );
              }
            },
            child: Text(loc.text('save')),
          ),
        ],
      ),
    );
  }
}