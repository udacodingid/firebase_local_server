import 'package:firebase_database/firebase_database.dart';

class Sekolah {
  String? key;
  String? namaSekolah;
  String? alamat;
  String? tujuan;

  Sekolah(this.namaSekolah, this.alamat, this.tujuan);

  Sekolah.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        namaSekolah = snapshot.value['namaSekolah'],
        alamat = snapshot.value['alamat'],
        tujuan = snapshot.value['tujuan'];

  Map<String, dynamic> toJson() => {
        "key": key,
        "namaSekolah": namaSekolah,
        "alamat": alamat,
        "tujuan": tujuan
      };
}
