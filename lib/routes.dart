// lib/routes.dart (update getRoutes)
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/result_screen.dart';
import 'screens/home/history_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/chat/chat_screen.dart';


class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String result = '/result';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      home: (context) => const HomeScreen(),
      result: (context) => const ResultScreen(),
      history: (context) => const HistoryScreen(),
      profile: (context) => const ProfileScreen(),
      chat: (context) => const ChatScreen(),
    };
  }
}
