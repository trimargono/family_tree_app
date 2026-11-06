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

  bool get _isAdmin => Supabase.instance.client.auth.currentUser?.email == 'cek@keluarga.com';

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    try {
      // KUNCI PERBAIKAN: Kita urutkan berdasarkan 'id' dari database sejak awal
      final data = await Supabase.instance.client
          .from('members')
          .select()
          .order('id', ascending: true); 
      
      final Map<String, Map<String, dynamic>> rawData = {
        for (var row in data) row['id'].toString(): row
      };

      int hitungGenerasi(String id, Map<String, Map<String, dynamic>> dataMap, [Set<String>? visited]) {
        visited ??= {};
        if (visited.contains(id)) return 1; 
        visited.add(id);

        var member = dataMap[id];
        if (member == null) return 1;
        
        if (member['father_id'] != null) {
          return hitungGenerasi(member['father_id'].toString(), dataMap, visited) + 1;
        } else if (member['mother_id'] != null) {
          return hitungGenerasi(member['mother_id'].toString(), dataMap, visited) + 1;
        }
        
        if (member['spouse_id'] != null) {
           return hitungGenerasi(member['spouse_id'].toString(), dataMap, visited);
        }
        
        return 1; 
      }

      final members = data.map((row) {
        final id = row['id'].toString();
        final parentIds = <String>[];
        if (row['father_id'] != null) parentIds.add(row['father_id'].toString());
        if (row['mother_id'] != null) parentIds.add(row['mother_id'].toString());
        
        String namaAsli = row['name'] ?? '';
        String namaTampil = namaAsli.length > 15 ? '${namaAsli.substring(0, 13)}...' : namaAsli;

        return FamilyMember(
          id: id,
          name: namaTampil, 
          gender: row['gender'] == 'female' ? Gender.female : Gender.male,
          generation: hitungGenerasi(id, rawData), 
          parentIds: parentIds,
          spouseIds: row['spouse_id'] != null ? [row['spouse_id'].toString()] : [],
          avatar: row['avatar_url'], 
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
                  familyNodeStyle: FamilyNodeStyle.circleAvatar, 
                  onMemberTap: (member) async {
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