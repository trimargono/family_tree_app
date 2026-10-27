import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:genealogy_chart/genealogy_chart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uawmxnlghmnwcoxhtful.supabase.co', // <-- GANTI INI
    anonKey: 'sb_publishable_HY-evQ_0IplBguWeKpJgyg_zfqVu-4Z', // <-- GANTI INI
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silsilah Keluarga',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FamilyMember> _familyMembers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    final data = await Supabase.instance.client.from('members').select();
    
    // Simpan data mentah ke map agar mudah dicari
    final Map<String, Map<String, dynamic>> rawData = {
      for (var row in data) row['id'].toString(): row
    };

    // Fungsi untuk menghitung generasi secara otomatis
    int hitungGenerasi(String id, Map<String, Map<String, dynamic>> dataMap) {
      var member = dataMap[id];
      if (member == null) return 1;
      
      // Jika punya ayah, generasi = generasi ayah + 1
      if (member['father_id'] != null) {
        return hitungGenerasi(member['father_id'].toString(), dataMap) + 1;
      } 
      // Jika tidak punya ayah tapi punya ibu
      else if (member['mother_id'] != null) {
        return hitungGenerasi(member['mother_id'].toString(), dataMap) + 1;
      }
      // Jika tidak punya orang tua (Kakek/Nenek), generasi = 1
      return 1; 
    }

    // Konversi ke FamilyMember
    final members = data.map((row) {
      final id = row['id'].toString();
      final parentIds = <String>[];
      if (row['father_id'] != null) parentIds.add(row['father_id'].toString());
      if (row['mother_id'] != null) parentIds.add(row['mother_id'].toString());
      
      return FamilyMember(
        id: id,
        name: row['name'] ?? '',
        gender: row['gender'] == 'female' ? Gender.female : Gender.male,
        generation: hitungGenerasi(id, rawData), 
        parentIds: parentIds,
        spouseIds: row['spouse_id'] != null ? [row['spouse_id'].toString()] : [],
      );
    }).toList();

    setState(() {
      _familyMembers = members;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silsilah Keluarga')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _familyMembers.isEmpty
              ? const Center(child: Text('Belum ada data.'))
              : GenealogyChart.family(
                  members: _familyMembers,
                  onMemberTap: (member) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Anda mengklik: ${member.name}')),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
           setState(() => _loading = true);
           _loadTree();
        },
      ),
    );
  }
}