import 'api_service.dart';
import 'local_database.dart';

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
// jeżeli lokalna baza ma już dane to nie pobieramy niczego
    if (!AnimeLocalDatabase.isEmpty()) {
      return;
    }
// jeżeli nie ma to pobierz dane z API i zapisz w bazie
    final tasks = await TaskApiService.fetchTopAnime();
    await AnimeLocalDatabase.saveTasks(tasks);
  }
}