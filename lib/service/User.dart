class GetUser {
  final String idPegawai;
  final String name;
  final String noHp;
  final String email;
  final String alamat;
  final int id_role;

  GetUser({
    required this.idPegawai,
    required this.name,
    required this.noHp,
    required this.id_role,
    required this.email,
    required this.alamat,
  });

  // JSON → Object
 factory GetUser.fromJson(Map<String, dynamic> json) {
  return GetUser(
    idPegawai: json['id_pegawai'].toString() ?? '',
    name: json['name'] ?? '',
    noHp: json['no_hp'] ?? '',
    email: json['email'] ?? '',
    alamat: json['alamat'] ?? '',
    id_role: json['id_role'] ?? '',

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
