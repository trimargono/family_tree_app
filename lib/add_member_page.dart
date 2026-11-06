import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedFatherId;
  String? _selectedMotherId;
  String? _selectedSpouseId;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _members = [];

  // Variabel untuk menyimpan foto
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final data = await Supabase.instance.client.from('members').select();
    setState(() {
      _members = List<Map<String, dynamic>>.from(data);
    });
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  Future<void> _saveMember() async {
    if (_nameController.text.isEmpty || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Jenis Kelamin wajib diisi!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      String? uploadedUrl;

      // 1. Jika ada gambar, unggah ke Supabase Storage
      if (_imageBytes != null && _imageName != null) {
        final fileExt = _imageName!.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, _imageBytes!);
            
        uploadedUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
      }

      // 2. Simpan data ke tabel members
      await Supabase.instance.client.from('members').insert({
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'birth_year': _birthYearController.text.isNotEmpty ? int.parse(_birthYearController.text) : null,
        'father_id': _selectedFatherId != null ? int.parse(_selectedFatherId!) : null,
        'mother_id': _selectedMotherId != null ? int.parse(_selectedMotherId!) : null,
        'spouse_id': _selectedSpouseId != null ? int.parse(_selectedSpouseId!) : null,
        'avatar_url': uploadedUrl, 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggota Keluarga Berhasil Ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2914),
      appBar: AppBar(
        title: const Text('Tambah Anggota Keluarga'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
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
                    // ==== AREA UPLOAD FOTO ====
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFE8F5E9),
                        backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                        child: _imageBytes == null 
                            ? const Icon(Icons.camera_alt, size: 40, color: Color(0xFF2E7D32))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Ketuk untuk memilih foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        prefixIcon: const Icon(Icons.wc),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedGender,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                      ],
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _birthYearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tahun Lahir (Contoh: 1990)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Ayah (Opsional)',
                        prefixIcon: const Icon(Icons.man),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedFatherId,
                      items: _members.where((m) => m['gender'] == 'male')
                          .map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text(m['name']))).toList(),
                      onChanged: (value) => setState(() => _selectedFatherId = value),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Ibu (Opsional)',
                        prefixIcon: const Icon(Icons.woman),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedMotherId,
                      items: _members.where((m) => m['gender'] == 'female')
                          .map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text(m['name']))).toList(),
                      onChanged: (value) => setState(() => _selectedMotherId = value),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Pasangan (Opsional)',
                        prefixIcon: const Icon(Icons.favorite),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedSpouseId,
                      items: _members.map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text(m['name']))).toList(),
                      onChanged: (value) => setState(() => _selectedSpouseId = value),
                    ),
                    const SizedBox(height: 32),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _saveMember,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('SIMPAN DATA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}