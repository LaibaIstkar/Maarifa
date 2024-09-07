import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maarifa/secrets/keys.dart';

class DeleteAccountService {
  final SupabaseClient supabase;

  DeleteAccountService({required this.supabase});

  Future<bool> deleteAccount() async {
    final user = supabase.auth.currentUser;
    final jwt = supabase.auth.currentSession?.accessToken;

    if (user != null && jwt != null) {
      try {
        final response = await http.post(
          Uri.parse(deleteuserfunc),
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'user_id': user.id}),
        );


        if (response.statusCode == 200) {
          await supabase.auth.signOut();
          return true;
        } else {
          return false;
        }
      } catch (error) {
        return false;
      }
    } else {
      return false;
    }
  }
}
