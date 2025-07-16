class AnimeEpisode {
  final int episode;
  final String title;
  final int airingAt;
  final String coverImageUrl;

  AnimeEpisode({
    required this.episode,
    required this.title,
    required this.airingAt,
    required this.coverImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'episode': episode,
      'title': title,
      'airingAt': airingAt,
      'coverImageUrl': coverImageUrl,
    };
  }

  factory AnimeEpisode.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('episode') ||
        !map.containsKey('title') ||
        !map.containsKey('airingAt') ||
        !map.containsKey('coverImageUrl')) {
      throw Exception('Faltan campos requeridos en el mapa para AnimeEpisode');
    }
    return AnimeEpisode(
      episode: map['episode'],
      title: map['title'],
      airingAt: map['airingAt'],
      coverImageUrl: map['coverImageUrl'],
    );
  }
}

class Anime {
  final String title;
  final String coverImageUrl;
  final List<AnimeEpisode> episodes;

  Anime({
    required this.title,
    required this.coverImageUrl,
    required this.episodes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'coverImageUrl': coverImageUrl,
      'episodes': episodes.map((e) => e.toMap()).toList(),
    };
  }

  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      title: map['title'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      episodes: (map['episodes'] as List<dynamic>)
          .map((e) => AnimeEpisode.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

