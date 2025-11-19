import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  // Add image upload method - FIXED VERSION
  Future<String?> uploadImage(File imageFile) async {
  try {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Generate unique filename
    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Read as Uint8List
    final bytes = await imageFile.readAsBytes();

    // Upload using uploadBinary
    final response = await client.storage
        .from('mri_images')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    // Check upload success
    if (response.isEmpty) throw Exception('Upload failed');

    // Generate public URL
    final url = client.storage
        .from('mri_images')
        .getPublicUrl(fileName);

    debugPrint('✅ Uploaded: $url');
    return url;

  } catch (e) {
    debugPrint('❌ Failed to upload image: $e');
    return null;
  }
}


  Future<void> savePredictionToHistory({
    required String imageUrl,
    required String predictedLabel,
    required double confidence,
    required Map<String, dynamic> allScores,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await client.from('history').insert({
        'user_id': user.id,
        'image_url': imageUrl,
        'predicted_label': predictedLabel,
        'confidence': confidence,
        'all_scores': allScores,
      }).select();

      debugPrint('✅ Prediction saved to history with ID: ${response[0]['id']}');
    } catch (e) {
      debugPrint('❌ Failed to save prediction to history: $e');
      if (e is PostgrestException) {
        debugPrint('📋 Database error details: ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await client
        .from('history')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteHistoryItem(String id) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await client
        .from('history')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}