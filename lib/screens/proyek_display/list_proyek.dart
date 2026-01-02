import 'package:absensi_proyek/screens/from/from_absen_keluar.dart';
import 'package:absensi_proyek/screens/from/from_absen_masuk.dart';
import 'package:absensi_proyek/wigeds/error.dart';
import 'package:absensi_proyek/wigeds/menucard.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// Model Proyek
class Proyek {
  final int id;
  final String namaProyek;
  final String lokasiProyek;
  final String deskripsi;
  final double logProyek; // longitude
  final double latProyek; // latitude

  Proyek({
    required this.id,
    required this.namaProyek,
    required this.lokasiProyek,
    required this.deskripsi,
    required this.logProyek,
    required this.latProyek,
  });

  // Factory untuk parsing dari JSON API
  factory Proyek.fromJson(Map<String, dynamic> json) {
    return Proyek(
      id: json['id'] ?? 0,
      namaProyek: json['nama_proyek'] ?? '',
      lokasiProyek: json['lokasi_proyek'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      logProyek: double.parse(json['long_proyek'].toString()),
      latProyek: double.parse(json['lat_proyek'].toString()),
    );
  }
}

class ListProyekScreen extends StatefulWidget {
  const ListProyekScreen({Key? key}) : super(key: key);

  @override
  State<ListProyekScreen> createState() => _ListProyekScreenState();
}

class _ListProyekScreenState extends State<ListProyekScreen> {
  // Data dummy untuk demo (nanti ganti dengan data dari API)
  final List<Proyek> _proyekList = [
    Proyek(
      id: 1,
      namaProyek: 'Pembangunan Mall Central Park',
      lokasiProyek: 'Jakarta Barat, DKI Jakarta',
      deskripsi:
          'Proyek pembangunan mall dengan luas 50.000 m2 yang dilengkapi dengan fasilitas modern dan area parkir bertingkat',
      logProyek: 106.7903,
      latProyek: -6.1777,
    ),
    Proyek(
      id: 2,
      namaProyek: 'Renovasi Gedung Perkantoran',
      lokasiProyek: 'Sudirman, Jakarta Pusat',
      deskripsi:
          'Renovasi total gedung perkantoran 20 lantai termasuk sistem MEP dan interior modern',
      logProyek: 106.8229,
      latProyek: -6.2088,
    ),
    Proyek(
      id: 3,
      namaProyek: 'Konstruksi Jembatan Tol',
      lokasiProyek: 'Bekasi Timur, Jawa Barat',
      deskripsi:
          'Pembangunan jembatan layang tol sepanjang 2.5 km dengan teknologi pratekan',
      logProyek: 107.0156,
      latProyek: -6.2383,
    ),
    Proyek(
      id: 4,
      namaProyek: 'Perumahan Green Valley',
      lokasiProyek: 'Tangerang Selatan, Banten',
      deskripsi:
          'Pembangunan komplek perumahan eksklusif dengan konsep green living dan smart home system',
      logProyek: 106.6745,
      latProyek: -6.2914,
    ),
  ];

  List<Proyek> _filteredProyek = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProyek = _proyekList;
  }

  void _filterProyek(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProyek = _proyekList;
      } else {
        _filteredProyek =
            _proyekList.where((proyek) {
              return proyek.namaProyek.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  proyek.lokasiProyek.toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

Future<void> _openGoogleMaps(double lat, double long) async {
  final url = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$long',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ErrorSnackbar.show(context,('Tidak bisa membuka Google Maps'));
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Proyek',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2196F3).withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProyek,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau lokasi proyek...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2196F3),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterProyek('');
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredProyek.length} Proyek',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),

            // List Proyek
            Expanded(
              child:
                  _filteredProyek.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _filteredProyek.length,
                        itemBuilder: (context, index) {
                          return _buildProyekCard(_filteredProyek[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProyekCard(Proyek proyek) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showProyekDetail(proyek);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proyek.namaProyek,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                proyek.lokasiProyek,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Deskripsi
              Text(
                proyek.deskripsi,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Divider
              Container(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 12),

              // Koordinat GPS
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.navigation,
                      label: 'Lat',
                      value: proyek.latProyek.toStringAsFixed(4),
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.navigation,
                      label: 'Long',
                      value: proyek.logProyek.toStringAsFixed(4),
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _openMaps(proyek);
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Lihat Lokasi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showProyekDetail(proyek);
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada proyek ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba cari dengan kata kunci lain',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showProyekDetail(Proyek proyek) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Handle Bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: Color(0xFF2196F3),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Detail Proyek',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Nama Proyek
                        _buildDetailRow(
                          icon: Icons.apartment,
                          label: 'Nama Proyek',
                          value: proyek.namaProyek,
                          color: const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 16),

                        // Lokasi
                        _buildDetailRow(
                          icon: Icons.location_on,
                          label: 'Lokasi',
                          value: proyek.lokasiProyek,
                          color: const Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 16),

                        // Deskripsi
                        _buildDetailSection(
                          icon: Icons.description,
                          label: 'Deskripsi',
                          value: proyek.deskripsi,
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 16),

                        // Koordinat
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.gps_fixed,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Koordinat GPS',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Latitude',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          proyek.latProyek.toStringAsFixed(6),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Longitude',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          proyek.logProyek.toStringAsFixed(6),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openMaps(proyek);
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Buka di Maps'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width,
                     
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CardMenu(
                                title: 'Absen Keluar',
                                icon: Icons.logout,
                                color: Colors.red,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AbsenKeluarPage(),
                                      ),
                                    ),
                              ),
                              const SizedBox(width: 16),
                              CardMenu(
                                title: 'Absen Masuk',
                                icon: Icons.login,
                                color: Colors.green,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AbsenMasukPage(),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _openMaps(Proyek proyek) {
    // TODO: Implementasi buka Google Maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka maps: ${proyek.namaProyek}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
