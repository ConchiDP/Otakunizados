import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/models/anime_model.dart';
import 'package:otakunizados/services/anime_schedule_firestore_service.dart';
import 'package:otakunizados/services/anime_firestore_service.dart';

class AniListService {
  late GraphQLClient _client;

  AniListService() {
    final httpLink = HttpLink('https://graphql.anilist.co');
    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }

  int _convertAiringTimeToTimestamp(int airingTime) {
    return airingTime * 1000;
  }

  Future<List<AnimeSchedule>> getEpisodesThisAndNextWeek() async {
    final now = DateTime.now().toUtc();

    final thisMonday = now.subtract(Duration(days: now.weekday - 1)); // lunes de esta semana
    final nextMonday = thisMonday.add(Duration(days: 7));  // lunes de la próxima semana
    final nextSunday = nextMonday.add(Duration(days: 6)); // domingo de la próxima semana

    final startTimestamp = thisMonday.millisecondsSinceEpoch;
    final endTimestamp = nextSunday.millisecondsSinceEpoch;

    final result = await getWeeklySchedule(startTimestamp, endTimestamp);
    return result ?? [];
  }

  Future<List<AnimeSchedule>?> getWeeklySchedule(int startTimestamp, int endTimestamp) async {
    int startSeconds = startTimestamp ~/ 1000;
    int endSeconds = endTimestamp ~/ 1000;

    final query = gql(r'''
      query ($start: Int, $end: Int) {
        Page(page: 1, perPage: 100) {
          airingSchedules(airingAt_greater: $start, airingAt_lesser: $end, sort: TIME) {
            airingAt
            episode
            media {
              id
              title {
                romaji
                english
              }
              coverImage {
                large
              }
              endDate {
                 year
                 month
                 day
              }
            }
          }
        }
      }
    ''');

    final options = QueryOptions(
      document: query,
      variables: {
        'start': startSeconds,
        'end': endSeconds,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException) {
      print("❌ Error GraphQL al obtener el horario semanal: ${result.exception.toString()}");
      return null;
    }

    if (result.data == null) {
      print("❗️ La respuesta de AniList no contiene datos.");
      return [];
    }

    final schedulesData = result.data?['Page']?['airingSchedules'];

    if (schedulesData == null || schedulesData is! List) {
      print("❗️ No se encontró la lista 'airingSchedules' en la respuesta o no es una lista.");
      return [];
    }

    final List<dynamic> schedules = schedulesData;

    if (schedules.isEmpty) {
      print("✅ No hay episodios programados para la próxima semana en AniList.");
      return [];
    }

    final filteredSchedules = schedules.where((item) {
      final media = item?['media'];
      final endDate = media?['endDate'];
      return endDate == null || endDate['year'] == null;
    }).toList();

    try {
      final sortedSchedules = filteredSchedules.map((item) {
        final media = item['media'];
        final coverInfo = media['coverImage'];
        final titleInfo = media['title'];

        final title = titleInfo?['romaji'] ?? titleInfo?['english'] ?? 'Título no disponible';
        final airingTime = item['airingAt'] as int;
        final timestamp = _convertAiringTimeToTimestamp(airingTime);
        final episodeNumber = item['episode'] as int? ?? 0;
        final coverImageUrl = coverInfo?['large'] as String? ?? '';

        return AnimeSchedule(
          airingAt: timestamp,
          episode: episodeNumber,
          title: title,
          coverImageUrl: coverImageUrl,
        );
      }).toList();

      sortedSchedules.sort((a, b) => a.airingAt.compareTo(b.airingAt));

      // Guardar anime con episodios en Firestore
      for (var animeSchedule in sortedSchedules) {
        final exists = await AnimeScheduleFirestoreService().doesEpisodeExist(animeSchedule.airingAt);
        if (!exists) {
          await AnimeScheduleFirestoreService().saveEpisode(animeSchedule);
          print("Guardando episodio: ${animeSchedule.title} episodio ${animeSchedule.episode}");
        } else {
          print("Episodio ya existe: ${animeSchedule.title} episodio ${animeSchedule.episode}");
        }

        // Ahora guardamos el anime, solo si no existe en Firestore
        final anime = await AnimeFirestoreService().getAnimeByTitle(animeSchedule.title);
        if (anime == null) {
          final newAnime = Anime(
            title: animeSchedule.title,
            coverImageUrl: animeSchedule.coverImageUrl,
            episodes: [
              AnimeEpisode(
                airingAt: animeSchedule.airingAt,
                episode: animeSchedule.episode,
                title: animeSchedule.title,
                coverImageUrl: animeSchedule.coverImageUrl,
              )
            ],
          );
          await AnimeFirestoreService().saveAnime(animeSchedule.title, newAnime);
          print("Guardando anime nuevo: ${animeSchedule.title}");
        } else {
          // Si el anime ya existe, actualizamos sus episodios si no están duplicados
          final existingEpisodes = anime.episodes ?? [];
          final updatedEpisodes = [...existingEpisodes, animeSchedule]
              .toSet() // Eliminar duplicados
              .toList();
          final updatedAnime = Anime(
            title: anime.title,
            coverImageUrl: anime.coverImageUrl,
            episodes: updatedEpisodes.cast<AnimeEpisode>(),
          );
          await AnimeFirestoreService().saveAnime(animeSchedule.title, updatedAnime);
          print("Actualizando episodios del anime: ${animeSchedule.title}");
        }
      }

      return sortedSchedules;
    } catch (e) {
      print("❌ Error al mapear los datos de AniList a AnimeSchedule: $e");
      return null;
    }
  }
}
