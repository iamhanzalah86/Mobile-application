import 'package:flutter/material.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProfileApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _validationMessage = '';
  String _displayName = 'John Doe';
  String _displayEmail = 'john.doe@example.com';

  void _validateAndUpdateUsername() {
    setState(() {
      if (_usernameController.text.isEmpty) {
        _validationMessage = 'Username cannot be empty!';
      } else {
        _validationMessage = '';
        _displayName = _usernameController.text;
        _displayEmail = '${_usernameController.text.toLowerCase().replaceAll(' ', '.')}@example.com';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current screen orientation
    final orientation = MediaQuery.of(context).orientation;
    final orientationText = orientation == Orientation.portrait
        ? 'Portrait'
        : 'Landscape';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Screen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile picture
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
              ),

              // RichText widget with name and email
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_displayName\n',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: _displayEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              // Row with two buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit Profile pressed')),
                      );
                    },
                    child: Text('Edit Profile'),
                  ),
                  SizedBox(width: 15),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Settings pressed')),
                      );
                    },
                    child: Text('Settings'),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Container with background color and padding
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'This is a profile app that demonstrates the use of basic Flutter widgets including Scaffold, Column, Row, Image/Icon, RichText, buttons, Container, TextField, and MediaQuery for orientation detection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),

              SizedBox(height: 20),

              // TextField to edit username
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Edit Username',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username',
                  ),
                  onChanged: (value) {
                    _validateAndUpdateUsername();
                  },
                ),
              ),

              // Validation message
              if (_validationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _validationMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              SizedBox(height: 20),

              // Display screen orientation using MediaQuery
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current Orientation: $orientationText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}