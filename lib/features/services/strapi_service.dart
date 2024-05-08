import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import the http_parser package

class StrapiService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<dynamic>> getMediaFiles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/upload/files'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load media files');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> uploadMediaFile(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/upload'),
    );
    var stream = http.ByteStream(file.openRead());
    stream.cast();
    var length = await file.length();
    var multipartFileSign = http.MultipartFile(
      'files',
      stream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFileSign);

    var response = await request.send();
    if (response.statusCode == 200) {
      return response.stream.bytesToString();
    } else {
      throw Exception('Failed to upload media file');
    }
  }
}