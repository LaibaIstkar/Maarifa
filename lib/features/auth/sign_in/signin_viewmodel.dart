import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/supabaseservice.dart';



final signInViewModelProvider = StateNotifierProvider<SignInViewModel, AsyncValue<String?>>((ref) {
  return SignInViewModel();
});

class SignInViewModel extends StateNotifier<AsyncValue<String?>> {
  SignInViewModel() : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final supabase = SupabaseService().supabaseClient;
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        // Fetch the username from the profiles table
        final userProfile = await supabase
            .from('profiles')
            .select('username')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (userProfile != null) {
          final username = userProfile['username'] as String;
          state = AsyncValue.data(username);
        } else {
          state = AsyncValue.error("No profile found for this user", StackTrace.current);
        }
      } else {
        state =
            AsyncValue.error("Invalid email or password", StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }

}