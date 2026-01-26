import 'package:absensi_proyek/Model/Pegawai.dart';
import 'package:absensi_proyek/Model/Proyek.dart';

class UserProyek {
  String? id_pegawai;
  int? id_proyek;
  Pegawai? pegawai;
  Proyek? proyek;

  UserProyek(this.id_pegawai, this.id_proyek, this.pegawai, this.proyek);
  
  factory UserProyek.fromJson(Map<String, dynamic> json) {
    return UserProyek(
      json['id_pegawai']?.toString(),
      json['id_proyek'] != null
          ? int.parse(json['id_proyek'].toString())
          : null,
      json['pegawai'] != null ? Pegawai.fromJson(json['pegawai']) : null,
      json['proyek'] != null ? Proyek.fromJson(json['proyek']) : null,
    );
  }
}
