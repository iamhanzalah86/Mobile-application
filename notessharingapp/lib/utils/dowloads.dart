import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadAndOpenFile(String url, String fileName) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';

    await Dio().download(url, filePath);
    await OpenFile.open(filePath);
  } catch (e) {
    print('Download error: $e');
  }
}
