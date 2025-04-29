import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Episodios'),
      ),
      body: const Center(
        child: Text(
          'Próximamente: Calendario de nuevos episodios',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 