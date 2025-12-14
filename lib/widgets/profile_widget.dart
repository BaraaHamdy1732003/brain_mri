import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final SupabaseClient client = Supabase.instance.client;
  User? user;

  @override
  void initState() {
    super.initState();
    user = client.auth.currentUser;

    client.auth.onAuthStateChange.listen((event) {
      setState(() => user = client.auth.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final metadata = user!.userMetadata ?? {};
    final fullName = metadata['display_name'] ?? "No name set";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // Avatar
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          Center(
            child: Text(
              user!.email ?? "No Email",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: _changePasswordDialog,
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              client.auth.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          )
        ],
      ),
    );
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
          decoration: const InputDecoration(labelText: "New Password"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await client.auth.updateUser(
                  UserAttributes(password: controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
