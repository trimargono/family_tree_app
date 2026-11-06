import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_page.dart'; // <-- Tambahkan ini
import 'register_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    // 1. Validasi Input Kosong (Notifikasi Oranye)
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        // 2. Notifikasi Sukses Login (Hijau)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
          ),
        );
                // Arahkan ke Dashboard, bukan HomePage
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } on AuthException catch (e) {
      if (mounted) {
        // 3. Notifikasi Gagal Login (Merah)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Login: ${e.message}'), 
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      // Latar Belakang Gelap (Dark Emerald)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05140A), Color(0xFF0B2914)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              
              // Efek Lighting / Glow Hijau
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),

              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.5), width: 2),
                ),
                clipBehavior: Clip.antiAlias, 
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // ================= BAGIAN KIRI: GAMBAR =================
                      if (isDesktop)
                        Expanded(
                          flex: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/SiTrah2.png', // Ganti nama file jika perlu
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF1B5E20),
                                  child: const Center(
                                    child: Icon(Icons.family_restroom, size: 150, color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                  ),
                                ),
                              ),
                              const Positioned(
                                bottom: 40,
                                left: 20,
                                right: 20,
                                child: Column(
                                  children: [
                                    Text(
                                      'Rekam Jejak Keluarga',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Satu pohon, sejuta kenangan.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ================= BAGIAN KANAN: FORM LOGIN =================
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // LOGO SITRAH
                              Image.asset(
                                'assets/Logo SiTRAH.png', // Sesuaikan dengan nama file logo Anda
                                height: 250,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.account_tree_rounded, size: 70, color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 10),
                              //const Text('SI TRAH',
                              //  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              //),
                              //const Text(
                                //'Sistem Informasi Silsilah Keluarga',
                                //style: TextStyle(fontSize: 14, color: Colors.grey),
                              //),
                              const SizedBox(height: 40),

                                 TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  textInputAction: TextInputAction.next, // Tombol Enter berubah jadi "Next"
                                ),
                              const SizedBox(height: 16),

                                                            // FORM PASSWORD
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  // Tambahkan tombol ikon mata di kanan
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                obscureText: _obscurePassword, // Gunakan variabel
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _signIn(),
                              ),

                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      onPressed: _signIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E7D32),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('MASUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                              
                              const SizedBox(height: 16),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                                },
                                child: const Text('Belum punya akun? Daftar di sini'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}