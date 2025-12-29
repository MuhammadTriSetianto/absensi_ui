import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class FormCutiScreen extends StatefulWidget {
  const FormCutiScreen({Key? key}) : super(key: key);

  @override
  State<FormCutiScreen> createState() => _FormCutiScreenState();
}

class _FormCutiScreenState extends State<FormCutiScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _idKaryawanController = TextEditingController();
  final TextEditingController _idProyekController = TextEditingController();
  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  PlatformFile? _pickedFile;

  @override
  void dispose() {
    _idKaryawanController.dispose();
    _idProyekController.dispose();
    _subjekController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  // ================= LOGIC =================

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isStart ? DateTime.now() : (_tanggalMulai ?? DateTime.now()),
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
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        final file = result.files.single;

        if (file.size > 2 * 1024 * 1024) {
          _showSnackBar('Ukuran file maksimal 2MB', Colors.orange);
          return;
        }

        setState(() => _pickedFile = file);
      }
    } catch (_) {
      _showSnackBar('Gagal memilih file', Colors.red);
    }
  }

  int _durasiCuti() {
    if (_tanggalMulai == null || _tanggalSelesai == null) return 0;
    return _tanggalSelesai!.difference(_tanggalMulai!).inDays + 1;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalMulai == null || _tanggalSelesai == null || _pickedFile == null) {
      _showSnackBar('Semua field wajib diisi', Colors.orange);
      return;
    }

    final payload = {
      'id_karyawan': _idKaryawanController.text,
      'id_proyek': int.parse(_idProyekController.text),
      'subjek': _subjekController.text,
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(_tanggalMulai!),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(_tanggalSelesai!),
      'keterangan': _keteranganController.text,
      'durasi': _durasiCuti(),
      'file_name': _pickedFile!.name,
      'file_path': _pickedFile!.path,
    };

    debugPrint(payload.toString());
    _showSnackBar('Pengajuan cuti berhasil dikirim!', Colors.green);

    // Reset form
    Future.delayed(const Duration(seconds: 2), () {
      _formKey.currentState?.reset();
      setState(() {
        _tanggalMulai = null;
        _tanggalSelesai = null;
        _pickedFile = null;
      });
    });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle_outline : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 14))),
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

  // ================= UI =================

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
          'Form Cuti',
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
            tooltip: 'Reset Form',
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
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 28),

              // Section: Identitas
              _buildSectionHeader(Icons.badge_outlined, 'Identitas Karyawan & Proyek'),
              const SizedBox(height: 12),

              _textField(
                _idKaryawanController,
                'ID Karyawan',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _textField(
                _idProyekController,
                'ID Proyek',
                Icons.work_outline,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 28),

              // Section: Detail Cuti
              _buildSectionHeader(Icons.event_note_outlined, 'Detail Pengajuan Cuti'),
              const SizedBox(height: 12),

              _textField(
                _subjekController,
                'Subjek Cuti',
                Icons.title_outlined,
              ),
              const SizedBox(height: 16),

              // Tanggal Row
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                      'Tanggal Mulai',
                      _tanggalMulai,
                      Icons.calendar_today_outlined,
                      () => _selectDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datePicker(
                      'Tanggal Selesai',
                      _tanggalSelesai,
                      Icons.event_outlined,
                      () => _selectDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info Durasi
              if (_tanggalMulai != null && _tanggalSelesai != null)
                _buildDurasiInfo(),

              if (_tanggalMulai != null && _tanggalSelesai != null)
                const SizedBox(height: 16),

              _textField(
                _keteranganController,
                'Keterangan Cuti',
                Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              // Section: Upload
              _buildSectionHeader(Icons.attach_file, 'Lampiran Surat Cuti'),
              const SizedBox(height: 12),

              _uploadButton(),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF0066CC).withOpacity(0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Ajukan Cuti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0066CC).withOpacity(0.25),
            const Color(0xFF0066CC).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0066CC).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066CC).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.beach_access_rounded,
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
                  'Pengajuan Cuti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Isi formulir dengan lengkap dan benar',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0066CC).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0066CC), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDurasiInfo() {
    final durasi = _durasiCuti();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0066CC).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0066CC).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Color(0xFF0066CC),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Durasi Cuti',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$durasi Hari',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              durasi == 1 ? '1 hari' : '$durasi hari',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
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
      ),
      validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _datePicker(
    String label,
    DateTime? date,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white60, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date == null ? 'Pilih tanggal' : DateFormat('dd MMM yyyy').format(date),
              style: TextStyle(
                color: date == null ? Colors.white54 : Colors.white,
                fontSize: 13,
                fontWeight: date == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadButton() {
    final isUploaded = _pickedFile != null;

    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isUploaded
              ? LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF0066CC).withOpacity(0.2),
                    const Color(0xFF0066CC).withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? Colors.green.withOpacity(0.5)
                : const Color(0xFF0066CC).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green : const Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (isUploaded ? Colors.green : const Color(0xFF0066CC))
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUploaded ? 'File Berhasil Dipilih' : 'Upload Surat Cuti',
                    style: TextStyle(
                      color: isUploaded ? Colors.green[300] : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded
                        ? _pickedFile!.name
                        : 'JPG, JPEG, PNG, PDF (Max 2MB)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.done_all_rounded : Icons.arrow_forward_ios_rounded,
              color: isUploaded ? Colors.green : Colors.white60,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}