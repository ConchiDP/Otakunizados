class AnimeSchedule {
  final int airingAt;
  final int episode;
  final String title;
  final String coverImageUrl;

  AnimeSchedule({
    required this.airingAt,
    required this.episode,
    required this.title,
    required this.coverImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'airingAt': airingAt,
      'episode': episode,
      'title': title,
      'coverImageUrl': coverImageUrl,
    };
  }

  factory AnimeSchedule.fromMap(Map<String, dynamic> map) {
    return AnimeSchedule(
      airingAt: map['airingAt'] ?? 0,
      episode: map['episode'] ?? 0,
      title: map['title'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
    );
  }
}
