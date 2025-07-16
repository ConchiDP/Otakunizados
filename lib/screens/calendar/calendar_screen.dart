import 'package:flutter/material.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/services/anilist_service.dart';
import 'package:otakunizados/services/anime_schedule_firestore_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/anime_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<AnimeSchedule>> _groupedEpisodes = {};
  List<AnimeSchedule> _selectedEpisodes = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAnimes();
  }

  Future<void> _loadUserAnimes() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('user_lists')
        .doc(user.uid)
        .collection('animes')
        .get();
    final List<AnimeEpisode> allEpisodes = [];
    for (var doc in snapshot.docs) {
      final anime = Anime.fromMap(doc.data());
      allEpisodes.addAll(anime.episodes);
    }
    
    final List<AnimeSchedule> episodes = allEpisodes.map((e) => AnimeSchedule(
      airingAt: e.airingAt,
      episode: e.episode,
      title: e.title,
      coverImageUrl: e.coverImageUrl,
    )).toList();
    _groupEpisodesByDate(episodes);
    setState(() => _isLoading = false);
  }

  void _groupEpisodesByDate(List<AnimeSchedule> episodes) {
    _groupedEpisodes.clear();

    for (var episode in episodes) {
      final date = DateTime.fromMillisecondsSinceEpoch(episode.airingAt);
      final dateKey = DateTime(date.year, date.month, date.day);
      if (_groupedEpisodes[dateKey] == null) {
        _groupedEpisodes[dateKey] = [];
      }
      _groupedEpisodes[dateKey]!.add(episode);
    }

    _selectedDay = _focusedDay;
    _selectedEpisodes = _groupedEpisodes[_selectedDay] ?? [];
  }

  List<AnimeSchedule> _getEpisodesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day); 
    return _groupedEpisodes[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateTime.now();
    final firstDay = isToday.subtract(const Duration(days: 7));
    final lastDay = isToday.add(const Duration(days: 14));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario de Estrenos"),
       
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: firstDay, 
                  lastDay: lastDay,
                  calendarFormat: CalendarFormat.week,
                  locale: 'es_ES',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEpisodesForDay,
                  headerStyle: const HeaderStyle(formatButtonVisible: false),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEpisodes = _getEpisodesForDay(selectedDay);
                    });
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _selectedEpisodes.isEmpty
                      ? const Center(child: Text("No hay episodios para este día."))
                      : ListView.builder(
                          itemCount: _selectedEpisodes.length,
                          itemBuilder: (context, index) {
                            final anime = _selectedEpisodes[index];
                            return ListTile(
                              leading: anime.coverImageUrl.isNotEmpty
                                  ? Image.network(anime.coverImageUrl, width: 50, fit: BoxFit.cover)
                                  : const Icon(Icons.image_not_supported),
                              title: Text(anime.title),
                              subtitle: Text("Episodio ${anime.episode}"),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
    );
  }
}
