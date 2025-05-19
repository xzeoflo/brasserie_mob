import 'package:flutter/material.dart';
import 'package:brasserie_mob/pages/home_page.dart';
import 'package:brasserie_mob/services/supabase.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brasserie Mob',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(), 
      debugShowCheckedModeBanner: false,
    );
  }
}
