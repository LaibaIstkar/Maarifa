import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._internal();

  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  final SupabaseClient client = Supabase.instance.client;


  SupabaseClient get supabaseClient => client;
}
