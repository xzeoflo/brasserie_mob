import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://bxqhiqpscrlqxhlphjzs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ4cWhpcXBzY3JscXhobHBoanpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxODI4MTMsImV4cCI6MjA1OTc1ODgxM30.P2rf9179D9BKlpzHl2vM6XuWgSK-R53LT32_nD2ACPk'; // tronqué ici
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }


}
