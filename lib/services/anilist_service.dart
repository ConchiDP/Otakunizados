import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/models/anime_model.dart';
import 'package:otakunizados/services/anime_schedule_firestore_service.dart';

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
    final now = DateTime.now();

    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final nextMonday = thisMonday.add(Duration(days: 7));
    final nextSunday = nextMonday.add(Duration(days: 6));

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
      for (var item in filteredSchedules) {
        final media = item['media'];
        final coverInfo = media['coverImage'];
        final titleInfo = media['title'];

        final title = titleInfo?['romaji'] ?? titleInfo?['english'] ?? 'Título no disponible';
        final airingTime = item['airingAt'] as int;
        final timestamp = _convertAiringTimeToTimestamp(airingTime);
        final episodeNumber = item['episode'] as int? ?? 0;
        final coverImageUrl = coverInfo?['large'] as String? ?? '';

        // Creamos un AnimeSchedule para mostrar en el calendario
        final animeSchedule = AnimeSchedule(
          airingAt: timestamp,
          episode: episodeNumber,
          title: title,
          coverImageUrl: coverImageUrl,
        );

        // Guardamos individualmente como episodio en Firestore
        await AnimeScheduleFirestoreService().saveEpisode(animeSchedule);

        // Convertimos a AnimeEpisode para guardarlo en el modelo Anime
        final animeEpisode = AnimeEpisode(
          episode: episodeNumber,
          title: title,
          airingAt: timestamp,
          coverImageUrl: coverImageUrl,
        );

        await AnimeScheduleFirestoreService().saveAnime(Anime(
          title: title,
          coverImageUrl: coverImageUrl,
          episodes: [animeEpisode],
        ));
      }

      // Retornar la lista para el calendario (no afecta a Firebase)
      return filteredSchedules.map((item) {
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
    } catch (e) {
      print("❌ Error al mapear los datos de AniList a AnimeSchedule: $e");
      return null;
    }
  }
}
