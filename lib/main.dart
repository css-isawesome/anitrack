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
    return const MaterialApp(
      title: 'AniTrack',
      home: MainAnimeListScreen(),
    );
  }
}

class MainAnimeListScreen extends StatefulWidget {
  const MainAnimeListScreen({super.key});

  @override
  State<MainAnimeListScreen> createState() => _MainAnimeListScreenState();
}

class _MainAnimeListScreenState extends State<MainAnimeListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pasek dla pierwszego ekranu
      appBar: AppBar(
        title: const Text("AniTrack"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: "Profil",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Tutaj będzie Twoja lista top anime!"),
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
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Tutaj będą statystyki, postęp i oceny."),
      ),
    );
  }
}