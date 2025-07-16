import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_model.dart';

class AnimeFirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveAnime(String title, Anime anime) async {
    try {
      print('Guardando anime con título: $title');
      print('Datos del anime: ${anime.toMap()}');
      
      
      await _db.collection('animes').doc(title).set({
        'title': anime.title,
        'coverImageUrl': anime.coverImageUrl,
        'episodes': anime.episodes.map((e) => e.toMap()).toList(),
      });
      print('Anime guardado con éxito');
    } catch (e) {
      print("Error al guardar el anime: $e");
    }
  }

  
  Future<Anime?> getAnimeByTitle(String title) async {
    try {
      final docSnapshot = await _db.collection('animes').doc(title).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final episodesData = List<Map<String, dynamic>>.from(data?['episodes'] ?? []);
        return Anime(
          title: data?['title'],
          coverImageUrl: data?['coverImageUrl'] ?? '',
          episodes: episodesData.map((episodeData) => AnimeEpisode.fromMap(episodeData)).toList(),
        );
      }
      return null;
    } catch (e) {
      print("❌ Error al obtener el anime: $e");
      return null;
    }
  }

  
  Future<List<Anime>> getAnimes() async {
    final snapshot = await _db.collection('animes').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final episodesData = List<Map<String, dynamic>>.from(data?['episodes'] ?? []);

      return Anime(
        title: data['title'],
        coverImageUrl: data['coverImageUrl'] ?? '', 
        episodes: episodesData.map((episodeData) => AnimeEpisode.fromMap(episodeData)).toList(),
      );
    }).toList();
  }
}
