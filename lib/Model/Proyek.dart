class Proyek {
  final int idProyek;
  final String namaProyek;
  final String lokasiProyek;
  final double latProyek;
  final double longProyek;
  final String deskripsi;

  Proyek({
    required this.idProyek,
    required this.namaProyek,
    required this.lokasiProyek,
    required this.latProyek,
    required this.longProyek,
    required this.deskripsi,
  });

  factory Proyek.fromJson(Map<String, dynamic> json) {
    return Proyek(
      idProyek: json['id_proyek'],
      namaProyek: json['nama_proyek'],
      lokasiProyek: json['lokasi_proyek'],
      deskripsi: json['deskripsi'],
      latProyek: double.parse(json['lat_proyek'].toString()),
      longProyek: double.parse(json['long_proyek'].toString()),
    );
  }
}
