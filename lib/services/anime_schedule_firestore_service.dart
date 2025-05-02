import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';

class AnimeScheduleFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Verifica si un episodio con la ID 'airingAt' ya existe en la colección 'episodes'
  Future<bool> doesEpisodeExist(int airingAt) async {
    try {
      final docRef = _db.collection('episodes').doc(airingAt.toString());
      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } catch (e) {
      print("❌ Error al verificar si el episodio existe: $e");
      return false;
    }
  }

  // Guarda un episodio en la colección 'episodes'
  Future<void> saveEpisode(AnimeSchedule episode) async {
    try {
      final docRef = _db.collection('episodes').doc(episode.airingAt.toString());
      
      await docRef.set({
        'title': episode.title,
        'episode': episode.episode,
        'airingAt': episode.airingAt,
        'coverImageUrl': episode.coverImageUrl,
      });

      print("✅ Episodio guardado con éxito: ${episode.title} episodio ${episode.episode}");
    } catch (e) {
      print("❌ Error al guardar el episodio: $e");
    }
  }

  // Obtiene todos los episodios de la colección 'episodes'
  Future<List<AnimeSchedule>> getEpisodes() async {
    try {
      final snapshot = await _db.collection('episodes').get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<AnimeSchedule> episodes = snapshot.docs.map((doc) {
        final data = doc.data();
        return AnimeSchedule(
          airingAt: data['airingAt'],
          episode: data['episode'],
          title: data['title'],
          coverImageUrl: data['coverImageUrl'],
        );
      }).toList();

      return episodes;
    } catch (e) {
      print("❌ Error al obtener episodios desde Firestore: $e");
      return [];
    }
  }
}
