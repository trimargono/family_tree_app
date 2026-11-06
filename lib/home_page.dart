import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:genealogy_chart/genealogy_chart.dart';
import 'add_member_page.dart';
import 'detail_member_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FamilyMember> _familyMembers = [];
  bool _loading = true;
  
  final Map<String, String?> _avatarUrls = {};
  final Map<String, String> _fullNames = {};

  bool get _isAdmin => Supabase.instance.client.auth.currentUser?.email == 'cek@keluarga.com';

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    try {
      final data = await Supabase.instance.client.from('members').select();
      
      final Map<String, Map<String, dynamic>> rawData = {
        for (var row in data) row['id'].toString(): row
      };

      _avatarUrls.clear();
      _fullNames.clear();
      for (var row in data) {
        _avatarUrls[row['id'].toString()] = row['avatar_url'];
        _fullNames[row['id'].toString()] = row['name'] ?? '';
      }

      int hitungGenerasi(String id, Map<String, Map<String, dynamic>> dataMap) {
        var member = dataMap[id];
        if (member == null) return 1;
        if (member['father_id'] != null) {
          return hitungGenerasi(member['father_id'].toString(), dataMap) + 1;
        } else if (member['mother_id'] != null) {
          return hitungGenerasi(member['mother_id'].toString(), dataMap) + 1;
        }
        return 1; 
      }

      final members = data.map((row) {
        final id = row['id'].toString();
        final parentIds = <String>[];
        if (row['father_id'] != null) parentIds.add(row['father_id'].toString());
        if (row['mother_id'] != null) parentIds.add(row['mother_id'].toString());
        
        String namaAsli = row['name'] ?? '';
        
        return FamilyMember(
          id: id,
          name: namaAsli, 
          gender: row['gender'] == 'female' ? Gender.female : Gender.male,
          generation: hitungGenerasi(id, rawData), 
          parentIds: parentIds,
          spouseIds: row['spouse_id'] != null ? [row['spouse_id'].toString()] : [],
        );
      }).toList();

      if (mounted) {
        setState(() {
          _familyMembers = members;
          _loading = false;
        });
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic e) {
    if (mounted) {
      setState(() => _loading = false);
      if (e is AuthException || e.toString().contains('JWT')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi berakhir. Silakan login kembali.'), backgroundColor: Colors.orange),
        );
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silsilah Keluarga'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _familyMembers.isEmpty
              ? const Center(child: Text('Belum ada data. Klik tombol + untuk menambah.'))
              : GenealogyChart.family(
                  members: _familyMembers,
                  theme: GenealogyChartTheme(
                    selectionColor: Colors.deepPurple,
                    selectionWidth: 4,
                  ),
                  // ==== KUSTOMISASI NODE (FOTO + NAMA + KLIK) ====
                  familyNodeBuilder: (context, member, state) {
                    final avatarUrl = _avatarUrls[member.id];
                    String fullName = _fullNames[member.id] ?? '';
                    String displayName = fullName.length > 10 ? '${fullName.substring(0, 8)}...' : fullName;

                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMemberPage(memberId: member.id),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _familyMembers.clear();
                            _loading = true;
                          });
                          await _loadTree();
                        }
                      },
                      // KUNCI: Kita gunakan ukuran spesifik (80x80) agar sesuai dengan library
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Foto Lingkaran
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: state.isSelected ? Colors.deepPurple : Colors.grey.shade300,
                                  width: state.isSelected ? 3 : 1,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty 
                                    ? NetworkImage(avatarUrl) 
                                    : null,
                                child: avatarUrl == null || avatarUrl.isEmpty
                                    ? Icon(
                                        member.gender == Gender.female ? Icons.female : Icons.male,
                                        size: 26,
                                        color: Colors.grey.shade600,
                                      )
                                    : null,
                              ),
                            ),
                            // Nama di bawah foto (posisi diatur agar tidak menutupi garis)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onMemberTap: (member) {},
                ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMemberPage()));
                if (result == true) {
                  setState(() { _familyMembers.clear(); _loading = true; });
                  _loadTree();
                }
              },
              child: const Icon(Icons.add), 
            )
          : null,
    );
  }
}