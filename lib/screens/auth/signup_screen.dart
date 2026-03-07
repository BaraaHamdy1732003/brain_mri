import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/input_field.dart';
import '../../routes.dart';
import '../../services/local_storage.dart';
import '../../services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();

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
      final fullName = _fullName.text.trim();

      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        setState(() {
          _error =
              AppLocalizations.of(context)!.text('fill_all_fields');
        });
        return;
      }

      final supa =
          Provider.of<SupabaseService>(context, listen: false);

      final res = await supa.signUp(email, password, fullName);

      if (res.user == null) {
        setState(() =>
            _error = AppLocalizations.of(context)!
                .text('signup_failed'));
        return;
      }

      await LocalStorage.saveUserId(res.user!.id);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() => _error =
          "${AppLocalizations.of(context)!.text('signup_error')}: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.text('sign_up'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: context
                  .watch<LanguageProvider>()
                  .locale
                  .languageCode,
              icon: const Icon(Icons.language,
                  color: Colors.white),
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<LanguageProvider>()
                      .changeLanguage(value);
                }
              },
              items: const [
                DropdownMenuItem(
                    value: 'en', child: Text('English')),
                DropdownMenuItem(
                    value: 'ru', child: Text('Русский')),
                DropdownMenuItem(
                    value: 'ar', child: Text('العربية')),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(
                  Icons.person_add,
                  size: 60,
                  color: Colors.blue.shade700,
                ),

                const SizedBox(height: 16),

                Text(
                  t.text('sign_up'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                InputField(
                  controller: _fullName,
                  label: t.text('full_name'),
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: _email,
                  label: t.text('email'),
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: _password,
                  label: t.text('password'),
                  obscure: true,
                ),

                const SizedBox(height: 24),

                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            t.text('create_account'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                if (_error != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}