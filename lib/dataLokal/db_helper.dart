import 'package:flutterfirebase/dataLokal/model_sekolah.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tablePegawai = 'tablePegawai';
  final String columnId = 'id';
  final String columnNama = 'namaSekolah';
  final String columnPosisi = 'alamat';
  final String columnGaji = 'tujuan';

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'pegawai.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE tablePegawai($columnId INTEGER PRIMARY KEY,  $columnNama TEXT, $columnPosisi TEXT, $columnGaji INTEGER)');
  }

  Future<int> savePegawai(Pegawai pegawai) async {
    var dbClient = await db;
    var result = await dbClient.insert(tablePegawai, pegawai.toMap());
    print(result);
    return result;
  }

  Future<List> getAllPegawai() async {
    var dbClient = await db;
    var result = await dbClient.query(tablePegawai, columns: [
      columnId,
      columnNama,
      columnPosisi,
      columnGaji,
    ]);
    return result.toList();
  }

  Future<int> UpdatePegawai(Pegawai pegawai) async {
    var dbClient = await db;
    return await dbClient.update(tablePegawai, pegawai.toMap(),
        where: "$columnId = ?", whereArgs: [pegawai.id]);
  }

  Future<int> deletePegawai(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tablePegawai, where: '$columnId = ?', whereArgs: [id]);
  }
}