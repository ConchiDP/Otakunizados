import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String province;
  final String imageUrl;
  final String type; // tipo de evento: cosplay, anime, manga, gaming, etc.
  final double price; // precio de entrada, 0 si es gratis
  final String organizador;
  final String contactInfo;
  final String url; // URL de la página oficial del evento

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.province,
    required this.imageUrl,
    required this.type,
    required this.price,
    required this.organizador,
    required this.contactInfo,
    required this.url,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'province': province,
      'imageUrl': imageUrl,
      'type': type,
      'price': price,
      'organizador': organizador,
      'contactInfo': contactInfo,
      'url': url,
    };
  }

  // Crear desde Map (desde Firebase)
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      location: map['location'] ?? '',
      province: map['province'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      organizador: map['organizador'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      url: map['url'] ?? '',
    );
  }
} 