// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/dataLokal/model_sekolah.dart';
import 'package:flutterfirebase/res_sekolah.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dataLokal/db_helper.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  final GoogleSignIn? googleSignIn;
  HomeScreen({this.user, this.googleSignIn});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DatabaseHelper db = new DatabaseHelper();
  List<Pegawai> item = [];

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      print(result);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference? sekolahRef;
  List<Sekolah> _sekolahList = [];

  TextEditingController namaSekolah1 = TextEditingController();
  TextEditingController alamat1 = TextEditingController();
  TextEditingController tujuan1 = TextEditingController();

  StreamSubscription<Event>? _onSekolahAdd;
  StreamSubscription<ConnectivityResult>? subscription;

  void dataSql() {
    db.getAllPegawai().then((pegawai) {
      setState(() {
        item.clear();
        pegawai.forEach((element) {
          item.add(Pegawai.fromMap(element));
        });
      });
    });
  }

  Future sendOfflineData() async {
//    item.forEach((pegawai) async {
//      bool success = await savePegawai(pegawai);
//      db.deletePegawai(pegawai.id);
//    });

    await Future.forEach(item, (Pegawai pegawai) async {
      bool? success = await _addSekolah(
          pegawai.namaSekolah!, pegawai.alamat!, pegawai.tujuan!);
      if (success!) {
        db.deletePegawai(pegawai.id!);
      }
    });
    dataSql();
  }

  @override
  void initState() {
    sekolahRef = _database.reference().child("sekolah");
    _onSekolahAdd = sekolahRef?.onChildAdded.listen(_onAddSekolah);
    super.initState();
    dataSql();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.wifi:
          sendOfflineData();
          break;
        case ConnectivityResult.mobile:
          sendOfflineData();
          break;
        case ConnectivityResult.none:
          break;
      }
    });
  }

  void _onAddSekolah(Event event) {
    setState(() {
      _sekolahList.add(Sekolah.fromSnapshot(event.snapshot));
    });
  }

  Future<bool?> _addSekolah(
      String namaSekolah, String alamat, String tujuan) async {
    bool koneknsi = await checkConnectivity();
    if (koneknsi == true) {
      if (namaSekolah.length > 0 && alamat.length > 0 && tujuan.length > 0) {
        Sekolah sekolah = Sekolah(namaSekolah, alamat, tujuan);
        await sekolahRef?.push().set(sekolah.toJson());
        return true;
      } else {
        return false;
      }
    } else {
      {
        int inserted = await db.savePegawai(Pegawai(
            namaSekolah: namaSekolah1.text,
            alamat: alamat1.text,
            tujuan: tujuan1.text));
        if (inserted > 0) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (Route<dynamic> route) => false);
        } else {
          print('data gagal diinput');
        }
      }
    }
  }

  @override
  void dispose() {
    _onSekolahAdd?.cancel();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: ListView(
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: item.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${item[index].namaSekolah}'),
                  trailing: GestureDetector(
                      onTap: () {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       return AlertDialog(
                        //         content: Text(
                        //             'Yakin Mau Hapus data ${item[index].posisi}'),
                        //         actions: <Widget>[
                        //           FlatButton(
                        //               onPressed: () {
                        //                 db.deletePegawai(item[index].id);
                        //               },
                        //               child: Text('Yakin Dong')),
                        //         ],
                        //       );
                        //     });
                      },
                      child: Icon(Icons.delete)),
                );
              }),
          ListView.builder(
              shrinkWrap: true,
              itemCount: _sekolahList.length,
              itemBuilder: (context, index) {
                Sekolah data = _sekolahList[index];
                return Card(
                  child: ListTile(
                    title: Text('${data.namaSekolah}'),
                    subtitle: Text('${data.tujuan}'),
                  ),
                );
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          namaSekolah1.clear();
          alamat1.clear();
          tujuan1.clear();
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaSekolah1,
                        decoration: InputDecoration(
                            hintText: 'NAMA SEKOLAH',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.blue.withOpacity(0.3)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: alamat1,
                        decoration: InputDecoration(
                            hintText: 'ALAMAT',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.blue.withOpacity(0.3)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: tujuan1,
                        decoration: InputDecoration(
                            hintText: 'TUJUAN',
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.blue.withOpacity(0.3)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () {
                          _addSekolah(
                              namaSekolah1.text, alamat1.text, tujuan1.text);
                          Navigator.pop(context);
                        },
                        child: Text('SIMPAN'),
                      )
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
