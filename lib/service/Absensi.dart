import 'package:absensi_proyek/screens/proyek_display/list_proyek.dart';
import 'package:absensi_proyek/service/Pegawai.dart';

class Absensi {
  final int idAbsensi;
  final String idPegawai;
  final int idProyek;
  final String tanggalAbsensi;
  final String jamMasuk;
  final String jamPulang;
  final String keteranganAbsensi;
  final Pegawai pegawai;
  final Proyek proyek;

  Absensi({
    required this.idAbsensi,
    required this.idPegawai,
    required this.idProyek,
    required this.tanggalAbsensi,
    required this.jamMasuk,
    required this.jamPulang,
    required this.keteranganAbsensi,
    required this.pegawai,
    required this.proyek,
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
      pegawai: Pegawai.fromJson(json['pegawai']),
      proyek: Proyek.fromJson(json['proyek']),
    );
  }
}
