// definicja nowej klasy
class TopAnime {
  // final - po utworzeniu obiektu wartosc nie bedzie zmieniana
  final int id; // id anime
  final String img; // okladka anime
  final String engTitle; // ang tytul anime

  // required - parametr musi zostac przekazany przy tworzeniu obiektu
  TopAnime({
    required this.id, // id anime
    required this.img, // okladka anime
    required this.engTitle, // ang tytul anime
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "img": img,
      "engTitle": engTitle,
    };
  }

  factory TopAnime.fromMap(Map map) {
    return TopAnime(
      id: map["id"],
      engTitle: map["engTitle"],
      img: map["img"],
    );
  }
}