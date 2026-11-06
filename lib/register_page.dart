import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Berhasil! Silakan Login.'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Mendaftar: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. LATAR BELAKANG GELAP (Sama seperti halaman Login)
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
              constraints: const BoxConstraints(maxWidth: 500), // Lebih ramping untuk form daftar
              
              // 2. EFEK LIGHTING / GLOW
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
                color: Colors.white, // Form daftar full putih
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.5), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO & JUDUL
                      Image.asset(
                        'assets/Logo SiTRAH.png', // Menggunakan logo yang sama
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person_add_alt_1, size: 70, color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'DAFTAR AKUN',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                      const Text(
                        'Bergabunglah dengan silsilah keluarga',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // FORM EMAIL
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // FORM PASSWORD
                                            // FORM PASSWORD
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password (Minimal 6 Karakter)',
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
                      ),

                      // TOMBOL DAFTAR
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('DAFTAR SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                      
                      const SizedBox(height: 20),

                      // TOMBOL KEMBALI KE LOGIN
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Kembali ke halaman Login
                        },
                        child: const Text('Sudah punya akun? Kembali ke Login'),
                      )
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