import 'package:anitrack/models/info_anime.dart';
import 'package:hive_ce/hive.dart';

class AnimeLocalDatabase {
  // 1. Zmieniamy typ Boxa na <Map> zamiast <InfoAnime>
  static Box<Map> get _box => Hive.box<Map>("userAnimeBox");

  // 2. Przy pobieraniu mapujemy każdą Mapę z powrotem na obiekt InfoAnime
  static List<InfoAnime> getTrackedAnime() {
    return _box.values.map((map) => InfoAnime.fromMap(map)).toList();
  }

  // 3. Pobieranie jednego elementu i konwersja z Map
  static InfoAnime? getAnimeById(int id) {
    final map = _box.get(id);
    if (map == null) return null;
    return InfoAnime.fromMap(map);
  }

  // 4. Przy zapisie wywołujemy Twoją metodę .toMap()
  static Future<void> saveAnime(InfoAnime anime) async {
    await _box.put(anime.id, anime.toMap());
  }

  static Future<void> deleteAnime(int id) async {
    await _box.delete(id);
  }

  static bool isEmpty() {
    return _box.isEmpty;
  }
}