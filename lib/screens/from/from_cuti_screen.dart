import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FormCutiScreen extends StatefulWidget {
  const FormCutiScreen({Key? key}) : super(key: key);

  @override
  State<FormCutiScreen> createState() => _FormCutiScreenState();
}

class _FormCutiScreenState extends State<FormCutiScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  PlatformFile? _pickedFile;

  String? _idProyek;
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
      headers: {
        'Authorization':
            'Bearer 1|FZGajyXfVyVuxVYYV9RBZQObsj4gU6AJ2bTWecpbb9505dec',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        _idProyek = body['data'][0]['id_proyek'].toString();
        _loading = false;
      });
    } else {
      _showSnackBar('Gagal mengambil data proyek', Colors.red);
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime firstDate =
        isStart ? DateTime.now() : (_tanggalMulai ?? DateTime.now());

    final DateTime initialDate =
        isStart
            ? DateTime.now()
            : (_tanggalMulai != null && _tanggalMulai!.isAfter(DateTime.now())
                ? _tanggalMulai!
                : DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
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
        if (isStart) {
          _tanggalMulai = picked;
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = null;
          }
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      if (result.files.single.size > 2 * 1024 * 1024) {
        _showSnackBar('Ukuran file maksimal 2MB', Colors.orange);
        return;
      }
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null ||
        _tanggalSelesai == null ||
        _pickedFile == null) {
      _showSnackBar('Semua field wajib diisi', Colors.orange);
      return;
    }

    setState(() => _submitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/cuti/buat_cuti'),
    );

    request.headers.addAll({
      'Authorization':
          'Bearer 1|FZGajyXfVyVuxVYYV9RBZQObsj4gU6AJ2bTWecpbb9505dec',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'id_proyek': _idProyek!,
      'subjek_cuti': _subjekController.text,
      'keterangan_cuti': _keteranganController.text,
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(_tanggalMulai!),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(_tanggalSelesai!),
    });

    request.files.add(
      await http.MultipartFile.fromPath('surat_cuti', _pickedFile!.path!),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    setState(() => _submitting = false);

    if (response.statusCode == 201) {
      _showSnackBar('Pengajuan cuti berhasil', Colors.green);
      _formKey.currentState!.reset();
      setState(() {
        _pickedFile = null;
        _tanggalMulai = null;
        _tanggalSelesai = null;
        _subjekController.clear();
        _keteranganController.clear();
      });
    } else {
      debugPrint(body);
      _showSnackBar(
        jsonDecode(body)['message'] ?? 'Gagal mengajukan cuti',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String msg, Color color) {
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

  InputDecoration _inputDecor(String label, IconData icon, {String? hint}) {
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

  int _calculateDuration() {
    if (_tanggalMulai == null || _tanggalSelesai == null) return 0;
    return _tanggalSelesai!.difference(_tanggalMulai!).inDays + 1;
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
          'Pengajuan Cuti',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
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
              // Header Card
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
                        Icons.beach_access,
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
                            'Ajukan Cuti',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Isi formulir dengan lengkap',
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
                'Detail Cuti',
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
                    TextFormField(
                      controller: _subjekController,
                      decoration: _inputDecor(
                        'Subjek Cuti',
                        Icons.title_outlined,
                        hint: 'Contoh: Cuti Tahunan',
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator:
                          (v) => v!.isEmpty ? 'Subjek Cuti wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _keteranganController,
                      maxLines: 4,
                      decoration: _inputDecor(
                        'Keterangan Cuti',
                        Icons.notes_outlined,
                        hint: 'Jelaskan keperluan cuti Anda',
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator:
                          (v) =>
                              v!.isEmpty ? 'Keterangan Cuti wajib diisi' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date Section
              const Text(
                'Periode Cuti',
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
                                        ? 'Pilih tanggal mulai cuti'
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
                                        ? 'Pilih tanggal selesai cuti'
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

              // Duration Info
              if (_tanggalMulai != null && _tanggalSelesai != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003554).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF003554).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF003554),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Durasi cuti: ${_calculateDuration()} hari',
                          style: const TextStyle(
                            color: Color(0xFF003554),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                            ? 'Upload Surat Cuti'
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
                            ? 'JPG, PNG, atau PDF (Maks. 2MB)'
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
                                'Ajukan Cuti',
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
