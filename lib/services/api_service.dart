import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/top_anime.dart';
class TaskApiService {
  // linkacz do jikan api
  static const String baseUrl = "https://api.jikan.moe/v4";

  // pobieranie top anime do wyswietlenia na stronie glownej
  static Future<List<TopAnime>> fetchTopAnime() async {
    final response = await http.get(
      Uri.parse("$baseUrl/top/anime?sfw"),
    );
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

  // pobieranie szczegolowych informacji o konkretnym anime
  static Future<List<TopAnime>> fetchInfoAnime(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/anime/$id/full"),
    );
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
}