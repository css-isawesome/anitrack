import 'package:anitrack/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '/models/top_anime.dart';
import '/models/info_anime.dart';
import 'services/database_anime.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox<Map>("userAnimeBox");

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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

  final List<TopAnime> _animeList = []; // pobrane anime
  int _currentPage = 1; // sledzenie aktualnej strony
  bool _isLoading = false; // czy trwa pobieranie anime

  @override
  void initState() {
    super.initState();
    _loadMoreAnime();
    // _loadCachedAnime();

    // scrollowanie
    _scrollController.addListener(() {
      // jesli uzytkownik przewinal do 90% dlugosci ekranu i nie trwa ladowanie
      if (_animeList.isNotEmpty &&
          _scrollController.position.pixels >=
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
      if (!mounted) return; // sprawdzenie czy ekran wciaz istnieje bo warning
      String errorMessage = "Error: $e";
      // na wypadek errora - snackbar z komunikatem o bledze
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // przejscie do ekranu z profilem uzytkownika
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
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
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentPage = 1;
                  _animeList.clear();
                });
                await _loadMoreAnime();
              },
              child: GridView.builder(
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
                              // wypelnienie calego grida przez okladke
                              width: double.infinity,
                              anime.img,
                              fit: BoxFit.cover,
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
  List<InfoAnime> _favoritedAnimeList = [];

  @override
  void initState() {
    super.initState();
    // Pobieramy listę wszystkich zapisanych w Hive obiektów InfoAnime
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritedAnimeList = AnimeLocalDatabase.getTrackedAnime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: Colors.black45,
        foregroundColor: Colors.grey,
      ),
      // Jeśli lista jest pusta, wyświetlamy komunikat, w innym wypadku listę tytułów
      body: _favoritedAnimeList.isEmpty
          ? const Center(
              child: Text(
                "Nothing to see here yet...",
                style: TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _favoritedAnimeList.length,
              itemBuilder: (context, index) {
                final anime = _favoritedAnimeList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          await AnimeLocalDatabase.deleteAnime(anime.id);

                          if (!mounted) return;
                          _loadFavorites();
                        },
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InfoAnimeScreen(
                                  animeId: anime.id,
                                  animeTitle: anime.engTitle,
                                ),
                              ),
                            );
                            if (!mounted) return;
                            _loadFavorites(); // Odświeżamy listę z bazy Hive
                          },
                          child: Text(anime.engTitle),
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
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    // pobranie szczegolowych informacji o anime
    _animeInfoFuture = ApiService.fetchInfoAnime(widget.animeId);

    // Sprawdzamy, czy to anime już istnieje w naszej bazie Hive
    final cachedAnime = AnimeLocalDatabase.getAnimeById(widget.animeId);
    if (cachedAnime != null) {
      _isFavorited = true;
    }

    // logowanie wyswietlenia szczegolow anime
    FirebaseAnalytics.instance.logEvent(
      name: 'anime_viewed',
      parameters: {
        'anime_id': widget.animeId,
        'anime_title': widget.animeTitle,
      },
    );
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
                "Something went wrong...: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // jesli sukces
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
                        // alignment: Alignment.topCenter,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // tytuly
                    children: [
                      // tytul angielski
                      Text(
                        anime.engTitle,
                        textAlign: TextAlign.center,
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 32.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_isFavorited) {
                            // Jeśli już był polubiony -> usuwamy z bazy Hive
                            await AnimeLocalDatabase.deleteAnime(anime.id);

                            // logowanie usuniecia z listy ulubionych
                            await FirebaseAnalytics.instance.logEvent(
                              name: 'anime_unfavorited',
                              parameters: {
                                'anime_id': anime.id,
                                'anime_title': anime.engTitle,
                              },
                            );
                          } else {
                            // Jeśli nie był polubiony -> zapisujemy do bazy Hive
                            await AnimeLocalDatabase.saveAnime(anime);

                            await FirebaseAnalytics.instance.logEvent(
                              name: 'anime_favorited',
                              parameters: {
                                'anime_id': anime.id,
                                'anime_title': anime.engTitle,
                              },
                            );
                          }
                          setState(() {
                            _isFavorited = !_isFavorited;
                            // print(_isFavorited); // debug
                          });
                        },
                        // wyglad przycisku favorite
                        icon: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(_isFavorited ? "Favorited" : "Favorite"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),

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

                          const SizedBox(height: 32.0),
                          Text(
                            "Information",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Divider(height: 32.0),
                          _buildAnimeDetail(
                            "Episodes",
                            anime.episodes.toString(),
                          ),
                          _buildAnimeDetail("Status", anime.status),
                          _buildAnimeDetail("Aired", anime.aired),
                          _buildAnimeDetail("Demographic", anime.demographic),
                          _buildAnimeDetail("Genre", anime.genre),
                          _buildAnimeDetail("Score", anime.score.toString()),
                          _buildAnimeDetail("Studios", anime.studios),
                          const SizedBox(height: 32.0),
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

  // do wyswietlania informacji jedna za druga pod soba np episodes gernre itd
  Widget _buildAnimeDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      // Automatyczny mały odstęp pod każdym wierszem
      child: Text.rich(
        TextSpan(
          // style: const TextStyle(),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey, // Kolor dla etykiety
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.black45,
        foregroundColor: Colors.grey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // przycisk czyszczenia cache
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            title: const Text(
              "Clear Cache / Favorites",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "This will delete all saved anime from your device.",
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Pokazujemy okienko dialogowe z potwierdzeniem
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text("Are you sure?"),
                    content: const Text(
                      "Do you really want to clear all favorited anime?",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                      TextButton(
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onPressed: () async {
                          await AnimeLocalDatabase.clearDatabase();

                          if (!context.mounted) return;
                          Navigator.pop(dialogContext); // Zamknij dialog

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cache cleared successfully!"),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
