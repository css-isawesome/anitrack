import 'package:anitrack/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '/models/top_anime.dart';
import '/models/info_anime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<TopAnime>("topAnimeBox");
  await Hive.openBox<InfoAnime>("userAnimeBox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniTrack',
      theme: ThemeData.dark(),
      home: MainAnimeListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainAnimeListScreen extends StatefulWidget {
  const MainAnimeListScreen({super.key});

  @override
  State<MainAnimeListScreen> createState() => _MainAnimeListScreenState();
}

class _MainAnimeListScreenState extends State<MainAnimeListScreen> {
  final ScrollController _scrollController = ScrollController();

  List<TopAnime> _animeList = []; // pobrane anime
  int _currentPage = 1; // sledzenie aktualnej strony
  bool _isLoading = false; // czy trwa pobieranie anime

  @override
  void initState() {
    super.initState();
    _loadMoreAnime();

    // scrollowanie
    _scrollController.addListener(() {
      // jesli uzytkownik przewinal do 90% dlugosci ekranu i nie trwa ladowanie
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !_isLoading) {
        _loadMoreAnime();
      }
    });
  }

  // funkcja ktora pobiera wiecej anime
  Future<void> _loadMoreAnime() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<TopAnime> newAnime = await ApiService.fetchTopAnime(
        page: _currentPage,
      );

      setState(() {
        _animeList.addAll(
          newAnime,
        ); // dodawanie nowych anime do istniejacej listy
        _currentPage++; // zwiekszenie licznika
      });
    } catch (e) {
      // na wypadek errora - snackbar z komunikatem o bledze
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nie udało się pobrać danych: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // czyszczenie kontrolera na wypadek nisczenia ekranu zeby nie doszlo do wycieku pamieci

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      // ciemne tlo ciala ekranu
      appBar: AppBar(
        title: const Text("AniTrack"),
        backgroundColor: Colors.black45,
        foregroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
            onPressed: () {
              // przejscie do ekranu z profilem uzytkownika
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          ),
        ],
      ),
      // jesli lista jest pusta i ladujemy - kolko ladowania, inaczej pokazuje anime
      body: _animeList.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              // kontroler przewijania
              padding: const EdgeInsets.all(12.0),
              itemCount: _animeList.length + (_isLoading ? 1 : 0),
              //
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolumny
                crossAxisSpacing: 12.0, // odstep poziomy miedzy kolumnami
                mainAxisSpacing: 16.0, // odstep pionowy miedzy wierszami
                childAspectRatio:
                    0.65, // stosunek szerokosci do wysokosci okladki zeby sie zmiescilo
              ),
              itemBuilder: (context, index) {
                // jesli ostatni element - pokaz kolko
                if (index == _animeList.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final anime = _animeList[index];
                // klikniecie w szczegoly anime
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoAnimeScreen(
                          animeId: anime.id,
                          animeTitle: anime.engTitle,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // okladka anime
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          // zaokraglone rogi okladki
                          child: Image.network(
                            anime.img,
                            fit: BoxFit.cover,
                            // wypelnienie calego grida przez okladke
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8.0, // odstep miedzy zdjeciem a tekstem
                      ),
                      // tytul pod spodem
                      Text(
                        anime.engTitle,
                        maxLines: 2,
                        // max 2 linijki tekstu
                        overflow: TextOverflow.ellipsis,
                        // jesli tytul za dlugi to doda kropki
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: Colors.black45,
        foregroundColor: Colors.grey,
      ),
      body: const Center(child: Text("Tutaj będą statystyki, postęp i oceny.")),
    );
  }
}

class InfoAnimeScreen extends StatefulWidget {
  final int animeId; // id pobrane z ekranu MainAnimeListScreen
  final String animeTitle;

  const InfoAnimeScreen({
    super.key,
    required this.animeId,
    required this.animeTitle,
  });

  @override
  State<InfoAnimeScreen> createState() => _InfoAnimeScreenState();
}

class _InfoAnimeScreenState extends State<InfoAnimeScreen> {
  late Future<InfoAnime> _animeInfoFuture;

  @override
  void initState() {
    super.initState();
    // pobranie szczegolowych informacji o anime
    _animeInfoFuture = ApiService.fetchInfoAnime(widget.animeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: Text(widget.animeTitle),
        backgroundColor: Colors.black45,
        foregroundColor: Colors.grey,
      ),
      body: FutureBuilder<InfoAnime>(
        future: _animeInfoFuture,
        builder: (context, snapshot) {
          // ladowanie
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error handling
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Coś poszło nie tak: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // jesli suckes
          final anime = snapshot.data!;

          return SingleChildScrollView(
            // scrollowanie ekraniu
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // obrazek okladki
                Padding(
                  padding: const EdgeInsets.all(12.0), // padding wokol okladki
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    // zaokraglone rogi
                    child: SizedBox(
                      width: double.infinity,
                      // rozciagniecie na pelna szerokosc
                      height: 350,
                      // sztywna wysokosc ktora zmusi obrazek do przyciecia
                      child: Image.network(
                        anime.img,
                        fit: BoxFit.cover, // uciecie gory i dolu
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // tytul angielski
                          Text(
                            anime.engTitle,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4.0),

                          // tytul japonski
                          Text(
                            anime.jpTitle,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],

                      ),

                      // dodatkowe informacje
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32.0),
                          Text(
                            "Synopsis",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Divider(height: 32.0),
                          // linia do oddzielenia ekranu
                          Text(anime.synopsis),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
