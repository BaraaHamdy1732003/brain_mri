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

  @override
  void initState() {
    super.initState();
    user = client.auth.currentUser;

    // Keep profile updated when auth state changes
    client.auth.onAuthStateChange.listen((event) {
      setState(() => user = client.auth.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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

        /// ✅ HOME ICON ON LEFT
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[300],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // Full Name
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text("Full Name"),
                subtitle: Text(fullName),
              ),
            ),

            const SizedBox(height: 12),

            // Email
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text("Email"),
                subtitle: Text(user!.email ?? "No email"),
              ),
            ),

            const SizedBox(height: 30),

            // Change password
            ElevatedButton.icon(
              onPressed: () => _changePasswordDialog(),
              icon: const Icon(Icons.lock_reset),
              label: const Text("Change Password"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Logout
            ElevatedButton.icon(
              onPressed: () {
                client.auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
          ),
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
