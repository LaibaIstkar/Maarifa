import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maarifa/core/database/auth_state.dart'  ;

// A StateNotifier to listen to auth state changes and update the AuthState
class AuthStateNotifier extends StateNotifier<AuthStateM> {
  AuthStateNotifier() : super(AuthStateM(userId: Supabase.instance.client.auth.currentUser?.id)) {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      state = AuthStateM.fromUser(Supabase.instance.client.auth.currentUser);
    });
  }
}

// Provider for the AuthStateNotifier
final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthStateM>((ref) {
  return AuthStateNotifier();
});