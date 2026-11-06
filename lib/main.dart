import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uawmxnlghmnwcoxhtful.supabase.co',   // <-- GANTI DENGAN URL ANDA
    anonKey: 'sb_publishable_HY-evQ_0IplBguWeKpJgyg_zfqVu-4Z',   // <-- GANTI DENGAN KEY ANDA
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiTrah', 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(), 
    );
  }
}