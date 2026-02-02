class Cuti {
 final String? idCuti;
 final int? idProyek;
 final String? subjekCuti;
 final String? keteranganCuti;
 final String? tanggalMulai;
 final String? tanggalSelesai;
 final String? statusCuti;
 final int? logDay;
 final DateTime? createdDate;

  Cuti({
    this.idCuti,
    this.idProyek,
    this.subjekCuti,
    this.keteranganCuti,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.statusCuti,
    this.logDay,
    this.createdDate
  });

factory Cuti.jsonParse(Map<String, dynamic> json) {
  return Cuti(
    idCuti: json['id_cuti'],
    idProyek: json['id_proyek'],
    subjekCuti: json['subjek_cuti'],
    keteranganCuti: json['keterangan_cuti'],
    tanggalMulai: json['tanggal_mulai'],
    tanggalSelesai: json['tanggal_selesai'],
    statusCuti: json['status_cuti'],
    logDay: json['log_day'],  
    createdDate: json['created_date'] != null
        ? DateTime.parse(json['created_date'])
        : null,
  );
}


}