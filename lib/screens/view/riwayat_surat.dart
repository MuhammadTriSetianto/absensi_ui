import 'dart:convert';
import 'package:absensi_proyek/Model/Cuti.dart';
import 'package:absensi_proyek/Model/izin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatSuratScreens extends StatefulWidget {
  const RiwayatSuratScreens({super.key});

  @override
  State<RiwayatSuratScreens> createState() => _RiwayatSuratScreensState();
}

class _RiwayatSuratScreensState extends State<RiwayatSuratScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Izin>> _izinFuture;
  late Future<List<Cuti>> _cutiFuture;

  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _izinFuture = getIzinUser();
    _cutiFuture = getCutiUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= LOG DAY =================

  List<Map<String, dynamic>> _getLogDate(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return [];

    return data.map((item) {
      final startDate = DateTime.parse(item['tanggal_mulai']);
      final endDate = DateTime.parse(item['tanggal_selesai']);

      final logDay = endDate.difference(startDate).inDays + 1;

      return {...item, 'log_day': logDay};
    }).toList();
  }

  // ================= API IZIN =================

  Future<List<Izin>> getIzinUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/izin/bulan/sekarang'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final raw = List<Map<String, dynamic>>.from(body['data']);

      final withLogDay = _getLogDate(raw);

      return withLogDay.map((e) => Izin.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data izin');
    }
  }

  // ================= API CUTI =================

  Future<List<Cuti>> getCutiUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/cuti/bulan/sekarang'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final raw = List<Map<String, dynamic>>.from(body['data']);

      final withLogDay = _getLogDate(raw);

      return withLogDay.map((e) => Cuti.jsonParse(e)).toList();
    } else {
      throw Exception('Gagal mengambil data cuti');
    }
  }

  // ================= FILTER =================

  List<Izin> _filterIzin(List<Izin> list) {
    if (_selectedFilter == 'Semua') return list;

    return list.where((izin) {
      final status = izin.statusIzin.toLowerCase();

      switch (_selectedFilter) {
        case 'Disetujui':
          return status == 'disetujui';
        case 'Proses':
          return status == 'proses' || status == 'pending';
        case 'Ditolak':
          return status == 'ditolak';
        default:
          return true;
      }
    }).toList();
  }

  List<Cuti> _filterCuti(List<Cuti> list) {
    if (_selectedFilter == 'Semua') return list;

    return list.where((cuti) {
      final status = (cuti.statusCuti ?? '').toLowerCase();

      switch (_selectedFilter) {
        case 'Disetujui':
          return status == 'disetujui';
        case 'Proses':
          return status == 'proses' || status == 'pending';
        case 'Ditolak':
          return status == 'ditolak';
        default:
          return true;
      }
    }).toList();
  }

  // ================= HELPER UI =================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return const Color(0xFF4CAF50);
      case 'proses':
      case 'pending':
        return const Color(0xFFFF9800);
      case 'ditolak':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return Icons.check_circle;
      case 'proses':
      case 'pending':
        return Icons.pending;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

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
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${bulan[date.month]} ${date.year}';
    } catch (e) {
      return tanggal;
    }
  }

  String _getHari(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return date.day.toString().padLeft(2, '0');
    } catch (e) {
      return '';
    }
  }

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
        'DES',
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
          'Riwayat Surat',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildTabBar(),
                const SizedBox(height: 12),
                _buildFilterChips(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildIzinTab(), _buildCutiTab()],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('Surat Izin')),
            ),
          ),
          Tab(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text('Surat Cuti')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Semua', 'icon': Icons.list_alt},
      {'label': 'Disetujui', 'icon': Icons.check_circle_outline},
      {'label': 'Proses', 'icon': Icons.pending_outlined},
      {'label': 'Ditolak', 'icon': Icons.cancel_outlined},
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['label'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: Icon(
                filter['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : Colors.blue,
              ),
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter['label'] as String);
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIzinTab() {
    return FutureBuilder<List<Izin>>(
      future: _izinFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState('Gagal memuat data izin');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            'Tidak ada data surat izin',
            Icons.description_outlined,
          );
        }

        final filtered = _filterIzin(snapshot.data!);

        if (filtered.isEmpty) {
          return _buildEmptyState(
            'Tidak ada surat izin dengan status "$_selectedFilter"',
            Icons.filter_list_off,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _izinFuture = getIzinUser();
            });
          },
          child: Column(
            children: [
              _buildSummaryCard(filtered, 'izin'),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final izin = filtered[index];
                    return _buildIzinCard(izin);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCutiTab() {
    return FutureBuilder<List<Cuti>>(
      future: _cutiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState('Gagal memuat data cuti');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            'Tidak ada data surat cuti',
            Icons.event_available_outlined,
          );
        }

        final filtered = _filterCuti(snapshot.data!);

        if (filtered.isEmpty) {
          return _buildEmptyState(
            'Tidak ada surat cuti dengan status "$_selectedFilter"',
            Icons.filter_list_off,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _cutiFuture = getCutiUser();
            });
          },
          child: Column(
            children: [
              _buildSummaryCard(filtered, 'cuti'),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cuti = filtered[index];
                    return _buildCutiCard(cuti);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(List<dynamic> data, String type) {
    int disetujui = 0;
    int proses = 0;
    int ditolak = 0;
    int totalHari = 0;

    for (var item in data) {
      final status =
          type == 'izin'
              ? (item as Izin).statusIzin.toLowerCase()
              : (item as Cuti).statusCuti?.toLowerCase() ?? '';

      final hari =
          type == 'izin' ? (item as Izin).logDay : (item as Cuti).logDay ?? 0;

      if (status == 'disetujui') {
        disetujui++;
        totalHari += hari;
      } else if (status == 'proses' || status == 'pending') {
        proses++;
      } else if (status == 'ditolak') {
        ditolak++;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              type == 'izin'
                  ? [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)]
                  : [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (type == 'izin' ? Colors.purple : Colors.cyan).withOpacity(
              0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan ${type == 'izin' ? 'Izin' : 'Cuti'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalHari Hari',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Disetujui',
                  disetujui,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildSummaryItem('Proses', proses, Icons.pending),
              ),
              Expanded(
                child: _buildSummaryItem('Ditolak', ditolak, Icons.cancel),
              ),
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

  Widget _buildIzinCard(Izin izin) {
    final color = _getStatusColor(izin.statusIzin);
    final icon = _getStatusIcon(izin.statusIzin);
    final hariMulai = _getHari(izin.tanggalMulai);
    final bulanMulai = _getBulanSingkat(izin.tanggalMulai);
    final tanggalMulaiFormatted = _formatTanggal(izin.tanggalMulai);
    final tanggalSelesaiFormatted = _formatTanggal(izin.tanggalSelesai);

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
          onTap: () => _showIzinDetailDialog(izin),
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
                        hariMulai,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        bulanMulai,
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
                      Text(
                        izin.jenisIzin,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          Expanded(
                            child: Text(
                              '$tanggalMulaiFormatted - $tanggalSelesaiFormatted',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${izin.logDay} Hari',
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

                const SizedBox(width: 12),

                // Status Badge
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            izin.statusIzin,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCutiCard(Cuti cuti) {
    final color = _getStatusColor(cuti.statusCuti ?? '');
    final icon = _getStatusIcon(cuti.statusCuti ?? '');
    final hariMulai = _getHari(cuti.tanggalMulai ?? '');
    final bulanMulai = _getBulanSingkat(cuti.tanggalMulai ?? '');
    final tanggalMulaiFormatted = _formatTanggal(cuti.tanggalMulai ?? '');
    final tanggalSelesaiFormatted = _formatTanggal(cuti.tanggalSelesai ?? '');

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
          onTap: () => _showCutiDetailDialog(cuti),
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
                        hariMulai,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        bulanMulai,
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
                      Text(
                        cuti.subjekCuti ?? 'Cuti',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          Expanded(
                            child: Text(
                              '$tanggalMulaiFormatted - $tanggalSelesaiFormatted',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${cuti.logDay ?? 0} Hari',
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

                const SizedBox(width: 12),

                // Status Badge
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            cuti.statusCuti ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
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
            child: Icon(icon, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Data akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _izinFuture = getIzinUser();
                _cutiFuture = getCutiUser();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIzinDetailDialog(Izin izin) {
    final color = _getStatusColor(izin.statusIzin);
    final icon = _getStatusIcon(izin.statusIzin);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
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
                      'Detail Surat Izin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      Icons.description_outlined,
                      'Jenis Izin',
                      izin.jenisIzin,
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.subject_outlined,
                      'Alasan',
                      izin.alasan,
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.info_outline,
                      'Status',
                      izin.statusIzin,
                      color,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Tanggal Mulai',
                      _formatTanggal(izin.tanggalMulai),
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.event,
                      'Tanggal Selesai',
                      _formatTanggal(izin.tanggalSelesai),
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.access_time,
                      'Durasi',
                      '${izin.logDay} Hari',
                      Colors.grey[700]!,
                    ),
                    if (izin.proyek != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.work_outline,
                        'Proyek',
                        izin.proyek!.namaProyek ?? '-',
                        Colors.grey[700]!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.notes_outlined,
                      'Keterangan',
                      izin.keterangan.isNotEmpty ? izin.keterangan : '-',
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
          ),
    );
  }

  void _showCutiDetailDialog(Cuti cuti) {
    final color = _getStatusColor(cuti.statusCuti ?? '');
    final icon = _getStatusIcon(cuti.statusCuti ?? '');

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
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
                      'Detail Surat Cuti',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      Icons.description_outlined,
                      'Subjek Cuti',
                      cuti.subjekCuti ?? '-',
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.info_outline,
                      'Status',
                      cuti.statusCuti ?? '-',
                      color,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Tanggal Mulai',
                      _formatTanggal(cuti.tanggalMulai ?? ''),
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.event,
                      'Tanggal Selesai',
                      _formatTanggal(cuti.tanggalSelesai ?? ''),
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.access_time,
                      'Durasi',
                      '${cuti.logDay ?? 0} Hari',
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.work_outline,
                      'ID Proyek',
                      cuti.idProyek?.toString() ?? '-',
                      Colors.grey[700]!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.notes_outlined,
                      'Keterangan',
                      cuti.keteranganCuti != null &&
                              cuti.keteranganCuti!.isNotEmpty
                          ? cuti.keteranganCuti!
                          : '-',
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
          ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
