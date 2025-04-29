import 'package:flutter/material.dart';
import 'package:otakunizados/models/news_model.dart';
import 'package:otakunizados/widgets/news_card.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de noticias de ejemplo
    final List<NewsModel> newsList = [
      NewsModel(
        id: '1',
        title: '¡Dandadan 2 revela su primer tráiler!',
        description: 'El esperado anime de Dandadan ha revelado su primer tráiler para su segunda temporada. El video nos muestra nuevas escenas impactantes que prometen una continuación aún más emocionante.',
        imageUrl: 'assets/images/dandadan_trailer.jpg',
        date: '26 de abril de 2025',
        source: 'Otakunizados',
        url: 'https://www.youtube.com/watch?v=8wZdzIsDEic',
      ),
      // Puedes agregar más noticias aquí
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Noticias', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NewsCard(
                  news: news,
                  onTap: () {
                    Navigator.pushNamed(context, '/news');
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 