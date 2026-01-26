import 'dart:convert';

import 'package:absensi_proyek/screens/from/from_edit_profile.dart';
import 'package:absensi_proyek/Model/Absensi.dart';
import 'package:absensi_proyek/Model/RekapAbsensi.dart';
import 'package:absensi_proyek/Model/User.dart';
import 'package:absensi_proyek/screens/log_in_screen.dart';
import 'package:absensi_proyek/wigeds/buildheader.dart';
import 'package:absensi_proyek/wigeds/buildinfocard.dart';
import 'package:absensi_proyek/wigeds/buildprofilecard.dart';
import 'package:absensi_proyek/wigeds/buildsectiontitle.dart';
import 'package:absensi_proyek/wigeds/buildstatcard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({Key? key}) : super(key: key);

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late Future<RekapAbsensiResponse> rekapFuture;
  late Future<GetUser> getuser;
  String keyToken = '';
  @override
  void initState() {
    super.initState();
    getuser = getUser();
    rekapFuture = getRekapAbsensi();
    getToken();
  }

  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      keyToken = token.toString();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final keyToken = prefs.remove('token');
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/logout'),
      headers: {
        'Authorization': 'Bearer $keyToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<GetUser> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print ('token $token');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/profile'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GetUser.fromJson(data['data']);
    } else {
      final error =
          jsonDecode(response.body)['massage'] ?? 'Gagal mengambil data user';
      throw Exception(error);
    }
  }

  Future<RekapAbsensiResponse> getRekapAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/absen/user/semua'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return RekapAbsensiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil rekap absensi');
    }
  }

  int getTotalHadir(List<Absensi> absen) {
    int hadir = 0;
    for (var a in absen) {
      if (a.keteranganAbsensi == 'hadir') {
        hadir++;
      }
    }
    return hadir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A3D5C), Color(0xFF1A4D6D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              BuildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: FutureBuilder<GetUser>(
                      future: getuser,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text('Data user tidak ditemukan'),
                          );
                        }

                        final userData = snapshot.data!;
                      print ('data user ${userData.idRole}');
                        return Column(
                          children: [
                            BuildProfileCard(
                              name: userData.name,
                              image: userData.image,
                              idname: userData.idPegawai,
                              role: userData.idRole,
                            ),

                            const SizedBox(height: 20),

                            /// STAT CARD
                            FutureBuilder<RekapAbsensiResponse>(
                              future: rekapFuture,

                              builder: (context, snapshotAbsen) {
                                if (!snapshotAbsen.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                return BuildStatCard(
                                  totalHadir: getTotalHadir(
                                    snapshotAbsen.data!.absensi!,
                                  ),
                                  totalIzin: snapshotAbsen.data!.izin,
                                  totalCuti: snapshotAbsen.data!.totalCuti,
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            const BuildSectionProfile(title: 'Informasi'),
                            const SizedBox(height: 12),

                            BuildInfoCard(
                              title: 'Email',
                              value: userData.email,
                              icon: Icons.email_rounded,
                              color: const Color(0xFF0066CC),
                            ),

                            const SizedBox(height: 12),

                            BuildInfoCard(
                              title: 'Nomor Handphone',
                              value: userData.noHp,
                              icon: Icons.phone_rounded,
                              color: const Color(0xFF00C897),
                            ),

                            const SizedBox(height: 12),

                            BuildInfoCard(
                              title: 'Alamat Tinggal',
                              value: userData.alamat,
                              icon: Icons.location_on_rounded,
                              color: const Color(0xFFFF6B35),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 24),

                            const BuildSectionProfile(title: 'Aksi'),
                            const SizedBox(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: _buildActionCard(
                                    icon: Icons.edit_rounded,
                                    label: 'Edit Profil',
                                    color: const Color(0xFF0066CC),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditProfile(
                                                token: "Bearer $keyToken",
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(width: 24),
                                Expanded(
                                  child: _buildActionCard(
                                    icon: Icons.history_rounded,
                                    label: 'Riwayat Absensi',
                                    color: const Color(0xFF00C897),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionCard(
                                    icon: Icons.description_rounded,
                                    label: 'Status Pengajuan',
                                    color: const Color(0xFFFFC107),
                                    onTap: () {
                                    
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _buildActionCard(
                                    icon: Icons.help_rounded,
                                    label: 'Bantuan',
                                    color: const Color(0xFF9C27B0),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            _buildLogoutButton(),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height:100,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(icon, color: color, size: 28)),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: () {
          _logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Keluar dari Akun', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
