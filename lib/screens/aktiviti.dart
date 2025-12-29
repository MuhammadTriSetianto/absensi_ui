import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Aktiviti extends StatefulWidget {
  const Aktiviti({Key? key}) : super(key: key);

  @override
  State<Aktiviti> createState() => _AktivitiState();
}

class _AktivitiState extends State<Aktiviti> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dummy data
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'absensi',
      'title': 'Peringatan Absensi',
      'message': 'Jangan lupa absen masuk hari ini',
      'time': DateTime.now().subtract(Duration(hours: 2)),
      'isRead': false,
      'icon': Icons.warning_rounded,
      'color': Color(0xFFFF6B35),
    },
    {
      'type': 'izin',
      'title': 'Izin Disetujui',
      'message': 'Pengajuan izin Anda telah disetujui oleh atasan',
      'time': DateTime.now().subtract(Duration(hours: 5)),
      'isRead': false,
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF00C897),
    },
    {
      'type': 'cuti',
      'title': 'Cuti Berhasil',
      'message': 'Pengajuan cuti tanggal 25-27 Desember telah disetujui',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'icon': Icons.beach_access_rounded,
      'color': Color(0xFF0066CC),
    },
    {
      'type': 'absensi',
      'title': 'Absensi Berhasil',
      'message': 'Absensi masuk pada 08:00 WIB berhasil dicatat',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF00C897),
    },
  ];

  final List<Map<String, dynamic>> activities = [
    {
      'type': 'absensi_masuk',
      'title': 'Absensi Masuk',
      'description': 'Proyek Website E-Commerce',
      'time': DateTime.now().subtract(Duration(hours: 2)),
      'icon': Icons.login_rounded,
      'color': Color(0xFF00C897),
    },
    {
      'type': 'izin',
      'title': 'Pengajuan Izin Sakit',
      'description': 'Status: Menunggu Persetujuan',
      'time': DateTime.now().subtract(Duration(hours: 5)),
      'icon': Icons.event_note_rounded,
      'color': Color(0xFFFF6B35),
    },
    {
      'type': 'cuti',
      'title': 'Pengajuan Cuti',
      'description': '25-27 Desember 2024 (3 hari)',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'icon': Icons.beach_access_rounded,
      'color': Color(0xFF0066CC),
    },
    {
      'type': 'absensi_pulang',
      'title': 'Absensi Pulang',
      'description': 'Proyek Mobile Banking',
      'time': DateTime.now().subtract(Duration(days: 1, hours: 8)),
      'icon': Icons.logout_rounded,
      'color': Color(0xFFFF6B35),
    },
    {
      'type': 'absensi_masuk',
      'title': 'Absensi Masuk',
      'description': 'Proyek Dashboard Analytics',
      'time': DateTime.now().subtract(Duration(days: 2)),
      'icon': Icons.login_rounded,
      'color': Color(0xFF00C897),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(time);
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Semua notifikasi ditandai sudah dibaca'),
          ],
        ),
        backgroundColor: const Color(0xFF00C897),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A3D5C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D5C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi & Aktivitas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white70, size: 18),
              label: const Text(
                'Tandai',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text('Notifikasi'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Aktivitas'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    if (notifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_off_rounded,
        title: 'Belum Ada Notifikasi',
        subtitle: 'Notifikasi Anda akan muncul di sini',
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, index);
        },
      ),
    );
  }

  Widget _buildActivityList() {
    if (activities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'Belum Ada Aktivitas',
        subtitle: 'Riwayat aktivitas Anda akan muncul di sini',
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final isLast = index == activities.length - 1;
          return _buildActivityCard(activity, isLast);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;

    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          setState(() {
            notification['isRead'] = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.transparent : notification['color'].withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isRead 
                    ? Colors.black.withOpacity(0.03)
                    : notification['color'].withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: const Color(0xFF0A3D5C),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(notification['time']),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activity['color'].withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 20,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        activity['color'].withOpacity(0.3),
                        activity['color'].withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A3D5C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(activity['time']),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}