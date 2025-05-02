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
