import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';

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
  
  // Lunes de esta semana (ajustado)
  final thisMonday = now.subtract(Duration(days: now.weekday - 1)); // Restar el día actual menos 1 (lunes)
  
  // Lunes de la próxima semana
  final nextMonday = DateTime(now.year, now.month, now.day + (8 - now.weekday)); // Mismo cálculo que antes
  
  // Domingo de la próxima semana
  final nextSunday = nextMonday.add(Duration(days: 6));  // Domingo de la siguiente semana
  
  final startTimestamp = thisMonday.millisecondsSinceEpoch;  // Usar el lunes de esta semana
  final endTimestamp = nextSunday.millisecondsSinceEpoch;    // Usar el domingo de la próxima semana

  final result = await getWeeklySchedule(startTimestamp, endTimestamp);
  return result ?? [];
}

  Future<List<AnimeSchedule>?> getWeeklySchedule(int startTimestamp, int endTimestamp) async {
    int startSeconds = startTimestamp ~/ 1000;
    int endSeconds = endTimestamp ~/ 1000;

    final query = gql(r'''
      query ($start: Int, $end: Int) {
        Page(page: 1, perPage: 0) {
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
      return filteredSchedules.map((item) {
        final media = item['media'];
        final titleInfo = media['title'];
        final coverInfo = media['coverImage'];

        final airingTime = item['airingAt'] as int;
        final timestamp = _convertAiringTimeToTimestamp(airingTime);

        return AnimeSchedule(
          airingAt: timestamp,
          episode: item['episode'] as int? ?? 0,
          title: titleInfo?['romaji'] as String? ?? titleInfo?['english'] as String? ?? 'Título no disponible',
          coverImageUrl: coverInfo?['large'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      print("❌ Error al mapear los datos de AniList a AnimeSchedule: $e");
      return null;
    }
  }
}
