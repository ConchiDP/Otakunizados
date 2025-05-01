import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/event_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedProvince = 'Todas';
  List<String> _provinces = [];

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final provincesSnapshot =
          await FirebaseFirestore.instance.collection('provinces').get();

      final provincesList =
          provincesSnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _provinces = ['Todas', ...provincesList];
      });
    } catch (e) {
      print("Error al cargar las provincias: $e");
    }
  }

  Future<bool> _isRunningOnEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _provinces.isEmpty
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
                    value: _selectedProvince,
                    isExpanded: true,
                    items: _provinces.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedProvince = newValue;
                        });
                      }
                    },
                  ),
          ),
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: _getEventsByProvince(_selectedProvince),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return const Center(
                    child: Text('No hay eventos próximos en esta provincia'),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy').format(event.date)} - ${DateFormat('dd/MM/yyyy').format(event.endDate)}',
                            ),
                            Text('Lugar: ${event.location}'),
                            Text('Precio: ${event.price}'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          _showEventDetails(event);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<EventModel>> _getEventsByProvince(String province) {
    final query = FirebaseFirestore.instance.collection('events');
    final stream = (province == 'Todas'
        ? query.orderBy('date')
        : query.where('province', isEqualTo: province).orderBy('date'));
    return stream.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList());
  }

  void _showEventDetails(EventModel event) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(event.description,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(event.date)} - ${DateFormat('dd/MM/yyyy').format(event.endDate)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text('Ubicación: ${event.location}',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Precio: ${event.price}',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Organizador: ${event.organizador}',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              if (event.url.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () => _launchUrl(event.url),
                    child: const Text(
                        'Comprar entradas',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error al abrir URL: $e');
    }
  }
}