class NewsModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String source;
  final String url;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.source,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: json['date'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
    );
  }
} 