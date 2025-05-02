// anime_model.dart

class Anime {
  final int id;
  final String title;
  final List<AnimeEpisode> episodes;

  Anime({
    required this.id,
    required this.title,
    required this.episodes,  // Aseguramos que se maneje una lista de episodios
  });

  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      id: map['id'],
      title: map['title'],
      episodes: (map['episodes'] as List)
          .map((episodeMap) => AnimeEpisode.fromMap(episodeMap))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'episodes': episodes.map((e) => e.toMap()).toList(),
    };
  }
}

class AnimeEpisode {
  final int episode;
  final int airingAt;
  final String coverImageUrl;
  final String romaji;

  AnimeEpisode({
    required this.episode,
    required this.airingAt,
    required this.coverImageUrl,
    required this.romaji,
  });

  factory AnimeEpisode.fromMap(Map<String, dynamic> map) {
    return AnimeEpisode(
      episode: map['episode'],
      airingAt: map['airingAt'],
      coverImageUrl: map['coverImageUrl'] ?? '',
      romaji: map['romaji'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'episode': episode,
      'airingAt': airingAt,
      'coverImageUrl': coverImageUrl,
      'romaji': romaji,
    };
  }
}
