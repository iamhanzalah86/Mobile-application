// main.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const GlassNotesApp());
}

class GlassNotesApp extends StatelessWidget {
  const GlassNotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glass Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Models
class Note {
  String id;
  DateTime date;
  String title;
  String content;
  List<String> imagePaths;
  List<String> audioPaths;
  List<TodoItem> todos;
  String? drawingData;
  bool isLocked;
  String? passwordHash;
  DateTime createdAt;
  DateTime updatedAt;
  List<Offset> drawingPoints;


  Note({
    required this.id,
    required this.date,
    this.title = '',
    this.content = '',
    List<String>? imagePaths,
    List<String>? audioPaths,
    List<TodoItem>? todos,
    this.drawingData,
    this.isLocked = false,
    this.passwordHash,
    this.drawingPoints =const[],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : imagePaths = imagePaths ?? [],
        audioPaths = audioPaths ?? [],
        todos = todos ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'content': content,
    'imagePaths': imagePaths,
    'audioPaths': audioPaths,
    'todos': todos.map((t) => t.toJson()).toList(),
    'drawingData': drawingData,
    'isLocked': isLocked,
    'passwordHash': passwordHash,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    date: DateTime.parse(json['date']),
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    imagePaths: List<String>.from(json['imagePaths'] ?? []),
    audioPaths: List<String>.from(json['audioPaths'] ?? []),
    todos: (json['todos'] as List?)
        ?.map((t) => TodoItem.fromJson(t))
        .toList() ??
        [],
    drawingData: json['drawingData'],
    isLocked: json['isLocked'] ?? false,
    passwordHash: json['passwordHash'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class TodoItem {
  String id;
  String text;
  bool isCompleted;

  TodoItem({required this.id, required this.text, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'],
    text: json['text'],
    isCompleted: json['isCompleted'] ?? false,
  );
}

// Storage Service
class NotesStorage {
  static const String _notesKey = 'notes_storage';

  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString(_notesKey);
    if (notesJson == null) return [];

    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((json) => Note.fromJson(json)).toList();
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final String notesJson = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_notesKey, notesJson);
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await NotesStorage.loadNotes();
    setState(() {
      _notes = notes;
    });
  }

  List<Note> _getNotesForDay(DateTime day) {
    return _notes.where((note) => isSameDay(note.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade200,
              Colors.purple.shade200,
              Colors.pink.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildGlassHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCalendar(),
                      const SizedBox(height: 20),
                      _buildNotesForSelectedDay(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewNote(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Glass Notes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.view_list, color: Colors.white),
                      onPressed: () => _showAllNotes(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => _showSettings(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) => _getNotesForDay(day),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(color: Colors.white),
                weekendTextStyle: const TextStyle(color: Colors.white70),
                outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              ),
              headerStyle: const HeaderStyle(
                formatButtonTextStyle: TextStyle(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesForSelectedDay() {
    final notes = _getNotesForDay(_selectedDay ?? DateTime.now());

    if (notes.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        child: Text(
          "No notes for ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? DateTime.now())}",
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index]);
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                note.isLocked ? Icons.lock : Icons.note,
                color: Colors.white,
              ),
              title: Text(
                note.title.isEmpty ? 'Untitled Note' : note.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                note.content.isEmpty ? 'Tap to edit' : note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () => _openNote(note),
            ),
          ),
        ),
      ),
    );
  }

  void _createNewNote() {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDay ?? DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: newNote,
          onSave: (note) async {
            setState(() {
              _notes.add(note);
            });
            await NotesStorage.saveNotes(_notes);
          },
        ),
      ),
    );
  }

  void _openNote(Note note) {
    if (note.isLocked) {
      _showPasswordDialog(note);
    } else {
      _navigateToEditor(note);
    }
  }

  void _showPasswordDialog(Note note) {
    // Password dialog implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Password'),
          onSubmitted: (value) {
            final hash = sha256.convert(utf8.encode(value)).toString();
            if (hash == note.passwordHash) {
              Navigator.pop(context);
              _navigateToEditor(note);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incorrect password')),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToEditor(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          onSave: (updatedNote) async {
            setState(() {
              final index = _notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
            await NotesStorage.saveNotes(_notes);
          },
          onDelete: () async {
            setState(() {
              _notes.removeWhere((n) => n.id == note.id);
            });
            await NotesStorage.saveNotes(_notes);
          },
        ),
      ),
    );
  }

  void _showAllNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllNotesScreen(
          notes: _notes,
          onNotesChanged: (notes) async {
            setState(() {
              _notes = notes;
            });
            await NotesStorage.saveNotes(_notes);
          },
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('App Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developed with Flutter'),
            SizedBox(height: 8),
            Text('Glass Notes © 2024'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Note Editor Screen
class NoteEditorScreen extends StatefulWidget {
  final Note note;
  final Function(Note) onSave;
  final VoidCallback? onDelete;

  const NoteEditorScreen({
    Key? key,
    required this.note,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class DrawingScreen extends StatefulWidget {
  final List<Offset> initialPoints;
  const DrawingScreen({super.key, required this.initialPoints});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late List<Offset> _points;

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.initialPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drawing"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _points),
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            _points.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanEnd: (_) => _points.add(Offset.infinite),
        child: CustomPaint(
          painter: _DrawingPainter(points: _points),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset> points;
  _DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note _note;
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleController = TextEditingController(text: _note.title);
    _contentController = TextEditingController(text: _note.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade200,
              Colors.purple.shade200,
              Colors.pink.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildContentField(),
                      const SizedBox(height: 16),
                      _buildTodoList(),
                      const SizedBox(height: 16),
                      _buildMediaSection(),
                    ],
                  ),
                ),
              ),
              _buildToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => _saveAndExit(),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_note.date),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Lock Note'),
                      onTap: () => _setPassword(),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () => _deleteNote(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setPassword() {
    showDialog(
      context: context,
      builder: (context) {
        String password = '';
        return AlertDialog(
          title: const Text('Set Password'),
          content: TextField(
            obscureText: true,
            onChanged: (value) => password = value,
            decoration: const InputDecoration(hintText: 'Enter password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (password.isNotEmpty) {
                  setState(() {
                    _note.isLocked = true;
                    _note.passwordHash =
                        sha256.convert(utf8.encode(password)).toString();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password set successfully')),
                  );
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildTitleField() {
    return _buildGlassContainer(
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: 'Title',
          hintStyle: TextStyle(color: Colors.white60),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return _buildGlassContainer(
      child: TextField(
        controller: _contentController,
        style: const TextStyle(color: Colors.white),
        maxLines: 10,
        decoration: const InputDecoration(
          hintText: 'Start writing...',
          hintStyle: TextStyle(color: Colors.white60),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    if (_note.todos.isEmpty) return const SizedBox.shrink();

    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To-Do List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._note.todos.map((todo) => CheckboxListTile(
            title: Text(
              todo.text,
              style: TextStyle(
                color: Colors.white,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            value: todo.isCompleted,
            onChanged: (value) {
              setState(() {
                todo.isCompleted = value ?? false;
              });
            },
          )),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      children: [
        if (_note.imagePaths.isNotEmpty) _buildImages(),
        if (_note.audioPaths.isNotEmpty) _buildAudioList(),
      ],
    );
  }

  Widget _buildImages() {
    return _buildGlassContainer(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _note.imagePaths
            .map((path) => Image.file(File(path), width: 100, height: 100))
            .toList(),
      ),
    );
  }

  Widget _buildAudioList() {
    return _buildGlassContainer(
      child: Column(
        children: _note.audioPaths
            .map((path) => ListTile(
          leading: const Icon(Icons.audiotrack, color: Colors.white),
          title: Text(
            path.split('/').last,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () => _playAudio(path),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.white),
                  onPressed: () => _pickImage(),
                ),
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _toggleRecording(),
                ),
                IconButton(
                  icon: const Icon(Icons.checklist, color: Colors.white),
                  onPressed: () => _addTodoItem(),
                ),
                IconButton(
                  icon: const Icon(Icons.brush, color: Colors.white),
                  onPressed: () => _openDrawing(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _note.imagePaths.add(image.path);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _note.audioPaths.add(path);
          _isRecording = false;
        });
      }
    } else {
      if (await Permission.microphone.request().isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  Future<void> _playAudio(String path) async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(path));
  }

  void _addTodoItem() {
    showDialog(
      context: context,
      builder: (context) {
        String todoText = '';
        return AlertDialog(
          title: const Text('Add To-Do'),
          content: TextField(
            onChanged: (value) => todoText = value,
            decoration: const InputDecoration(hintText: 'Enter task'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (todoText.isNotEmpty) {
                  setState(() {
                    _note.todos.add(TodoItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: todoText,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }


  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _openDrawing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawingScreen(initialPoints: _note.drawingPoints),
      ),
    );

    if (result != null && result is List<Offset>) {
      setState(() {
        _note.drawingPoints = result;
      });
    }
  }
  void _saveAndExit() {
    _note.title = _titleController.text;
    _note.content = _contentController.text;
    _note.updatedAt = DateTime.now();
    widget.onSave(_note);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

// All Notes Screen
class AllNotesScreen extends StatefulWidget {
  final List<Note> notes;
  final Function(List<Note>) onNotesChanged;

  const AllNotesScreen({
    Key? key,
    required this.notes,
    required this.onNotesChanged,
  }) : super(key: key);

  @override
  State<AllNotesScreen> createState() => _AllNotesScreenState();
}

class _AllNotesScreenState extends State<AllNotesScreen> {
  late List<Note> _notes;
  bool _isGridView = false;
  String _sortBy = 'date'; // 'date' or 'time'

  @override
  void initState() {
    super.initState();
    _notes = List.from(widget.notes);
    _sortNotes();
  }

  void _sortNotes() {
    if (_sortBy == 'date') {
      _notes.sort((a, b) => b.date.compareTo(a.date));
    } else {
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade200,
              Colors.purple.shade200,
              Colors.pink.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isGridView ? _buildGridView() : _buildListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'All Notes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(_isGridView ? Icons.list : Icons.grid_view),
                          const SizedBox(width: 8),
                          Text(_isGridView ? 'List View' : 'Grid View'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.sort),
                          SizedBox(width: 8),
                          Text('Sort by Date'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _sortBy = 'date';
                          _sortNotes();
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 8),
                          Text('Sort by Time'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _sortBy = 'time';
                          _sortNotes();
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 8),
                          Text('App Info'),
                        ],
                      ),
                      onTap: () => _showAppInfo(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_notes.isEmpty) {
      return Center(
        child: Text(
          'No notes yet',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(_notes[index]);
      },
    );
  }

  Widget _buildGridView() {
    if (_notes.isEmpty) {
      return Center(
        child: Text(
          'No notes yet',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 18,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return _buildNoteGridCard(_notes[index]);
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                note.isLocked ? Icons.lock : Icons.note,
                color: Colors.white,
              ),
              title: Text(
                note.title.isEmpty ? 'Untitled Note' : note.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content.isEmpty ? 'No content' : note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(note.date),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () => _editNote(note),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () => _deleteNote(note),
                  ),
                ],
              ),
              onTap: () => _editNote(note),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteGridCard(Note note) {
    return GestureDetector(
      onTap: () => _editNote(note),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      note.isLocked ? Icons.lock : Icons.note,
                      color: Colors.white,
                      size: 20,
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () => _editNote(note),
                        ),
                        PopupMenuItem(
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onTap: () => _deleteNote(note),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.title.isEmpty ? 'Untitled Note' : note.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    note.content.isEmpty ? 'No content' : note.content,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(note.date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          onSave: (updatedNote) {
            setState(() {
              final index = _notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
            widget.onNotesChanged(_notes);
          },
          onDelete: () {
            setState(() {
              _notes.removeWhere((n) => n.id == note.id);
            });
            widget.onNotesChanged(_notes);
          },
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
              });
              widget.onNotesChanged(_notes);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Glass Notes App', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developed with Flutter'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Calendar integration'),
            Text('• Text notes'),
            Text('• Voice recordings'),
            Text('• Image attachments'),
            Text('• To-do lists'),
            Text('• Password protection'),
            Text('• Drawing support'),
            SizedBox(height: 8),
            Text('© 2024 Glass Notes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
