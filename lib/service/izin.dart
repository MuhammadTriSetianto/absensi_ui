import 'Proyek.dart';

class Izin {
  final int idIzin;
  final String jenisIzin;
  final String statusIzin;
  final String tanggalMulai;
  final String tanggalSelesai;
  final Proyek proyek;

  Izin({
    required this.idIzin,
    required this.jenisIzin,
    required this.statusIzin,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.proyek,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      idIzin: json['id_izin'],
      jenisIzin: json['jenis_izin'],
      statusIzin: json['status_izin'],
      tanggalMulai: json['tanggal_mulai'],
      tanggalSelesai: json['tanggal_selesai'],
      proyek: Proyek.fromJson(json['proyek']),
    );
  }
}
