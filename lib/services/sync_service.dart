import 'api_service.dart';
import 'database_anime.dart';

class AnimeSyncService {
  static Future<void> loadInitialDataIfNeeded(int id) async {
// jeżeli lokalna baza ma już dane to nie pobieramy niczego
    if (!AnimeLocalDatabase.isEmpty()) {
      return;
    }
// jeżeli nie ma to pobierz dane z API i zapisz w bazie
    final tasks = await ApiService.fetchInfoAnime(id);
    await AnimeLocalDatabase.saveAnime(tasks);
  }
}