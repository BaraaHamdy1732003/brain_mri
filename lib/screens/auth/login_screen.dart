import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../widgets/input_field.dart';
import '../../routes.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_provider.dart';

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
        setState(() => _error =
            AppLocalizations.of(context)!
                .text('enter_email_password'));
        return;
      }

      final supabase = Supabase.instance.client;

      final response =
          await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        setState(() => _error =
            AppLocalizations.of(context)!
                .text('invalid_credentials'));
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(
          context, Routes.home);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error =
          AppLocalizations.of(context)!
                  .text('signin_error') +
              ': $e');
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.text('sign_in'),
          style:
              const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: context
                  .watch<LanguageProvider>()
                  .locale
                  .languageCode,
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<LanguageProvider>()
                      .changeLanguage(value);
                }
              },
              items: const [
                DropdownMenuItem(
                    value: 'en',
                    child: Text('English')),
                DropdownMenuItem(
                    value: 'ru',
                    child: Text('Русский')),
                DropdownMenuItem(
                    value: 'ar',
                    child: Text('العربية')),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue
                      .withOpacity(0.15),
                  blurRadius: 20,
                  offset:
                      const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.medical_services,
                  size: 60,
                  color:
                      Colors.blue.shade700,
                ),
                const SizedBox(
                    height: 16),
                Text(
                  t.text('sign_in'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors
                        .blue.shade700,
                  ),
                ),
                const SizedBox(
                    height: 24),
                InputField(
                  controller: _email,
                  label:
                      t.text('email'),
                ),
                const SizedBox(
                    height: 16),
                InputField(
                  controller:
                      _password,
                  label: t
                      .text('password'),
                  obscure: true,
                ),
                const SizedBox(
                    height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton(
                          onPressed:
                              _signIn,
                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                                Colors
                                    .blue
                                    .shade700,
                            padding:
                                const EdgeInsets
                                        .symmetric(
                                    vertical:
                                        14),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                          child: Text(
                            t.text(
                                'sign_in'),
                            style:
                                const TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: Colors
                                  .white,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                    height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(
                          context,
                          Routes.signup),
                  child: Text(
                    t.text(
                        'create_account'),
                    style:
                        TextStyle(
                      color: Colors
                          .blue
                          .shade700,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding:
                        const EdgeInsets
                                .only(
                            top: 16),
                    child: Text(
                      _error!,
                      textAlign:
                          TextAlign
                              .center,
                      style:
                          const TextStyle(
                        color:
                            Colors.red,
                        fontWeight:
                            FontWeight
                                .w500,
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