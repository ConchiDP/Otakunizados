import 'package:flutter/material.dart';
import 'package:otakunizados/services/anime_schedule_firestore_service.dart';
import 'package:otakunizados/models/anime_schedule_model.dart';
import 'package:otakunizados/services/anilist_service.dart'; // Asegúrate de usar el servicio correcto

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<AnimeSchedule> _schedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadScheduleFromFirestore();

    // Si no hay datos en Firestore, intenta obtenerlos desde AniList automáticamente
    if (_schedule.isEmpty) {
      await _fetchScheduleFromAniList();
    }
  }

  Future<void> _loadScheduleFromFirestore() async {
    setState(() => _isLoading = true);

    final episodes = await AnimeScheduleFirestoreService().getEpisodes();

    setState(() {
      _schedule = episodes;
      _isLoading = false;
    });
  }

  Future<void> _fetchScheduleFromAniList() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final schedule = await AniListService().getWeeklySchedule(
        startOfWeek.millisecondsSinceEpoch,
        endOfWeek.millisecondsSinceEpoch,
      );

      print("🧐 Datos recibidos de AniList: $schedule");

      if (schedule != null && schedule.isNotEmpty) {
        await AnimeScheduleFirestoreService().saveEpisodes(schedule);
      }

      await _loadScheduleFromFirestore();
    } catch (e) {
      print("❌ Error al obtener el horario de AniList: $e");
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year}";
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
          : _schedule.isEmpty
              ? const Center(child: Text("No hay episodios para mostrar."))
              : ListView.builder(
                  itemCount: _schedule.length,
                  itemBuilder: (context, index) {
                    final anime = _schedule[index];
                    return ListTile(
                      leading: anime.coverImageUrl.isNotEmpty
                          ? Image.network(anime.coverImageUrl)
                          : const Icon(Icons.image_not_supported),
                      title: Text(anime.title),
                      subtitle: Text("Episodio ${anime.episode}"),
                      trailing: Text(
                        _formatDate(anime.airingAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
    );
  }
}
