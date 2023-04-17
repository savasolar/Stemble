import 'package:flutter/material.dart';
import './pages/home.dart';
import './pages/tracks.dart';
import './pages/locations.dart';
import './pages/player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stemble',
      theme: ThemeData(
        primarySwatch: Colors.grey,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black//here you can give the text color
          )
      ),
      home: TracksPage(),//HomePage(),
//      initialRoute: '/',
//      routes: {
//        '/': (context) => HomePage(),
//        '/tracks': (context) => TracksPage(),
//        '/locations': (context) => LocationsPage(),
//        '/player': (context) => PlayerPage(),
//      },


    );
  }
}


