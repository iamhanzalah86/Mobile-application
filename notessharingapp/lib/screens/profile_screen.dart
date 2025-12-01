import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_services.dart';
import '../models/note.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // optional, null -> my profile
  ProfileScreen({this.userId});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final api = ApiService();
  List<Note> notes = [];
  String? profileName;
  bool following = false;

  @override void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final id = widget.userId ?? auth.userId;
    final res = await api.get('/users/$id', token: auth.token);
    setState(() {
      profileName = res['name'];
      notes = (res['notes'] as List).map((j)=> Note.fromJson(j)).toList();
      // check if following: res may have followers array; adjust as needed
      following = (res['followers'] as List).contains(auth.userId);
    });
  }

  @override Widget build(BuildContext ctx) {
    final auth = Provider.of<AuthProvider>(ctx);
    return Scaffold(
      appBar: AppBar(title: Text(profileName ?? 'Profile')),
      body: Column(children: [
        if (widget.userId != auth.userId) Row(children: [
          ElevatedButton(child: Text(following ? 'Unfollow' : 'Follow'), onPressed: () async {
            try {
              if (!following) {
                await api.post('/users/follow/${widget.userId}', {}, token: auth.token);
              } else {
                await api.post('/users/unfollow/${widget.userId}', {}, token: auth.token);
              }
              setState(()=> following = !following);
            } catch (e) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          })
        ]),
        Expanded(
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (_,i) => ListTile(title: Text(notes[i].title), subtitle: Text(notes[i].description),
                onTap: () { /* download or view */ }
            ),
          ),
        )
      ]),
    );
  }
}