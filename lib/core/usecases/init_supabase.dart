import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  if (dotenv.env['SUPABASE_URL'] == null ||
      dotenv.env['SUPABASE_ANON_KEY'] == null) {
    throw Exception(
        'Please define SUPABASE_URL and SUPABASE_ANON_KEY in your .env file');
  } else {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? "",
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? "",
    );
  }
}
