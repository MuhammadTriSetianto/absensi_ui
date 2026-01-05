class GetUser {
  final String idPegawai;
  final String name;
  final String email;
  final String noHp;
  final String alamat;
  final String idRole;
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
    idPegawai: json['id_pegawai'].toString() ?? '',
    name: json['name'] ?? '',
    noHp: json['no_hp'] ?? '',
    email: json['email'] ?? '',
    image: json['image'] ?? '',
    alamat: json['alamat'] ?? '',
    idRole: json['id_role'] ?? '',

  );
}


  // Object → JSON (UNTUK POST / PUT)
  Map<String, dynamic> toJson() {
    return {
      'id_pegawai': idPegawai,
      'name': name,
      'no_hp': noHp,
      'email': email,
      'alamat': alamat,
    };
  }
}
