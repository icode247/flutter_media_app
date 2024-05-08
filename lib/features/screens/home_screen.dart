import 'dart:convert';
import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:strapi_media_app/features/services/strapi_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> mediaFiles = [];
  StrapiService strapiService = StrapiService();

  @override
  void initState() {
    super.initState();
    fetchMediaFiles();
  }

  Future<void> fetchMediaFiles() async {
    try {
      final files = await strapiService.getMediaFiles();
      setState(() {
        mediaFiles = files;
      });
    } catch (e) {
      print('Error fetching media files: $e');
    }
  }

  Future<void> uploadMediaFile(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        final response = await strapiService.uploadMediaFile(file);
        List<dynamic> jsonResponse = jsonDecode(response);
        setState(() {
          mediaFiles.add(jsonResponse[0]);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading media file: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strapi Media Library'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: mediaFiles.length,
          itemBuilder: (context, index) {
            final file = mediaFiles[index];
            final imageUrl = StrapiService.baseUrl + file['url'];
            return ListTile(
              title: Text(file['name']),
              subtitle: Text(file['mime']),
              leading: Image.network(imageUrl),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => uploadMediaFile(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
