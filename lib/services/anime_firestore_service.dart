import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_model.dart';  // Asegúrate de que los modelos estén bien definidos.

class AnimeFirestoreService {
  final _db = FirebaseFirestore.instance;

  // Guarda el anime en la colección de animes
  Future<void> saveAnime(int animeId, Anime anime) async {
    try {
      print('Guardando anime con animeId: $animeId');
      print('Datos del anime: ${anime.toMap()}');
      
      // Guardamos el anime en la colección 'animes' usando el id como documento
      await _db.collection('animes').doc(animeId.toString()).set(anime.toMap());
      print('Anime guardado con éxito');
      
      // Ahora, guardamos los episodios en la subcolección 'episodes'
      for (var episode in anime.episodes) {
        await saveEpisode(animeId, episode);
      }
    } catch (e) {
      print("Error al guardar el anime: $e");
    }
  }

  // Guarda un episodio en la subcolección 'episodes' del anime
  Future<void> saveEpisode(int animeId, AnimeEpisode episode) async {
    try {
      print('Guardando episodio para el anime: $animeId');
      print('Datos del episodio: ${episode.toMap()}');
      
      // Guardamos el episodio en la subcolección 'episodes' del anime
      await _db
          .collection('animes')
          .doc(animeId.toString())  // Utilizamos el ID del anime
          .collection('episodes')
          .doc("ep_${episode.episode}")  // Usamos un ID único basado en el episodio
          .set(episode.toMap());
      print('Episodio guardado con éxito');
    } catch (e) {
      print("Error al guardar el episodio: $e");
    }
  }

  // Obtiene los episodios para un anime
  Future<List<AnimeEpisode>> getEpisodesForAnime(int animeId) async {
    final snapshot = await _db
        .collection('animes')
        .doc(animeId.toString())  // Aseguramos que estamos buscando por ID de anime
        .collection('episodes')
        .get();

    return snapshot.docs.map((doc) => AnimeEpisode.fromMap(doc.data())).toList();
  }
}
