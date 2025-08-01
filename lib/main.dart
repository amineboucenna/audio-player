import 'package:flutter/material.dart';
import 'FolderScreen.dart'; // Import the FolderScreen
import 'PlaylistTracks.dart'; // Import the PlaylistTracks screen
import 'PlayingLayout.dart'; // Import the PlayingLayout screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FolderScreen(),
        '/playlistTracks': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PlaylistTracks(
            audioFiles: args['audioFiles'],
            playlistName: args['playlistName'],
          );
        },
        '/player': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PlayingLayout(
            audioFiles: args['audioFiles'],
            playlistName: args['playlistName'],
            initialIndex: args['initialIndex'],
          );
        },
      },
    );
  }
}
