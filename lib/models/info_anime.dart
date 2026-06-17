// definicja nowej klasy
class InfoAnime {
  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  final int id;
  final String img;
  final String engTitle;
  final String jpTitle;
  final String synopsis;
  final String episodes; // double --> string
  final String status;
  final String aired;
  final String demographic;
  final String genre;
  final double score;
  final String studios;
  int progress;
  String? personalStatus;
  double? personalScore;
  bool favorite;


  // konstruktor
  InfoAnime({
    required this.id, // id anime
    required this.img, // okladka anime
    required this.engTitle, // ang tytul anime
    required this.jpTitle,
    required this.synopsis,
    required this.episodes,
    required this.status,
    required this.aired,
    required this.demographic,
    required this.genre,
    required this.score,
    required this.studios,
    this.progress = 0,
    this.personalStatus,
    this.personalScore,
    this.favorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "img": img,
      "engTitle": engTitle,
      "jpTitle": jpTitle,
      "synopsis": synopsis,
      "episodes": episodes,
      "status": status,
      "aired": aired,
      "demographic": demographic,
      "genre": genre,
      "score": score,
      "studios": studios,
      "progress": progress,
      "personalStatus": personalStatus,
      "personalScore": personalScore,
      "favorite": favorite,
    };
  }

  factory InfoAnime.fromMap(Map map) {
    return InfoAnime(
      id: map["id"],
      img: map["img"],
      engTitle: map["engTitle"],
      jpTitle: map["jpTitle"],
      synopsis: map["synopsis"],
      episodes: map["episodes"],
      status: map["status"],
      aired: map["aired"],
      demographic: map["demographic"],
      genre: map["genre"],
      score: map["score"],
      studios: map["studios"],
      progress: map["progress"],
      personalStatus: map["personalStatus"],
      personalScore: map["personalScore"],
      favorite: map["favorite"],
    );
  }
}
