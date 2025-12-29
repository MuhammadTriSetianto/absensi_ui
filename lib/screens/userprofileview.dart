import 'package:flutter/material.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B66),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ===== CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Profile Picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name
                    const Text(
                      'Korniawan Prabowo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ID
                    const Text(
                      'KRY010 - Senior',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 20),

                    // Status Aktivitas
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Status Aktivitas',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const Spacer(),

                          const SizedBox(width: 6),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email
                    _buildInfoCard(
                      title: 'Email',
                      value: 'Korniawan.offi@example.com',
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 12),

                    // Nomor Handphone
                    _buildInfoCard(
                      title: 'Nomor Handphone',
                      value: '(+62) 0812-4785-486',
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 12),

                    // Alamat Tinggal
                    _buildInfoCard(
                      title: 'Alamat Tinggal',
                      value:
                          'Jl. Kol Doel Tobing Kelurahan Griya Pata Lawari Blok J. '
                          'No 2 RT 35 RW 05 Kecamatan Sukarsih Kelurahan Tolong Betulu, '
                          'Kota Palembang Sumatra Selatan',
                      icon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Info Text
                    Text(
                      'Kelola informasi anda untuk mengontrol, melindungi, '
                      'dan mengamankan akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Rekap Absen Button
                    _buildActionButton(
                      text: 'Rekap Absen',
                      icon: Icons.description_outlined,
                      onPressed: () {},
                    ),

                    const SizedBox(height: 12),

                    // Log Out Button
                    _buildActionButton(
                      text: 'Log Out',
                      icon: Icons.logout,
                      onPressed: () {},
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== INFO CARD =====
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== ACTION BUTTON =====
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0D3B66),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onPressed,
      ),
    );
  }
}
