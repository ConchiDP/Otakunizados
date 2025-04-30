import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otakunizados/models/event_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedProvince = 'Todas'; // Provincia por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
      ),
      body: Column(
        children: [
          // Selector de provincia
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedProvince,
              isExpanded: true,
              items: _getProvincias()
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedProvince = newValue;
                  });
                }
              },
            ),
          ),
          // Lista de eventos
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: _getEventsByProvince(_selectedProvince),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy').format(event.date)} - ${DateFormat('dd/MM/yyyy').format(event.endDate)}', // Aquí se muestra tanto la fecha de inicio como la de fin
                            ),
                            Text(
                              'Lugar: ${event.location}',
                            ),
                            Text(
                              'Precio: ${event.price}', // Sin el símbolo de €
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          _showEventDetails(context, event);
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

  // Método para obtener las provincias disponibles
  List<String> _getProvincias() {
    return [
      'Todas', 'Madrid', 'Barcelona', 'Valencia', 'Málaga', 'Sevilla', 'Bilbao', 'Zaragoza', 'Alicante', 'Córdoba', 'Vigo'
    ];
  }

  // Método para obtener los eventos de Firestore filtrados por provincia
  Stream<List<EventModel>> _getEventsByProvince(String province) {
    if (province == 'Todas') {
      // No filtramos por provincia, mostramos todos los eventos
      return FirebaseFirestore.instance
          .collection('events') // Nombre de la colección en Firestore
          .orderBy('date') // Ordenamos por la fecha
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>))
                .toList();
          });
    } else {
      // Filtramos por provincia
      return FirebaseFirestore.instance
          .collection('events') // Nombre de la colección en Firestore
          .where('province', isEqualTo: province)
          .orderBy('date') // Ordenamos por la fecha
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>))
                .toList();
          });
    }
  }

  // Mostrar los detalles del evento en un modal
  void _showEventDetails(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(event.date)} - ${DateFormat('dd/MM/yyyy').format(event.endDate)}', // Aquí también se muestra la fecha de fin
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ubicación: ${event.location}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Precio: ${event.price}', // Asegúrate que el precio no tenga el símbolo de €
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Organizador: ${event.organizador}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              if (event.url.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Texto blanco
                    ),
                    onPressed: () async {
                      final Uri url = Uri.parse(event.url);

                      print("Intentando abrir la URL: ${event.url}"); // Log para depurar la URL
                      
                      try {
                        // Verificamos si la URL es válida y la lanzamos
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          // Si no se puede lanzar la URL
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo abrir la URL')),
                          );
                        }
                      } catch (e) {
                        // Capturamos cualquier error que ocurra al intentar abrir la URL
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al abrir la URL: $e')),
                        );
                      }
                    },
                    child: const Text('Comprar Entradas'),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
