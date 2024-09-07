import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/supabaseservice.dart';

final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, AsyncValue<String?>>((ref) {
  return SignUpViewModel();
});

class SignUpViewModel extends StateNotifier<AsyncValue<String?>> {
  SignUpViewModel() : super(const AsyncValue.data(null));

  Future<void> signUp(String username, String email, String password) async {
    state = const AsyncValue.loading();
    final supabase = SupabaseService().supabaseClient;
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
        },
      );

      if (response.user != null) {
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
