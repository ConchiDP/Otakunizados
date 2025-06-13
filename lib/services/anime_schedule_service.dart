import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime_schedule_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AniListService {
  final String _baseUrl = "https://graphql.anilist.co/";

  Future<List<Map<String, dynamic>>> fetchTodaySchedule() async {
    final query = '''
      query {
        Page(page: 1, perPage: 10) {
          airingSchedules(mediaType: ANIME, airingAt_greater: ${DateTime.now().millisecondsSinceEpoch / 1000}) {
            episode
            airingAt
            media {
              title {
                romaji
                english
                native
              }
            }
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final airingSchedules = data['data']['Page']['airingSchedules'];

      List<Map<String, dynamic>> schedule = [];
      for (var scheduleItem in airingSchedules) {
        schedule.add({
          'title': scheduleItem['media']['title']['romaji'],
          'date': DateTime.fromMillisecondsSinceEpoch(scheduleItem['airingAt'] * 1000),
        });
      }

      return schedule;
    } else {
      throw Exception('Error al obtener datos desde AniList');
    }
  }

  getEpisodesThisWeek() {}
}