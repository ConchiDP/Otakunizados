import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime endDate;
  final String location;
  final String province;
  final String type;
  final String price;
  final String organizador;
  final String url;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.endDate,
    required this.location,
    required this.province,
    required this.type,
    required this.price,
    required this.organizador,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'province': province,
      'type': type,
      'price': price,
      'organizador': organizador,
      'url': url,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      endDate: map['end_date'] is Timestamp
          ? (map['end_date'] as Timestamp).toDate()
          : DateTime.parse(map['end_date']),
      location: map['location'] ?? '',
      province: map['province'] ?? '',
      type: map['type'] ?? '',
      price: map['price'] ?? '',
      organizador: map['organizador'] ?? '',
      url: map['url'] ?? '',
    );
  }
}
