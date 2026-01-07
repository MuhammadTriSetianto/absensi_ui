class Notifikasi {
  final String idUser;
  final String idNotifikasi;
  final String judul;
   String status;
  final String isi;
  final DateTime tanggal;

  Notifikasi({
    required this.idUser,
    required this.idNotifikasi,
    required this.judul,
    required this.isi,
    required this.status,
    required this.tanggal,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      idUser: json['id_user'],
      idNotifikasi: json['id'].toString(),
      judul: json['judul'],
      isi: json['isi'],
      status: json['status'],
      tanggal: DateTime.parse(json['created_at']),
    );
  }
}
