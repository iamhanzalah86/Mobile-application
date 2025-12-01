import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_services.dart';

class UploadNoteScreen extends StatefulWidget {
  @override State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final categoryC = TextEditingController();
  String? pickedPath;
  bool uploading = false;

  @override Widget build(BuildContext ctx) {
    final auth = Provider.of<AuthProvider>(ctx);
    final api = ApiService();
    return Scaffold(
      appBar: AppBar(title: Text('Upload Note')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: titleC, decoration: InputDecoration(labelText:'Title')),
          TextField(controller: descC, decoration: InputDecoration(labelText:'Description')),
          TextField(controller: categoryC, decoration: InputDecoration(labelText:'Category')),
          SizedBox(height:12),
          Row(children: [
            ElevatedButton(
              child: Text('Pick File'),
              onPressed: () async {
                final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','doc','docx','png','jpg','jpeg']);
                if (res != null && res.files.single.path != null) {
                  setState(() { pickedPath = res.files.single.path; });
                }
              },
            ),
            SizedBox(width:12),
            Expanded(child: Text(pickedPath ?? 'No file selected', overflow: TextOverflow.ellipsis))
          ]),
          SizedBox(height:20),
          ElevatedButton(
              child: uploading ? CircularProgressIndicator(color: Colors.white) : Text('Upload'),
              onPressed: () async {
                if (pickedPath == null) { ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Pick file first'))); return; }
                setState((){ uploading = true; });
                try {
                  final res = await api.multipartPost('/notes', {
                    'title': titleC.text, 'description': descC.text, 'category': categoryC.text, 'tags':''
                  }, pickedPath!, 'file', auth.token!);
                  setState(()=> uploading = false);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Uploaded')));
                  Navigator.pop(ctx);
                } catch (e) {
                  setState(()=> uploading = false);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
          )
        ]),
      ),
    );
  }
}