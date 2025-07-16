import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/event_model.dart';

class EventService {
  Future<List<String>> fetchProvinces() async {
    final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();
    final provincesSet = <String>{};
    for (var doc in eventsSnapshot.docs) {
      final province = doc.data()['province']?.toString().trim() ?? '';
      if (province.isNotEmpty) {
        provincesSet.add(province);
      }
    }
    return ['Todas', ...provincesSet.toList()];
  }

  Stream<List<EventModel>> getEventsByProvince(String province) {
    final collection = FirebaseFirestore.instance.collection('events');
    Query query;
    if (province == 'Todas') {
      query = collection.orderBy('date');
    } else {
      final cleanProvince = province.trim();
      query = collection.where('province', isEqualTo: cleanProvince).orderBy('date');
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return EventModel.fromMap(data);
      }).toList();
    });
  }
} 
