import 'package:flutter/material.dart';
import 'package:notessharingapp/providers/notes_provider.dart';
import 'package:notessharingapp/screens/search_user_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/upload_note_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => AuthProvider()), ChangeNotifierProvider(create: (_) => NotesProvider()), ChangeNotifierProvider(create: (_) => UserProvider()) ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes Sharing',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/feed': (_) => FeedScreen(),
        '/search': (_) => SearchScreen(),
        '/upload': (_) => UploadNoteScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}