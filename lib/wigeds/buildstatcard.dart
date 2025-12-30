import 'package:absensi_proyek/wigeds/buildstatitem.dart';
import 'package:flutter/material.dart';

class BuildStatCard extends StatelessWidget {
  const BuildStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: const Color(0xFF0066CC),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Status Aktivitas Bulan Ini',
                style: TextStyle(
                  color: Color(0xFF0A3D5C),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BuildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Hadir',
                  value: '22',
                  color: const Color(0xFF00C897),
                ),
              ),
              Expanded(
                child: BuildStatItem(
                  icon: Icons.event_note_rounded,
                  label: 'Izin',
                  value: '2',
                  color: const Color(0xFFFF6B35),
                ),
              ),
              Expanded(
                child: BuildStatItem(
                  icon: Icons.beach_access_rounded,
                  label: 'Cuti',
                  value: '1',
                  color: const Color(0xFF0066CC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}