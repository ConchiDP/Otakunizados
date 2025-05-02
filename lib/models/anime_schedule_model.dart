import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeSchedule {
  final String title;
  final int airingAt; // Aquí aseguramos que sea un 'int' para almacenar el timestamp
  final int episode;
  final String coverImageUrl;

  AnimeSchedule({
    required this.title,
    required this.airingAt,
    required this.episode,
    required this.coverImageUrl,
  });

  // Método de fábrica para crear el objeto a partir de un Map (como se recibe del servidor)
  factory AnimeSchedule.fromMap(Map<String, dynamic> map) {
    return AnimeSchedule(
      title: map['media']['title']['romaji'] ?? 'Desconocido',
      airingAt: map['airingAt'],  // Asegurarse que esto sea un 'int' (timestamp)
      episode: map['episode'] ?? 1,
      coverImageUrl: map['media']['coverImage']['large'] ?? '',
    );
  }

  // Método para convertir el modelo a un Map (si necesitas guardarlo en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'airingAt': airingAt,  // Guardamos como 'int'
      'episode': episode,
      'coverImageUrl': coverImageUrl,
    };
  }
}
