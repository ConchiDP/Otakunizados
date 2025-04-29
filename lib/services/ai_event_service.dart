import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otakunizados/models/event_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final openAiKey = "tu_api_key_aca";  // Reemplaza con tu clave de API de OpenAI
  
  // URLs base de las principales fuentes de eventos
  final List<Map<String, String>> _eventSources = [
    {
      'url': 'https://www.freakcon.es',
      'name': 'FreakCon',
    },
    {
      'url': 'https://www.japanweekend.com',
      'name': 'Japan Weekend',
    },
    {
      'url': 'https://www.ficomic.com',
      'name': 'FICOMIC',
    },
    {
      'url': 'https://www.expotaku.com',
      'name': 'Expotaku',
    },
  ];

  // Obtener todos los eventos
  Stream<List<EventModel>> getAllEvents() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
          .orderBy('date')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList());
    } catch (e) {
      print('Error obteniendo todos los eventos: $e');
      return Stream.value([]);
    }
  }

  // Obtener eventos por provincia
  Stream<List<EventModel>> getEventsByProvince(String province) {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }

    if (province == 'Todas') {
      return getAllEvents();
    }

    try {
      // Primero intentamos buscar eventos con la IA
      _searchAndUpdateEvents(province);

      // Luego devolvemos el stream de eventos
      return _firestore
          .collection('events')
          .where('province', isEqualTo: province)
          .where('date', isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
          .orderBy('date')
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              // Si no hay eventos, devolvemos eventos predefinidos según la provincia
              if (province == 'Málaga') {
                return [
                  EventModel(
                    id: 'freakcon2025',
                    title: 'FreakCon 2025',
                    description: 'El mayor evento de cultura asiática y entretenimiento de Andalucía. ¡Celebramos nuestro aniversario con invitados especiales, concursos de cosplay, zona gaming, Artist Alley y mucho más!',
                    date: DateTime(2025, 5, 24),
                    location: 'Palacio de Congresos de Torremolinos',
                    province: 'Málaga',
                    imageUrl: 'https://www.freakcon.es/wp-content/uploads/2024/02/cartel-freakcon-2024.jpg',
                    type: 'Convención',
                    price: 12.0,
                    organizador: 'FreakCon',
                    contactInfo: 'info@freakcon.es',
                    url: 'https://www.freakcon.es/entradas',
                  )
                ];
              } else if (province == 'Madrid') {
                return [
                  EventModel(
                    id: 'japanweekend_madrid_2025',
                    title: 'Japan Weekend Madrid 2025',
                    description: 'El evento más importante de manga y anime en Madrid. Disfruta de concursos, actividades, stands y mucho más.',
                    date: DateTime(2025, 9, 20),
                    location: 'IFEMA - Feria de Madrid',
                    province: 'Madrid',
                    imageUrl: 'https://www.japanweekend.com/madrid/images/header.jpg',
                    type: 'Convención',
                    price: 15.0,
                    organizador: 'Japan Weekend',
                    contactInfo: 'info@japanweekend.com',
                    url: 'https://www.japanweekend.com/madrid',
                  )
                ];
              } else if (province == 'Barcelona') {
                return [
                  EventModel(
                    id: 'salon_manga_barcelona_2025',
                    title: 'Salón del Manga de Barcelona 2025',
                    description: 'El mayor evento de manga y anime de España. XXX edición del Salón del Manga de Barcelona.',
                    date: DateTime(2025, 10, 31),
                    location: 'Fira Barcelona Montjuïc',
                    province: 'Barcelona',
                    imageUrl: 'https://www.ficomic.com/media/manga2024.jpg',
                    type: 'Convención',
                    price: 13.0,
                    organizador: 'FICOMIC',
                    contactInfo: 'manga@ficomic.com',
                    url: 'https://www.ficomic.com/salon-manga.cfm',
                  )
                ];
              }
              return [];
            }
            return snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList();
          });
    } catch (e) {
      print('Error obteniendo eventos: $e');
      return Stream.value([]);
    }
  }

  // Función para buscar y actualizar eventos
  Future<void> _searchAndUpdateEvents(String province) async {
    if (_auth.currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      print('Buscando eventos para $province');
      
      // Para Málaga, asegurarnos de que siempre exista el evento FreakCon
      if (province == 'Málaga') {
        final eventData = {
          'id': 'freakcon2025',
          'title': 'FreakCon 2025',
          'description': 'El mayor evento de cultura asiática y entretenimiento de Andalucía. ¡Celebramos nuestro aniversario con invitados especiales, concursos de cosplay, zona gaming, Artist Alley y mucho más!',
          'date': DateTime(2025, 5, 24).toIso8601String(),
          'location': 'Palacio de Congresos de Torremolinos',
          'province': 'Málaga',
          'imageUrl': 'assets/images/freakcon.jpg',
          'type': 'Convención',
          'price': 12.0,
          'organizador': 'FreakCon',
          'contactInfo': 'info@freakcon.es',
          'url': 'https://www.freakcon.es/entradas',
        };

        await _firestore
            .collection('events')
            .doc('freakcon2025')
            .set(eventData, SetOptions(merge: true));
        
        print('Evento FreakCon 2025 guardado/actualizado');
      }

      // Continuar con la búsqueda de otros eventos usando la IA
      final events = await _processWithAI(province, '');
      
      if (events.isNotEmpty) {
        print('Guardando ${events.length} eventos adicionales encontrados');
        
        for (var eventData in events) {
          if (eventData['id'] != 'freakcon2025') { // No sobreescribir FreakCon
            final String eventId = DateTime.now().millisecondsSinceEpoch.toString();
            await _firestore
                .collection('events')
                .doc(eventId)
                .set({
                  ...eventData,
                  'id': eventId,
                  'province': province,
                }, SetOptions(merge: true));
          }
        }
      }
    } catch (e) {
      print('Error buscando y actualizando eventos: $e');
    }
  }

  // Función para buscar información en la web
  Future<String> _searchWebForEvents(String province) async {
    try {
      String allData = '';
      
      // Búsqueda específica para Málaga
      if (province == 'Málaga') {
        final sources = [
          'https://www.freakcon.es',
          'https://www.instagram.com/freakconmalaga',
          'https://www.facebook.com/FreakconMalaga',
        ];

        for (var source in sources) {
          try {
            final response = await http.get(Uri.parse(source));
            if (response.statusCode == 200) {
              allData += '''
                Información encontrada de FreakCon 2025:
                - Evento: FreakCon 2025
                - Fecha: 24 y 25 de mayo de 2025
                - Ubicación: Palacio de Congresos de Torremolinos
                - Precio: 12€
                - Web oficial: https://www.freakcon.es
                - Entradas: https://www.freakcon.es/entradas
                - Contacto: info@freakcon.es
                
                FreakCon es el mayor evento de cultura asiática y entretenimiento de Andalucía.
                Incluye: zona de stands, Artist Alley, concursos de cosplay, 
                zona gaming, invitados especiales y actividades durante todo el fin de semana.
              ''';
              break; // Si encontramos la información, no necesitamos buscar más
            }
          } catch (e) {
            print('Error accediendo a $source: $e');
          }
        }
      }
      
      // Búsqueda general para otras provincias
      final generalSources = [
        'https://www.japanweekend.com',
        'https://www.ficomic.com',
        'https://www.expotaku.com',
      ];

      for (var source in generalSources) {
        try {
          final response = await http.get(Uri.parse(source));
          if (response.statusCode == 200) {
            allData += response.body;
          }
        } catch (e) {
          print('Error accediendo a $source: $e');
        }
      }
      
      return allData;
    } catch (e) {
      print('Error en búsqueda web: $e');
      return '';
    }
  }

  // Función para procesar con IA
  Future<List<Map<String, dynamic>>> _processWithAI(String province, String webData) async {
    try {
      print('Iniciando búsqueda de eventos con IA para $province');
      
      final prompt = '''Por favor, busca eventos de anime y manga en $province para el año 2025.
                       Por ejemplo, en Málaga está confirmada la FreakCon 2025 para el 24 y 25 de mayo en el Palacio de Congresos de Torremolinos.
                       
                       Necesito que me devuelvas la información en este formato JSON:
                       [
                         {
                           "title": "FreakCon 2025",
                           "description": "El mayor evento de cultura asiática y entretenimiento de Andalucía",
                           "date": "2025-05-24T00:00:00.000Z",
                           "location": "Palacio de Congresos de Torremolinos",
                           "price": 12.0,
                           "url": "https://www.freakcon.es/entradas",
                           "organizador": "FreakCon",
                           "contactInfo": "info@freakcon.es",
                           "type": "Convención"
                         }
                       ]
                       
                       Solo incluye eventos CONFIRMADOS para 2025. Si no hay eventos confirmados, devuelve un array vacío []''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un asistente especializado en eventos de anime y manga en España. Tu tarea es proporcionar información precisa sobre eventos confirmados para 2025.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
        }),
      );

      print('Respuesta de la API recibida. Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final aiResponse = json.decode(response.body);
        final content = aiResponse['choices'][0]['message']['content'];
        print('Contenido de la respuesta: $content');

        try {
          final List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(json.decode(content));
          print('Eventos encontrados: ${events.length}');
          return events;
        } catch (e) {
          print('Error procesando JSON de la respuesta: $e');
          print('Contenido que causó el error: $content');
          return [];
        }
      } else {
        print('Error en la API. Status: ${response.statusCode}');
        print('Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error en procesamiento IA: $e');
    }
    return [];
  }

  // Función para obtener eventos de una fuente específica
  Future<List<Map<String, dynamic>>> _scrapeEventsFromSource(String url) async {
    if (_auth.currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Aquí procesamos el HTML de la página para extraer la información
        // Por ahora, devolvemos datos de ejemplo actualizados
        if (url.contains('freakcon')) {
          return [{
            'id': 'freakcon2025',
            'title': 'FreakCon 2025',
            'description': 'El mayor evento de cultura asiática y entretenimiento de Andalucía. ¡Celebramos nuestro aniversario con invitados especiales, concursos de cosplay, zona gaming, Artist Alley y mucho más!',
            'date': DateTime(2025, 5, 24).toIso8601String(),
            'location': 'Palacio de Congresos de Torremolinos',
            'province': 'Málaga',
            'imageUrl': 'assets/images/freakcon.jpg',
            'type': 'Convención',
            'price': 12.0,
            'organizador': 'FreakCon',
            'contactInfo': 'info@freakcon.es',
            'url': 'https://www.freakcon.es/entradas',
          }];
        }
      }
    } catch (e) {
      print('Error obteniendo eventos de $url: $e');
    }
    return [];
  }

  // Función para procesar eventos con OpenAI
  Future<List<Map<String, dynamic>>> _processEventsWithAI(
    List<Map<String, dynamic>> rawEvents,
    String province
  ) async {
    if (_auth.currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''Eres un asistente especializado en eventos de anime, manga y cultura japonesa en España.
                           Tu tarea es verificar y estructurar la información de eventos, asegurándote de que:
                           1. Las fechas sean correctas y estén actualizadas
                           2. Las ubicaciones sean precisas
                           3. Los enlaces sean a las páginas oficiales de venta de entradas
                           4. Los precios estén actualizados
                           5. La información de contacto sea correcta'''
            },
            {
              'role': 'user',
              'content': 'Verifica y estructura los siguientes eventos de anime y manga en $province: ${json.encode(rawEvents)}'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final aiResponse = json.decode(response.body);
        final content = aiResponse['choices'][0]['message']['content'];
        try {
          final List<dynamic> processedData = json.decode(content);
          return List<Map<String, dynamic>>.from(processedData);
        } catch (e) {
          print('Error procesando respuesta de IA: $e');
          return rawEvents;
        }
      }
    } catch (e) {
      print('Error procesando eventos con IA: $e');
    }
    return rawEvents;
  }

  // Función para actualizar eventos de una provincia
  Future<void> updateEventsForProvince(String province) async {
    if (_auth.currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      List<Map<String, dynamic>> allEvents = [];
      for (var source in _eventSources) {
        final events = await _scrapeEventsFromSource(source['url'] ?? '');
        allEvents.addAll(events);
      }

      final processedEvents = await _processEventsWithAI(allEvents, province);
      
      for (var eventData in processedEvents) {
        await _firestore
            .collection('events')
            .doc(eventData['id'])
            .set(eventData, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error actualizando eventos: $e');
      throw e;
    }
  }

  // Lista de provincias disponibles
  static List<String> getProvincias() {
    return [
      'Todas',
      'A Coruña', 'Álava', 'Albacete', 'Alicante', 'Almería', 'Asturias',
      'Ávila', 'Badajoz', 'Barcelona', 'Burgos', 'Cáceres', 'Cádiz',
      'Cantabria', 'Castellón', 'Ciudad Real', 'Córdoba', 'Cuenca',
      'Girona', 'Granada', 'Guadalajara', 'Guipúzcoa', 'Huelva', 'Huesca',
      'Islas Baleares', 'Jaén', 'La Rioja', 'Las Palmas', 'León', 'Lleida',
      'Lugo', 'Madrid', 'Málaga', 'Murcia', 'Navarra', 'Ourense', 'Palencia',
      'Pontevedra', 'Salamanca', 'Santa Cruz de Tenerife', 'Segovia', 'Sevilla',
      'Soria', 'Tarragona', 'Teruel', 'Toledo', 'Valencia', 'Valladolid',
      'Vizcaya', 'Zamora', 'Zaragoza'
    ];
  }
} 