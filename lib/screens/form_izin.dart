import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class FormIzinScreen extends StatefulWidget {
  const FormIzinScreen({Key? key}) : super(key: key);

  @override
  State<FormIzinScreen> createState() => _FormIzinScreenState();
}

class _FormIzinScreenState extends State<FormIzinScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _idPegawaiController = TextEditingController();
  final TextEditingController _idProyekController = TextEditingController();
  final TextEditingController _jenisIzinController = TextEditingController();
  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  PlatformFile? _pickedFile;

  @override
  void dispose() {
    _idPegawaiController.dispose();
    _idProyekController.dispose();
    _jenisIzinController.dispose();
    _subjekController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066CC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF003554),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        isStartDate ? _tanggalMulai = picked : _tanggalSelesai = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.single;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null || _tanggalSelesai == null) {
      _showSnackBar('Tanggal mulai dan selesai wajib diisi', Colors.orange);
      return;
    }

    if (_pickedFile == null) {
      _showSnackBar('File izin wajib diupload', Colors.orange);
      return;
    }

    final data = {
      'id_pegawai': _idPegawaiController.text,
      'id_proyek': int.parse(_idProyekController.text),
      'jenis_izin': _jenisIzinController.text,
      'subjek_izin': _subjekController.text,
      'keterangan_izin': _keteranganController.text,
      'tanggal_mulai': _tanggalMulai!.toIso8601String(),
      'tanggal_selesai': _tanggalSelesai!.toIso8601String(),
      'file_path': _pickedFile!.path,
      'file_name': _pickedFile!.name,
    };

    debugPrint('DATA FORM: $data');
    _showSnackBar('Form berhasil dikirim!', Colors.green);

    // Reset form
    Future.delayed(const Duration(seconds: 1), () {
      _formKey.currentState?.reset();
      setState(() {
        _tanggalMulai = null;
        _tanggalSelesai = null;
        _pickedFile = null;
      });
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white60, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003554),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003554),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Form Izin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _formKey.currentState?.reset();
              setState(() {
                _tanggalMulai = null;
                _tanggalSelesai = null;
                _pickedFile = null;
              });
              _showSnackBar('Form telah direset', Colors.blue);
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF0066CC),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Formulir Pengajuan Izin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lengkapi data berikut dengan benar',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Section Label
              const Text(
                'Data Pegawai & Proyek',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // ID Pegawai
              TextFormField(
                controller: _idPegawaiController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'ID Pegawai',
                  Icons.person_outline,
                ),
                validator: (v) => v!.isEmpty ? 'ID Pegawai wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // ID Proyek
              TextFormField(
                controller: _idProyekController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('ID Proyek', Icons.work_outline),
                validator: (v) => v!.isEmpty ? 'ID Proyek wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // Detail Izin Section
              const Text(
                'Detail Izin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Jenis Izin
              TextFormField(
                controller: _jenisIzinController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Jenis Izin (sakit/cuti/lainnya)',
                  Icons.category_outlined,
                ),
                validator: (v) => v!.isEmpty ? 'Jenis izin wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Subjek Izin
              TextFormField(
                controller: _subjekController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Subjek Izin',
                  Icons.title_outlined,
                ),
                validator: (v) => v!.isEmpty ? 'Subjek izin wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Tanggal Mulai
              InkWell(
                onTap: () => _selectDate(true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white60,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Mulai',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _tanggalMulai == null
                                  ? 'Pilih tanggal mulai izin'
                                  : DateFormat(
                                    'EEEE, dd MMMM yyyy',
                                    'id_ID',
                                  ).format(_tanggalMulai!),
                              style: TextStyle(
                                color:
                                    _tanggalMulai == null
                                        ? Colors.white54
                                        : Colors.white,
                                fontSize: 14,
                                fontWeight:
                                    _tanggalMulai == null
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal Selesai
              InkWell(
                onTap: () => _selectDate(false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        color: Colors.white60,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Selesai',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _tanggalSelesai == null
                                  ? 'Pilih tanggal selesai izin'
                                  : DateFormat(
                                    'EEEE, dd MMMM yyyy',
                                    'id_ID',
                                  ).format(_tanggalSelesai!),
                              style: TextStyle(
                                color:
                                    _tanggalSelesai == null
                                        ? Colors.white54
                                        : Colors.white,
                                fontSize: 14,
                                fontWeight:
                                    _tanggalSelesai == null
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Keterangan
              TextFormField(
                controller: _keteranganController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Keterangan',
                  Icons.notes_outlined,
                ),
                validator: (v) => v!.isEmpty ? 'Keterangan wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // Upload Section
              const Text(
                'Lampiran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Upload Button
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _pickedFile == null
                            ? const Color(0xFF0066CC).withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _pickedFile == null
                              ? const Color(0xFF0066CC).withOpacity(0.5)
                              : Colors.green.withOpacity(0.5),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _pickedFile == null
                                  ? const Color(0xFF0066CC).withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _pickedFile == null
                              ? Icons.cloud_upload_outlined
                              : Icons.check_circle_outline,
                          color:
                              _pickedFile == null
                                  ? const Color(0xFF0066CC)
                                  : Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pickedFile == null
                                  ? 'Upload File Surat Izin'
                                  : 'File Berhasil Dipilih',
                              style: TextStyle(
                                color:
                                    _pickedFile == null
                                        ? Colors.white
                                        : Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pickedFile == null
                                  ? 'Format: PNG, JPG, JPEG, PDF'
                                  : _pickedFile!.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _pickedFile == null ? Icons.attach_file : Icons.done,
                        color:
                            _pickedFile == null ? Colors.white60 : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF0066CC).withOpacity(0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Kirim Pengajuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
