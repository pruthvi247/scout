import 'package:flutter/material.dart';
import 'package:scout/presentations/screens/intro_screen.dart';
import 'package:scout/presentations/screens/login_screen.dart';
import 'package:scout/presentations/screens/home_screen.dart';
import 'package:scout/presentations/screens/add_activity_screen.dart';
import 'package:scout/presentations/screens/activity_details_screen.dart';
import 'package:scout/presentations/screens/profile_screen.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const ScoutApp());
}

class ScoutApp extends StatefulWidget {
  const ScoutApp({super.key});

  @override
  _ScoutAppState createState() => _ScoutAppState();
}

class _ScoutAppState extends State<ScoutApp> {
  List<String> _quotes = [];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer Activity Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_activity': (context) => const AddActivityScreen(),
        '/activity_details': (context) => const ActivityDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }

  Future<void> _loadQuotes() async {
    final quotesString =
        await rootBundle.loadString('assets/intro-images/quotes.txt');
    setState(() {
      _quotes =
          quotesString.split('\n').where((q) => q.trim().isNotEmpty).toList();
    });
  }
}
