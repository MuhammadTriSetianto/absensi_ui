class GetUser {
  final String idPegawai;
  final String name;
  final String email;
  final String noHp;
  final String alamat;
  final int idRole;
  final String? image;

  GetUser({
    required this.idPegawai,
    required this.name,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.idRole,
    this.image,
  });
  // JSON → Object
factory GetUser.fromJson(Map<String, dynamic> json) {
  return GetUser(
    idPegawai: json['id_pegawai'].toString(),
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    noHp: json['no_hp'] ?? '',
    alamat: json['alamat'] ?? '',
    image: json['image'],
    idRole: int.tryParse(json['role'].toString()) ?? 0,
    );
  }
}
