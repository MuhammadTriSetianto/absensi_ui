import 'package:absensi_proyek/wigeds/buildheader.dart';
import 'package:absensi_proyek/wigeds/buildinfocard.dart';
import 'package:absensi_proyek/wigeds/buildprofilecard.dart';
import 'package:absensi_proyek/wigeds/buildsectiontitle.dart';
import 'package:absensi_proyek/wigeds/buildstatcard.dart';
import 'package:absensi_proyek/wigeds/buildstatitem.dart';
import 'package:absensi_proyek/wigeds/buildsactioncard.dart';
import 'package:flutter/material.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({Key? key}) : super(key: key);

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
              // Header
              BuildHeader(),

              // Content
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
                    child: Column(
                      children: [
                        // Profile Card
                        BuildProfileCard(),
                        const SizedBox(height: 20),

                        // Stats Card
                        BuildStatCard(),
                        const SizedBox(height: 20),

                        // Info Section
                        const BuildSectionProfile(title: 'Informasi'),
                        const SizedBox(height: 12),

                        BuildInfoCard(
                          title: 'Email',
                          value: 'korniawan.offi@example.com',
                          icon: Icons.email_rounded,
                          color: const Color(0xFF0066CC),
                        ),
                        const SizedBox(height: 12),

                        BuildInfoCard(
                          title: 'Nomor Handphone',
                          value: '+62 812-4785-486',
                          icon: Icons.phone_rounded,
                          color: const Color(0xFF00C897),
                        ),
                        const SizedBox(height: 12),

                        BuildInfoCard(
                          title: 'Alamat Tinggal',
                          value:
                              'Jl. Kol Doel Tobing Kelurahan Griya Pata Lawari Blok J. No 2 RT 35 RW 05 Kecamatan Sukarsih Kelurahan Tolong Betulu, Kota Palembang Sumatra Selatan',
                          icon: Icons.location_on_rounded,
                          color: const Color(0xFFFF6B35),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Action Section
                        const BuildSectionProfile(title: 'Aksi'),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.edit_rounded,
                                label: 'Edit Profil',
                                color: const Color(0xFF0066CC),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.description_rounded,
                                label: 'Rekap Absen',
                                color: const Color(0xFF00C897),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                icon: Icons.settings_rounded,
                                label: 'Pengaturan',
                                color: const Color(0xFFFF9800),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
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

                        // Info Text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF0066CC).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: const Color(0xFF0066CC),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Kelola informasi Anda untuk mengontrol, melindungi, dan mengamankan akun',
                                  style: TextStyle(
                                    color: const Color(0xFF0066CC),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Logout Button
                        _buildLogoutButton(),
                        const SizedBox(height: 20),
                      ],
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
        padding: const EdgeInsets.symmetric(vertical: 20),
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
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Show confirmation dialog
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
