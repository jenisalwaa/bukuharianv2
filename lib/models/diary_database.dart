import 'package:bukuharianv2/models/diary.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DiaryDatabase extends ChangeNotifier {
  static late Isar isar;

  //inisialisasi database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [DiarySchema],
      directory: dir.path,
    );
  }

  //list diary
  final List<Diary> currentDiary = [];

  //create
  Future<void> addDiary(String textFromUser, DateTime date) async {
    //buat objek diary baru
    final newDiary = Diary()
        ..text = textFromUser
        ..date = date;

    //simpan ke db
    await isar.writeTxn(() => isar.diarys.put(newDiary));

    //fetch dari db
    fetchDiary();
  }

  //read
  Future<void> fetchDiary() async {
    List<Diary> fethedDiary = await isar.diarys.where().findAll();
    currentDiary.clear();
    currentDiary.addAll(fethedDiary);
    notifyListeners();
  }

  //update
  Future<void> updateDiary(int id, String newText) async {
    final dataLama = await isar.diarys.get(id);
    if (dataLama != null) {
      dataLama.text = newText;
      await isar.writeTxn(() => isar.diarys.put(dataLama));
      await fetchDiary();
    }
  }

  //delete
  Future<void> deleteDiary(int id) async {
    await isar.writeTxn(() => isar.diarys.delete(id));
    await fetchDiary();
  }
}
