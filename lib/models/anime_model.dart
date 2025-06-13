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
    return AnimeEpisode(
      episode: map['episode'] ?? 0,
      title: map['title'] ?? '',
      airingAt: map['airingAt'] ?? 0,
      coverImageUrl: map['coverImageUrl'] ?? '',
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
