import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FormIzinScreen extends StatefulWidget {
  const FormIzinScreen({Key? key}) : super(key: key);

  @override
  State<FormIzinScreen> createState() => _FormIzinScreenState();
}

class _FormIzinScreenState extends State<FormIzinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _jenisIzin;
  String? _idProyek;
  String? _idPegawai;

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  PlatformFile? _pickedFile;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserProyek();
  }

  Future<void> _loadUserProyek() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/usersproyek'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        _idProyek = body['data'][0]['id_proyek'].toString();
        _idPegawai = body['data'][0]['id_pegawai'];
        _loading = false;
      });
    }
  }

  Future<void> _selectDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003554),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF003554),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        start ? _tanggalMulai = picked : _tanggalSelesai = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null || _tanggalSelesai == null) {
      _showMessage('Tanggal wajib diisi', Colors.orange);
      return;
    }

    if (_pickedFile == null) {
      _showMessage('File surat izin wajib diupload', Colors.orange);
      return;
    }

    setState(() => _submitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/izin/kerja'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'id_pegawai': _idPegawai!,
      'id_proyek': _idProyek!,
      'jenis_izin': _jenisIzin!,
      'subjek_izin': _subjekController.text,
      'keterangan_izin': _keteranganController.text,
      'tanggal_mulai': _tanggalMulai!.toIso8601String(),
      'tanggal_selesai': _tanggalSelesai!.toIso8601String(),
    });

    request.files.add(
      await http.MultipartFile.fromPath('suratizin', _pickedFile!.path!),
    );

    final response = await request.send();

    setState(() => _submitting = false);

    if (response.statusCode == 201) {
      _showMessage('Izin berhasil diajukan', Colors.green);
      _formKey.currentState!.reset();
      setState(() {
        _jenisIzin = null;
        _pickedFile = null;
        _tanggalMulai = null;
        _tanggalSelesai = null;
        _subjekController.clear();
        _keteranganController.clear();
      });
    } else {
      _showMessage('Gagal mengajukan izin', Colors.red);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _decor(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF003554)),
      filled: true,
      fillColor: const Color(0xFFF5F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF003554), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9FC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003554)),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat data...',
                style: TextStyle(
                  color: Color(0xFF003554),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF003554),
        title: const Text(
          'Pengajuan Izin',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFFFFFFFF),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFFFFFFFF),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003554), Color(0xFF006494)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003554).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Form Pengajuan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lengkapi data izin Anda',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Section
              const Text(
                'Informasi Izin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003554),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _jenisIzin,
                      decoration: _decor(
                        'Jenis Izin',
                        Icons.category_outlined,
                        hint: 'Pilih jenis izin',
                      ),
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF003554),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                        DropdownMenuItem(
                          value: 'lainnya',
                          child: Text('Lainnya'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _jenisIzin = v),
                      validator:
                          (v) => v == null ? 'Jenis izin wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjekController,
                      decoration: _decor(
                        'Subjek Izin',
                        Icons.title_outlined,
                        hint: 'Masukkan subjek izin',
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _keteranganController,
                      maxLines: 4,
                      decoration: _decor(
                        'Keterangan',
                        Icons.notes_outlined,
                        hint: 'Jelaskan alasan izin Anda',
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date Section
              const Text(
                'Periode Izin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003554),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _selectDate(true),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003554).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF003554),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tanggal Mulai',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tanggalMulai == null
                                        ? 'Pilih tanggal mulai'
                                        : DateFormat(
                                          'EEEE, dd MMMM yyyy',
                                          'id_ID',
                                        ).format(_tanggalMulai!),
                                    style: TextStyle(
                                      color:
                                          _tanggalMulai == null
                                              ? Colors.grey
                                              : const Color(0xFF003554),
                                      fontSize: 15,
                                      fontWeight:
                                          _tanggalMulai == null
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    InkWell(
                      onTap: () => _selectDate(false),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003554).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Color(0xFF003554),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tanggal Selesai',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tanggalSelesai == null
                                        ? 'Pilih tanggal selesai'
                                        : DateFormat(
                                          'EEEE, dd MMMM yyyy',
                                          'id_ID',
                                        ).format(_tanggalSelesai!),
                                    style: TextStyle(
                                      color:
                                          _tanggalSelesai == null
                                              ? Colors.grey
                                              : const Color(0xFF003554),
                                      fontSize: 15,
                                      fontWeight:
                                          _tanggalSelesai == null
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // File Upload Section
              const Text(
                'Dokumen Pendukung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003554),
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          _pickedFile == null
                              ? const Color(0xFFE0E8F0)
                              : const Color(0xFF003554),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _pickedFile == null
                                  ? const Color(0xFFF5F9FC)
                                  : const Color(0xFF003554).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _pickedFile == null
                              ? Icons.cloud_upload_outlined
                              : Icons.check_circle_outline,
                          size: 40,
                          color:
                              _pickedFile == null
                                  ? Colors.grey
                                  : const Color(0xFF003554),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pickedFile == null
                            ? 'Upload Surat Izin'
                            : _pickedFile!.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color:
                              _pickedFile == null
                                  ? Colors.grey
                                  : const Color(0xFF003554),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pickedFile == null
                            ? 'JPG, PNG, atau PDF (Maks. 5MB)'
                            : 'Tap untuk mengganti file',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003554),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _submitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Kirim Pengajuan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
