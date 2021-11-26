class Pegawai {
  int? id;
  String? namaSekolah;
  String? alamat;
  String? tujuan;

  Pegawai({this.id, this.namaSekolah, this.alamat, this.tujuan});

  //Method untuk to Map
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    //cek id if != null masukkan id nya
    if (id != null) {
      map['id'] = id;
    }
    map['namaSekolah'] = namaSekolah;
    map['alamat'] = alamat;
    map['tujuan'] = tujuan;

    return map;
  }

  //constructor fromMap
  Pegawai.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.namaSekolah = map['namaSekolah'];
    this.alamat = map['alamat'];
    this.tujuan = map['tujuan'];
  }
}
