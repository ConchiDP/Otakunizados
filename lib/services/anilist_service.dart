import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/models/anime_model.dart';
import 'package:otakunizados/services/anime_schedule_firestore_service.dart';
import 'package:otakunizados/services/anime_firestore_service.dart';


const String kAniListApiUrl = 'https://graphql.anilist.co';

class AniListService {
  late GraphQLClient _client;

  AniListService() {
    final httpLink = HttpLink(kAniListApiUrl);
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
          
          final existingEpisodes = anime.episodes ?? [];
          final updatedEpisodes = [...existingEpisodes, animeSchedule]
              .toSet() 
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

  Future<List<Anime>> searchAnime(String query) async {
    final searchQuery = gql(r'''
      query (
        $query: String
      ) {
        Page(page: 1, perPage: 10) {
          media(search: $query, type: ANIME) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            episodes
          }
        }
      }
    ''');

    final options = QueryOptions(
      document: searchQuery,
      variables: {'query': query},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException) {
      print('Error al buscar animes: ${result.exception}');
      return [];
    }

    final mediaList = result.data?['Page']?['media'] as List<dynamic>?;
    if (mediaList == null) return [];

    return mediaList.map((media) {
      final title = media['title']?['romaji'] ?? media['title']?['english'] ?? 'Sin título';
      final coverImageUrl = media['coverImage']?['large'] ?? '';
      final episodesCount = media['episodes'] ?? 0;
      return Anime(
        title: title,
        coverImageUrl: coverImageUrl,
        episodes: List.generate(episodesCount, (i) => AnimeEpisode(
          episode: i + 1,
          title: title,
          airingAt: 0,
          coverImageUrl: coverImageUrl,
        )),
      );
    }).toList();
  }

  Future<List<AnimeEpisode>> getAnimeEpisodes(String animeTitle) async {
    final query = gql(r'''
      query (
        $search: String
      ) {
        Media(search: $search, type: ANIME) {
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          airingSchedule(notYetAired: true, perPage: 50) {
            nodes {
              episode
              airingAt
            }
          }
        }
      }
    ''');

    final options = QueryOptions(
      document: query,
      variables: {'search': animeTitle},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException) {
      print('Error al buscar episodios: ${result.exception}');
      return [];
    }

    final media = result.data?['Media'];
    if (media == null) return [];
    final title = media['title']?['romaji'] ?? media['title']?['english'] ?? 'Sin título';
    final coverImageUrl = media['coverImage']?['large'] ?? '';
    final nodes = media['airingSchedule']?['nodes'] as List<dynamic>?;
    if (nodes == null) return [];

    return nodes.map((node) {
      return AnimeEpisode(
        episode: node['episode'] ?? 0,
        title: title,
        airingAt: (node['airingAt'] ?? 0) * 1000, 
        coverImageUrl: coverImageUrl,
      );
    }).toList();
  }
}

