import 'dart:convert';
import 'package:anitrack/models/info_anime.dart';
import 'package:http/http.dart' as http;
import '../models/top_anime.dart';

class ApiService {
  // linkacz do jikan api
  static const String baseUrl = "https://api.jikan.moe/v4";

  // pobieranie top anime do wyswietlenia na stronie glownej
  static Future<List<TopAnime>> fetchTopAnime() async {
    final response = await http.get(Uri.parse("$baseUrl/top/anime?sfw"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List animes = data["data"];
      return animes.map((anime) {
        return TopAnime(
          id: anime["mal_id"],
          engTitle: anime["title_english"] ?? anime["title"] ?? "No Title",
          img: anime["images"]["jpg"]["image_url"],
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych"); // blad jezeli kod inny niz 200
    }
  }

  // pobieranie szczegolowych informacji o konkretnym POJEDYNCZYM anime
  static Future<InfoAnime> fetchInfoAnime(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/anime/$id/full"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final Map<String, dynamic> anime = data["data"]; // pojedynczy obiekt anime w polu data

      // pobiera liste gatunkow (bo moze byc ich kilka) i potem laczy a lancuch oddzielajac je przecinkami
      final List genresList = anime["genres"] ?? [];
      final String genresString = genresList.map((g) => g["name"]).join(", ");

      final List demoList = anime["demographics"] ?? [];
      final String demoString = demoList.map((d) => d["name"]).join(", ");

      final List studiosList = anime["studios"] ?? [];
      final String studiosString = studiosList.map((s) => s["name"]).join(", ");

        return InfoAnime(
          id: anime["mal_id"],
          engTitle: anime["title_english"] ?? anime["title"] ?? "No Title",
          img: anime["images"]["jpg"]["image_url"],
          jpTitle: anime["title_japanese"] ?? "No Title",
          status: anime["status"] ?? "Unknown",
          aired: anime["aired"]["string"] ?? "Unknown",
          demographic: demoString.isEmpty ? "None" : demoString,
          genre: genresString.isEmpty ? "None" : genresString,
          score: (anime["score"] ?? 0.0).toDouble(), //
          studios: studiosString.isEmpty ? "Unknown" : studiosString
        );
    } else {
      throw Exception("Błąd pobierania danych"); // blad jezeli kod inny niz 200
    }
  }
}
