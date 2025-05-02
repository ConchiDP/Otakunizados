import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/models/anime_model.dart';

class AnimeScheduleFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda un episodio usando `airingAt` como ID único
  Future<void> saveEpisode(AnimeSchedule animeSchedule) async {
    await _firestore
        .collection('episodes')
        .doc(animeSchedule.airingAt.toString()) // ✅ Usamos airingAt como ID
        .set(animeSchedule.toMap());
  }

  /// Guarda un anime y acumula episodios únicos en la lista
  Future<void> saveAnime(Anime anime) async {
    final docRef = _firestore.collection('animes').doc(anime.title);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final List<dynamic> existingEpisodes = (data?['episodes'] ?? []) as List;

      final newEpisode = anime.episodes.first.toMap();

      final alreadyExists = existingEpisodes.any((e) => e['airingAt'] == newEpisode['airingAt']);

      if (!alreadyExists) {
        existingEpisodes.add(newEpisode);
        await docRef.update({'episodes': existingEpisodes});
      }
    } else {
      // Si no existe, lo crea con el episodio
      await docRef.set(anime.toMap());
    }
  }

  /// Recupera todos los episodios desde Firestore
  Future<List<AnimeSchedule>> getEpisodes() async {
    final snapshot = await _firestore.collection('episodes').get();
    return snapshot.docs
        .map((doc) => AnimeSchedule.fromMap(doc.data()))
        .toList();
  }

  /// Recupera todos los animes (opcional, por si los usas en otro lugar)
  Future<List<Anime>> getAnimes() async {
    final snapshot = await _firestore.collection('animes').get();
    return snapshot.docs
        .map((doc) => Anime.fromMap(doc.data()))
        .toList();
  }
}
