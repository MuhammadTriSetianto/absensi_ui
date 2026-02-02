import '../Model/Proyek.dart';

class Izin {
  final int idIzin;
  final String jenisIzin;
  final String statusIzin;
  final String alasan;
  final String keterangan;
  final String tanggalMulai;
  final String tanggalSelesai;
  final DateTime createdAt;
  final int logDay;
  final Proyek? proyek;

  Izin({
    required this.idIzin,
    required this.jenisIzin,
    required this.alasan,
    required this.keterangan,
    required this.statusIzin,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.createdAt,
    required this.logDay,
    this.proyek,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      idIzin: json['id_izin'],
      jenisIzin: json['jenis_izin'],
      alasan: json['subjek_izin'],
      keterangan: json['keterangan_izin'],
      statusIzin: json['status_izin'],
      tanggalMulai: json['tanggal_mulai'],
      tanggalSelesai: json['tanggal_selesai'],
      createdAt: DateTime.parse(json['created_at']),
      logDay: json['log_day'], 
      proyek: json['proyek'] != null ? Proyek.fromJson(json['proyek']) : null,
    );
  }
}
