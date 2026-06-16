// definicja nowej klasy
class InfoAnime {
  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  final int id;
  final String img;
  final String engTitle;
  final String jpTitle;
  final String status;
  final String aired;
  final String demographic;
  final String genre;
  final double score;
  final String studios;
  int progress;
  double? personalScore;

  // konstruktor
  InfoAnime({
    required this.id, // id anime
    required this.img, // okladka anime
    required this.engTitle, // ang tytul anime
    required this.jpTitle,
    required this.status,
    required this.aired,
    required this.demographic,
    required this.genre,
    required this.score,
    required this.studios,
    this.progress = 0,
    this.personalScore,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "img": img,
      "engTitle": engTitle,
      "jpTitle": jpTitle,
      "status": status,
      "aired": aired,
      "demographic": demographic,
      "genre": genre,
      "score": score,
      "studios": studios,
      "progress": progress,
      "personalScore": personalScore,
    };
  }

  factory InfoAnime.fromMap(Map map) {
    return InfoAnime(
      id: map["id"],
      img: map["img"],
      engTitle: map["engTitle"],
      jpTitle: map["jpTitle"],
      status: map["status"],
      aired: map["aired"],
      demographic: map["demographic"],
      genre: map["genre"],
      score: map["score"],
      studios: map["studios"],
      progress: map["progress"],
      personalScore: map["personalScore"],
    );
  }
}
