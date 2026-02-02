import 'package:absensi_proyek/Model/Proyek.dart';
import 'package:absensi_proyek/screens/view/list_proyek.dart';
import 'package:absensi_proyek/Model/Pegawai.dart';

class Absensi {
  final int idAbsensi;
  final String idPegawai;
  final int idProyek;
  final String tanggalAbsensi;
  final String? jamMasuk;
  final String? jamPulang;
  final String keteranganAbsensi;
  final Pegawai? pegawai;
  final Proyek? proyek;

  Absensi({
    required this.idAbsensi,
    required this.idPegawai,
    required this.idProyek,
    required this.tanggalAbsensi,
    this.jamMasuk,
    this.jamPulang,
    required this.keteranganAbsensi,
    this.pegawai,
    this.proyek,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      idAbsensi: json['id_absensi'],
      idPegawai: json['id_pegawai'],
      idProyek: json['id_proyek'],
      tanggalAbsensi: json['tanggal_absensi'],
      jamMasuk: json['jam_masuk'],
      jamPulang: json['jam_pulang'],
      keteranganAbsensi: json['keterangan_absensi'],
      pegawai:
          json['pegawai'] != null ? Pegawai.fromJson(json['pegawai']) : null,

      proyek: json['proyek'] != null ? Proyek.fromJson(json['proyek']) : null,  
    );
  }
}
