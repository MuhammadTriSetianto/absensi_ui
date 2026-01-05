import '../Model/Absensi.dart';
import '../Model/Izin.dart';

class RekapAbsensiResponse {
  final List<Absensi> absensi;
  final List<Izin> izin;
  final int totalCuti;

  RekapAbsensiResponse({
    required this.absensi,
    required this.izin,
    required this.totalCuti,
  });

  factory RekapAbsensiResponse.fromJson(Map<String, dynamic> json) {
    return RekapAbsensiResponse(
      absensi: (json['absensi'] as List)
          .map((e) => Absensi.fromJson(e))
          .toList(),
      izin: (json['izin'] as List)
          .map((e) => Izin.fromJson(e))
          .toList(),
      totalCuti: int.parse(json['total_cuti'].toString()),
    );
  }
}
