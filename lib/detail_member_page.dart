import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_member_page.dart';

class DetailMemberPage extends StatefulWidget {
  final String memberId;

  const DetailMemberPage({super.key, required this.memberId});

  @override
  State<DetailMemberPage> createState() => _DetailMemberPageState();
}

class _DetailMemberPageState extends State<DetailMemberPage> {
  Map<String, dynamic>? _member;
  bool _isLoading = true;
  
  String _fatherName = '-';
  String _motherName = '-';
  String _spouseName = '-';
  List<String> _childrenNames = [];

  bool get _isAdmin => Supabase.instance.client.auth.currentUser?.email == 'cek@keluarga.com';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await Supabase.instance.client.from('members').select().eq('id', widget.memberId).single();
      final allMembers = await Supabase.instance.client.from('members').select();
      
      if (data['father_id'] != null) {
        final fatherList = allMembers.where((m) => m['id'] == data['father_id']).toList();
        if (fatherList.isNotEmpty) _fatherName = fatherList.first['name'];
      }

      if (data['mother_id'] != null) {
        final motherList = allMembers.where((m) => m['id'] == data['mother_id']).toList();
        if (motherList.isNotEmpty) _motherName = motherList.first['name'];
      }

      if (data['spouse_id'] != null) {
        final spouseList = allMembers.where((m) => m['id'] == data['spouse_id']).toList();
        if (spouseList.isNotEmpty) _spouseName = spouseList.first['name'];
      }

      final children = allMembers.where((m) => m['father_id'] == data['id'] || m['mother_id'] == data['id']).toList();
      _childrenNames = children.map((c) => c['name'].toString()).toList();

      if (mounted) {
        setState(() {
          _member = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2914),
      appBar: AppBar(
        title: const Text('Detail Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _member == null
              ? const Center(child: Text('Data tidak ditemukan', style: TextStyle(color: Colors.white)))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.5), width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: const Color(0xFFE8F5E9),
                                backgroundImage: _member!['avatar_url'] != null 
                                    ? NetworkImage(_member!['avatar_url']) 
                                    : null,
                                child: _member!['avatar_url'] == null 
                                    ? Icon(
                                        _member!['gender'] == 'female' ? Icons.female : Icons.male,
                                        size: 70,
                                        color: const Color(0xFF2E7D32),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              
                              Text(
                                _member!['name'] ?? 'Tanpa Nama',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Lahir: ${_member!['birth_year'] ?? 'Tidak diketahui'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                ),
                              ),
                              
                              const Divider(height: 40),
                              
                              _buildInfoRow(Icons.man, 'Ayah', _fatherName),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.woman, 'Ibu', _motherName),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.favorite, 'Pasangan', _spouseName),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.child_care, 
                                'Anak', 
                                _childrenNames.isEmpty ? '-' : _childrenNames.join(', ')
                              ),
                              
                              const Divider(height: 40),
                              
                              if (_isAdmin)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('EDIT'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () async {
                                          final navigator = Navigator.of(context);
                                          final result = await navigator.push(
                                            MaterialPageRoute(builder: (context) => EditMemberPage(memberData: _member!)),
                                          );
                                          if (result == true) {
                                            navigator.pop(); 
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.delete),
                                        label: const Text('HAPUS'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () async {
                                          final navigator = Navigator.of(context);
                                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                                          
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Konfirmasi Hapus'),
                                              content: Text('Apakah Anda yakin ingin menghapus ${_member!['name']}?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await Supabase.instance.client.from('members').delete().eq('id', _member!['id']);
                                              scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Data berhasil dihapus!'), backgroundColor: Colors.green));
                                              navigator.pop(); 
                                            } catch (e) {
                                              scaffoldMessenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}