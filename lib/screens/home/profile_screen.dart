import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user session")),
      );
    }

    final metadata = user!.userMetadata ?? {};
    final fullName = metadata['full_name'] ?? "No name set";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 251, 252),
      appBar: AppBar(
        title: const Text("Profile"),
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
            _infoCard("Full Name", fullName, Icons.person),
            _infoCard("Email", user!.email ?? "No email", Icons.email),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _changePasswordDialog,
              icon: const Icon(Icons.lock_reset),
              label: const Text("Change Password"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await client.auth.signOut(scope: SignOutScope.local);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed')),
      );
    }
  }

  Future<void> _changePasswordDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
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
                  const SnackBar(content: Text('Password update failed')),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
