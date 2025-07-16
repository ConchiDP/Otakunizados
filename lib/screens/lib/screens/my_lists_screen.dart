import 'package:flutter/material.dart';
import 'package:otakunizados/services/anilist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_model.dart';

class MyListsScreen extends StatefulWidget {
  const MyListsScreen({super.key});

  @override
  State<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends State<MyListsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Anime> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _searchAnime() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final anilistService = AniListService();
      
      final results = await anilistService.searchAnime(_searchController.text.trim());
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al buscar animes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addAnimeToUserList(Anime anime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final anilistService = AniListService();
    final episodes = await anilistService.getAnimeEpisodes(anime.title);
    final animeWithEpisodes = Anime(
      title: anime.title,
      coverImageUrl: anime.coverImageUrl,
      episodes: episodes,
    );
    final userAnimeRef = FirebaseFirestore.instance
        .collection('user_lists')
        .doc(user.uid)
        .collection('animes')
        .doc(anime.title);
    await userAnimeRef.set(animeWithEpisodes.toMap());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anime añadido a tu lista con episodios reales')),
    );
  }

  Future<void> _deleteAnimeFromUserList(String animeTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('user_lists')
        .doc(user.uid)
        .collection('animes')
        .doc(animeTitle)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anime eliminado de tu lista')),
    );
  }

  Stream<List<Anime>> _userAnimesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('user_lists')
        .doc(user.uid)
        .collection('animes')
        .snapshots()
        .map((snapshot) {
          final animes = snapshot.docs.map((doc) => Anime.fromMap(doc.data())).toList();
          for (final anime in animes) {
            print('Anime: \\${anime.title}');
            for (final ep in anime.episodes) {
              print('  Episodio: \\${ep.episode}, airingAt: \\${ep.airingAt}, title: \\${ep.title}');
            }
          }
          return animes;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis listas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar anime',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchAnime,
                ),
              ),
              onSubmitted: (_) => _searchAnime(),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tus animes guardados:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: StreamBuilder<List<Anime>>(
                      stream: _userAnimesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final userAnimes = snapshot.data ?? [];
                        if (userAnimes.isEmpty) {
                          return const Text('No tienes animes guardados.');
                        }
                        return ListView.builder(
                          itemCount: userAnimes.length,
                          itemBuilder: (context, index) {
                            final anime = userAnimes[index];
                            return ListTile(
                              leading: anime.coverImageUrl.isNotEmpty
                                  ? Image.network(anime.coverImageUrl, width: 50, fit: BoxFit.cover)
                                  : const Icon(Icons.image_not_supported),
                              title: Text(anime.title),
                              subtitle: Text('Episodios: ${anime.episodes.length}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAnimeFromUserList(anime.title),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  const Text('Resultados de búsqueda:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final anime = _searchResults[index];
                        return ListTile(
                          leading: anime.coverImageUrl.isNotEmpty
                              ? Image.network(anime.coverImageUrl, width: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported),
                          title: Text(anime.title),
                          subtitle: Text('Episodios: ${anime.episodes.length}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addAnimeToUserList(anime),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
