import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:otakunizados/core/firebase_options.dart';
import 'package:otakunizados/screens/auth/forgot_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:otakunizados/provider/login_provider.dart';
import 'package:otakunizados/screens/auth/login_screen.dart';
import 'package:otakunizados/screens/auth/register_screen.dart';
import 'package:otakunizados/screens/home/home_screen.dart';
import 'package:otakunizados/screens/news/news_screen.dart';
import 'package:otakunizados/screens/news/news_list_screen.dart';
import 'package:otakunizados/screens/events/events_screen.dart';
import 'package:otakunizados/screens/calendar/calendar_screen.dart'; // AÑADIDO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const OtakunizadosApp(),
    ),
  );
}

class OtakunizadosApp extends StatelessWidget {
  const OtakunizadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otakunizados',
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot': (context) => ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/news': (context) => const NewsScreen(),
        '/news-list': (context) => const NewsListScreen(),
        '/events': (context) => const EventsScreen(),
        '/calendar': (context) => const CalendarScreen(), // AÑADIDO
      },
    );
  }
}
