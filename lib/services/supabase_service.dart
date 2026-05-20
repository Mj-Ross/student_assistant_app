// GROUP MEMBERS: [Full Names and Student Numbers]

import 'package:supabase_flutter/supabase_flutter.dart';

class Constants {
  static const String supabaseUrl = 'https://vserhpvhohmgsohoqgyj.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_xWkcvy1XpJmPlDo7DQCJ5A_fVtyPdoS';
}

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Supabase.initialize(
      url: Constants.supabaseUrl,
      anonKey: Constants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _isInitialized = true;
    print('✅ Supabase initialized');
  }

  static SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase not initialized');
    }
    return _client!;
  }
}