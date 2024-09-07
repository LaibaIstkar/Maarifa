import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AuthState class to hold the current user's ID and other relevant information
class AuthStateM {
  final String? userId;

  AuthStateM({required this.userId});

  factory AuthStateM.fromUser(User? user) {
    return AuthStateM(userId: user?.id);
  }
}

// AuthProvider to manage the authentication state
final authProvider = StateProvider<AuthStateM>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  return AuthStateM.fromUser(user);
});

