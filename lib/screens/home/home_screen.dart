import 'package:flutter/material.dart';
import 'package:otakunizados/widgets/app_scaffold.dart';
import 'package:otakunizados/widgets/bottom_nav_bar.dart';
import 'package:otakunizados/models/news_model.dart';
import 'package:otakunizados/widgets/news_card.dart';
import 'package:otakunizados/screens/calendar/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 1) {
      Navigator.pushNamed(context, '/my-lists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bienvenido',
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D47A1), Colors.black],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '¡Bienvenido a Otakunizados!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Donde tu mundo otaku cobra vida.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    
                    const Text(
                      'Noticias Destacadas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final news = NewsModel(
                            id: '1',
                            title: '¡Dandadan 2 revela su primer tráiler!',
                            description: 'El esperado anime de Dandadan ha revelado su primer tráiler para su segunda temporada. El video nos muestra nuevas escenas impactantes que prometen una continuación aún más emocionante.',
                            imageUrl: 'assets/images/dandadan_trailer.jpg',
                            date: '26 de abril de 2025',
                            source: 'Otakunizados',
                            url: 'https://www.youtube.com/watch?v=8wZdzIsDEic',
                          );
                          return NewsCard(
                            news: news,
                            onTap: () {
                              Navigator.pushNamed(context, '/news');
                            },
                            isHorizontal: true,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    
                    _buildNavButton(
                      icon: Icons.newspaper,
                      title: 'Noticias',
                      onTap: () {
                        Navigator.pushNamed(context, '/news-list');
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildNavButton(
                      icon: Icons.calendar_today,
                      title: 'Calendario',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CalendarScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildNavButton(
                      icon: Icons.event,
                      title: 'Eventos',
                      onTap: () {
                        Navigator.pushNamed(context, '/events');
                      },
                    ),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
