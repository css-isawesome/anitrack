import 'package:hive_ce/hive.dart';
import '../models/info_anime.dart';

class AnimeLocalDatabase {
  // pobieramy box otworzony przez nas w main
  static Box get _box => Hive.box("animes");

  static List<InfoAnime> getTasks() {
    // zwraca wszystkie wartości zapisane w boxie
    return _box.values.map((item) {
      return InfoAnime.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<void> saveTasks(List<InfoAnime> tasks) async {
    await _box.clear();
    // zapisuje zadanie pod kluczem równym jego id
    for (final task in tasks) {
      await _box.put(task.id, task.toMap());
    }
  }

  static Future<void> addTask(InfoAnime task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<void> updateTask(InfoAnime task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<void> deleteTask(int id) async {
    // usuwa zadanie zapisane pod danym kluczem
    await _box.delete(id);
  }
  static Future<void> deleteAllTasks() async {
    await _box.clear();
  }
  static bool isEmpty() {
    return _box.isEmpty;
  }
}