import 'package:absensi_proyek/screens/from/from_absen_keluar.dart';
import 'package:absensi_proyek/screens/from/from_absen_masuk.dart';
import 'package:absensi_proyek/wigeds/menucard.dart';
import 'package:flutter/material.dart';

class WigetAbsensi extends StatelessWidget {
  const WigetAbsensi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CardMenu(
          title: 'Absen Masuk',
          icon: Icons.login,
          color: Colors.green,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AbsenMasukPage()),
              ),
        ),
        const SizedBox(height: 16),
        CardMenu(
          title: 'Absen Keluar',
          icon: Icons.logout,
          color: Colors.red,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AbsenKeluarPage()),
              ),
        ),
      ],
    );
  }
}
