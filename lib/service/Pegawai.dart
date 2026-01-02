class Pegawai {
  final int id;
  final String idPegawai;
  final String name;
  final String email;
  final int idRole;
  final String? jabatan;

  Pegawai({
    required this.id,
    required this.idPegawai,
    required this.name,
    required this.email,
    required this.idRole,
    this.jabatan,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      id: json['id'],
      idPegawai: json['id_pegawai'],
      name: json['name'],
      email: json['email'],
      idRole: json['id_role'],
      jabatan: json['jabatan'],
    );
  }
}
