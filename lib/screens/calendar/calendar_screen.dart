import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/services/anilist_service.dart';
import 'package:otakunizados/services/anime_schedule_firestore_service.dart';

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
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadScheduleFromFirestore();

    if (_groupedEpisodes.isEmpty) {
      await _fetchScheduleFromAniList();
    }
  }

  Future<void> _loadScheduleFromFirestore() async {
    setState(() => _isLoading = true);
    final episodes = await AnimeScheduleFirestoreService().getEpisodes();
    _groupEpisodesByDate(episodes);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchScheduleFromAniList() async {
    setState(() => _isLoading = true);

    try {
      final schedule = await AniListService().getEpisodesThisAndNextWeek();

      if (schedule != null && schedule.isNotEmpty) {
        await AnimeScheduleFirestoreService().saveEpisodes(schedule);
      }

      await _loadScheduleFromFirestore();
    } catch (e) {
      print("❌ Error al obtener el horario de AniList: $e");
      setState(() => _isLoading = false);
    }
  }

  void _groupEpisodesByDate(List<AnimeSchedule> episodes) {
    _groupedEpisodes.clear();

    for (var episode in episodes) {
      try {
        // Aseguramos que estamos creando una fecha válida a partir de airingAt
        final date = DateTime.fromMillisecondsSinceEpoch(episode.airingAt);
        final dateKey = DateTime(date.year, date.month, date.day);
        
        // Agregamos los episodios por fecha
        if (_groupedEpisodes[dateKey] == null) {
          _groupedEpisodes[dateKey] = [];
        }
        _groupedEpisodes[dateKey]!.add(episode);
      } catch (e) {
        print("❌ Error al agrupar episodios para la fecha: ${episode.airingAt}, error: $e");
      }
    }

    // Actualizamos el estado
    _selectedDay = _focusedDay;
    _selectedEpisodes = _groupedEpisodes[_selectedDay] ?? [];
    print("🗓️ Episodios agrupados: $_groupedEpisodes");
  }

  List<AnimeSchedule> _getEpisodesForDay(DateTime day) {
    return _groupedEpisodes[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario de Estrenos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchScheduleFromAniList,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.now().subtract(const Duration(days: 7)),
                  lastDay: DateTime.now().add(const Duration(days: 14)),
                  calendarFormat: CalendarFormat.week,
                  locale: 'es_ES', // Establece el locale a español
                  startingDayOfWeek: StartingDayOfWeek.monday, // Inicio de semana en lunes
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEpisodesForDay,
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
