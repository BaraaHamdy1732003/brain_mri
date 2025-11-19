import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {
  Future<String?> signUp(String email, String password) async {
    try {
      final response = await supabase.rpc(
        'signup_user',
        params: {
          'p_email': email,
          'p_password': password,
        },
      );

      return response; // returns user ID
    } catch (e) {
      return null;
    }
  }
}
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.rpc(
        'login_user',
        params: {
          'p_email': email,
          'p_password': password,
        },
      );

      return response; // user ID
    } catch (e) {
      return null;
    }
  }
