import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form Izin',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A3D5C),
        scaffoldBackgroundColor: const Color(0xFF0A3D5C),
      ),
      home: const FormIzinPage(),
    );
  }
}

class FormIzinPage extends StatefulWidget {
  const FormIzinPage({super.key});

  @override
  State<FormIzinPage> createState() => _FormIzinPageState();
}

class _FormIzinPageState extends State<FormIzinPage> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalAkhir;
  String? _selectedKeterangan;
  String? _fileName;

  final List<String> _keteranganOptions = [
    'Sakit',
    'Izin Pribadi',
    'Cuti',
    'Dinas Luar',
    'Lainnya',
  ];

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isMulai) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isMulai
              ? (_tanggalMulai ?? DateTime.now())
              : (_tanggalAkhir ?? _tanggalMulai ?? DateTime.now()),
      firstDate: isMulai ? DateTime(2020) : (_tanggalMulai ?? DateTime(2020)),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = picked;
          if (_tanggalAkhir != null && _tanggalAkhir!.isBefore(picked)) {
            _tanggalAkhir = null;
          }
        } else {
          _tanggalAkhir = picked;
        }
      });
    }
  }

  void _pickFile() {
    setState(() {
      _fileName = 'dokumen_izin.pdf';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('File berhasil dipilih')));
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null ||
        _tanggalAkhir == null ||
        _selectedKeterangan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lengkapi semua data')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text(
              'Tanggal: ${DateFormat('dd/MM/yyyy').format(_tanggalMulai!)} - '
              '${DateFormat('dd/MM/yyyy').format(_tanggalAkhir!)}\n'
              'Keterangan: $_selectedKeterangan',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _deskripsiController.clear();
                    _tanggalMulai = null;
                    _tanggalAkhir = null;
                    _selectedKeterangan = null;
                    _fileName = null;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D5C),
        title: const Text('Form Izin'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // === BAGIAN ATAS ===
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF0A3D5C),
                child: Column(
                  children: [
                    _dateButton(
                      'Tanggal Mulai',
                      _tanggalMulai,
                      () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 12),
                    _dateButton(
                      'Tanggal Akhir',
                      _tanggalAkhir,
                      _tanggalMulai == null
                          ? null
                          : () => _selectDate(context, false),
                    ),
                    const SizedBox(height: 12),
                    _dropdownKeterangan(),
                  ],
                ),
              ),

              // === BAGIAN PUTIH ===
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Lampirkan File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D5C),
                      ),
                    ),
                    if (_fileName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_fileName!),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A3D5C),
                        ),
                        child: const Text('Kirim'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateButton(String label, DateTime? date, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white),
        ),
        child: Text(
          date == null ? label : DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _dropdownKeterangan() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF0A3D5C),
          value: _selectedKeterangan,
          hint: const Text('Keterangan', style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          isExpanded: true,
          items:
              _keteranganOptions
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedKeterangan = value),
        ),
      ),
    );
  }
}
