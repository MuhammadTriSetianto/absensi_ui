import 'dart:convert';

import 'package:absensi_proyek/Model/Absensi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatAbsenScreen extends StatefulWidget {
  const RiwayatAbsenScreen({super.key});

  @override
  State<RiwayatAbsenScreen> createState() => _RiwayatAbsenScreenState();
}

class _RiwayatAbsenScreenState extends State<RiwayatAbsenScreen> {
  late Future<List<Absensi>> getabsen;

  Future<List<Absensi>> getAbsen() async {
    final pres = await SharedPreferences.getInstance();
    final token = pres.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/absen/user/bulan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final List<Map<String, dynamic>> list =
            List<Map<String, dynamic>>.from(data['data']);

        return list.map((e) => Absensi.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error getAbsen: $e');
    }

    return [];
  }

  @override
  void initState() {
    super.initState();
    getabsen = getAbsen();
  }

  // Helper untuk mendapatkan icon berdasarkan keterangan
  IconData _getAbsenIcon(String keterangan) {
    final ket = keterangan.toLowerCase();
    if (ket.contains('hadir') || ket.contains('masuk')) {
      return Icons.check_circle;
    } else if (ket.contains('sakit')) {
      return Icons.local_hospital;
    } else if (ket.contains('izin')) {
      return Icons.event_note;
    } else if (ket.contains('alpha') || ket.contains('tidak hadir')) {
      return Icons.cancel;
    } else if (ket.contains('cuti')) {
      return Icons.beach_access;
    } else if (ket.contains('terlambat')) {
      return Icons.access_time;
    }
    return Icons.assignment;
  }

  // Helper untuk mendapatkan warna berdasarkan keterangan
  Color _getAbsenColor(String keterangan) {
    final ket = keterangan.toLowerCase();
    if (ket.contains('hadir') || ket.contains('masuk')) {
      return const Color(0xFF4CAF50); // Hijau
    } else if (ket.contains('sakit')) {
      return const Color(0xFF2196F3); // Biru
    } else if (ket.contains('izin')) {
      return const Color(0xFF9C27B0); // Ungu
    } else if (ket.contains('alpha') || ket.contains('tidak hadir')) {
      return const Color(0xFFF44336); // Merah
    } else if (ket.contains('cuti')) {
      return const Color(0xFF00BCD4); // Cyan
    } else if (ket.contains('terlambat')) {
      return const Color(0xFFFF9800); // Orange
    }
    return Colors.grey;
  }

  // Helper untuk format tanggal
  String _formatTanggal(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      final bulan = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Oct',
        'Nov',
        'Des'
      ];
      final hari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      return '${hari[date.weekday % 7]}, ${date.day} ${bulan[date.month]} ${date.year}';
    } catch (e) {
      return tanggal;
    }
  }

  // Helper untuk mendapatkan hari dari tanggal
  String _getHari(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return date.day.toString().padLeft(2, '0');
    } catch (e) {
      return '';
    }
  }

  // Helper untuk mendapatkan bulan singkat
  String _getBulanSingkat(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      final bulan = [
        '',
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MEI',
        'JUN',
        'JUL',
        'AGU',
        'SEP',
        'OKT',
        'NOV',
        'DES'
      ];
      return bulan[date.month];
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              // Aksi untuk filter (bisa ditambahkan nanti)
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Absensi>>(
        future: getabsen,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final absensi = snapshot.data ?? [];
          print("absensi $absensi");
          
          if (absensi.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                getabsen = getAbsen();
              });
            },
            child: Column(
              children: [
                // Header Summary
                _buildSummaryCard(absensi),
                
                // List Absensi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: absensi.length,
                    itemBuilder: (context, index) {
                      final absen = absensi[index];
                      return _buildAbsenCard(absen);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Absensi> absensi) {
    // Hitung ringkasan
    int hadir = 0;
    int izin = 0;
    int sakit = 0;
    int alpha = 0;

    for (var absen in absensi) {
      final ket = absen.keteranganAbsensi.toLowerCase();
      if (ket.contains('hadir') || ket.contains('masuk')) {
        hadir++;
      } else if (ket.contains('izin')) {
        izin++;
      } else if (ket.contains('sakit')) {
        sakit++;
      } else if (ket.contains('alpha') || ket.contains('tidak hadir')) {
        alpha++;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Bulan Ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Hadir', hadir, Icons.check_circle),
              _buildSummaryItem('Izin', izin, Icons.event_note),
              _buildSummaryItem('Sakit', sakit, Icons.local_hospital),
              _buildSummaryItem('Alpha', alpha, Icons.cancel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAbsenCard(Absensi absen) {
    final color = _getAbsenColor(absen.keteranganAbsensi);
    final icon = _getAbsenIcon(absen.keteranganAbsensi);
    final hari = _getHari(absen.tanggalAbsensi);
    final bulan = _getBulanSingkat(absen.tanggalAbsensi);
    final tanggalFormatted = _formatTanggal(absen.tanggalAbsensi);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Aksi ketika card di-tap (bisa ditambahkan detail)
            _showDetailDialog(absen);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Kalender Mini
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hari,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        bulan,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              absen.keteranganAbsensi,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tanggalFormatted,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Proyek #${absen.idProyek}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Data absensi kosong',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada riwayat absensi bulan ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat data absensi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                getabsen = getAbsen();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Absensi absen) {
    final color = _getAbsenColor(absen.keteranganAbsensi);
    final icon = _getAbsenIcon(absen.keteranganAbsensi);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                'Detail Absensi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                Icons.info_outline,
                'Status',
                absen.keteranganAbsensi,
                color,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.calendar_today,
                'Tanggal',
                _formatTanggal(absen.tanggalAbsensi),
                Colors.grey[700]!,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.work_outline,
                'ID Proyek',
                absen.idProyek.toString(),
                Colors.grey[700]!,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}