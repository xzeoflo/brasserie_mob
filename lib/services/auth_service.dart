import 'package:flutter/foundation.dart'; // pour debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  Future<AuthResponse?> signUp(String email, String password, String firstName, String lastName) async {
  try {
    final response = await _client.auth.signUp(email: email, password: password);

    final userId = response.user?.id;
    if (userId != null) {
      final insertedUser = await _client.from('users').insert({
        'id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role': '',
      }).select().maybeSingle();

      if (insertedUser == null) {
        debugPrint('Erreur : insertion dans users a retourné null');
        return null;
      }
    }

    return response;
  } catch (error) {
    debugPrint('Erreur d\'inscription : $error');
    return null;
  }
}


  // Retourne la session si succès, sinon null
  Future<Session?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      return response.session;
    } catch (error) {
      debugPrint('Erreur de connexion : $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
}
