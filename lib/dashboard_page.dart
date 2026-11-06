import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'add_member_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalMembers = 0;
  bool _isLoading = true;

  bool get _isAdmin => Supabase.instance.client.auth.currentUser?.email == 'cek@keluarga.com';
  String get _userEmail => Supabase.instance.client.auth.currentUser?.email ?? 'Pengguna';

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await Supabase.instance.client.from('members').select('id');
      if (mounted) {
        setState(() {
          _totalMembers = (response as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat statistik: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05140A), Color(0xFF0B2914)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          _isAdmin ? 'Admin SiTrah' : 'Anggota Keluarga',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _userEmail,
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.family_restroom, color: Colors.white, size: 40),
                      const SizedBox(height: 16),
                      const Text(
                        'Total Anggota Keluarga',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              '$_totalMembers Orang',
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Menu Utama',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildMenuCard(
                  icon: Icons.account_tree,
                  title: 'Lihat Pohon Silsilah',
                  subtitle: 'Visualisasi seluruh anggota keluarga',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                    _fetchStats();
                  },
                ),
                const SizedBox(height: 12),

                // MENU TAMBAH HANYA MUNCUL UNTUK ADMIN
                if (_isAdmin) ...[
                  _buildMenuCard(
                    icon: Icons.person_add,
                    title: 'Tambah Anggota Baru',
                    subtitle: 'Daftarkan anggota keluarga baru',
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMemberPage()));
                      if (result == true) {
                        _fetchStats(); 
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF4CAF50), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}