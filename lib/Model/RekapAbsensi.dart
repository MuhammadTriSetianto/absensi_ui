import '../Model/Absensi.dart';


class RekapAbsensiResponse {
  final List<Absensi> absensi;
  final int izin;
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
      izin: int.parse(json['izin'].toString()),
      totalCuti: int.parse(json['total_cuti'].toString()),
    );
  }
}
