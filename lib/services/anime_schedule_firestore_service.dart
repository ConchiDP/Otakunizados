import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';

class AnimeScheduleFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para guardar episodios en Firestore
Future<void> saveEpisodes(List<AnimeSchedule> episodes) async {
  for (var episode in episodes) {
    final episodeId = '${episode.airingAt}_${episode.episode}';

    try {
      await _db.collection('anime_schedules').doc(episodeId).set({
        'airingAt': episode.airingAt,
        'episode': episode.episode,
        'media': {
          'title': episode.title,
          'coverImage': episode.coverImageUrl,
        },
      });

      // Añadimos un print para ver si el episodio fue guardado
      print("Episodio guardado: $episodeId");
    } catch (e) {
      print("Error al guardar episodio: $e");
    }
  }
}
  
    
    // Método para obtener episodios de Firestore
    Future<List<AnimeSchedule>> getEpisodes() async {
      try {
        final snapshot = await _db.collection('anime_schedules').get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return AnimeSchedule(
            airingAt: data['airingAt'],
            episode: data['episode'],
            title: data['media']['title'],
            coverImageUrl: data['media']['coverImage'],
          );
        }).toList();
      } catch (e) {
        print("Error al obtener episodios: $e");
        return [];
      }
    }
  }

