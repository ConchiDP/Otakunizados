import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String title;
  final String route;
  const MenuItem({required this.id, required this.title, required this.route});
}

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;

  static const List<MenuItem> menuItems = [
    MenuItem(id: 'profile', title: 'Perfil', route: '/profile'),
    MenuItem(id: 'settings', title: 'Configuración', route: '/settings'),
    MenuItem(id: 'logout', title: 'Cerrar sesión', route: '/login'),
  ];

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    void _onMenuSelected(MenuItem item) {
      if (item.id == 'logout') {
        Navigator.pushReplacementNamed(context, item.route);
      } else {
        Navigator.pushNamed(context, item.route);
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            
            Image.asset(
              'assets/Otakunizados.jpg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          
          PopupMenuButton<MenuItem>(
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) {
              return menuItems.map((item) {
                return PopupMenuItem<MenuItem>(
                  value: item,
                  child: Text(item.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
