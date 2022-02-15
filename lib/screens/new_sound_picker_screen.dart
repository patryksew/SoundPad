import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/sounds_provider.dart';

// ignore: use_key_in_widget_constructors
class NewSoundPickerScreen extends StatefulWidget {
  @override
  State<NewSoundPickerScreen> createState() => _NewSoundPickerScreenState();
}

class _NewSoundPickerScreenState extends State<NewSoundPickerScreen> {
  File? cachedSoundFile;
  File? cachedImageFile;

  late File soundFile;
  File? imageFile;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new sound'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cachedSoundFile == null ? Colors.grey : null,
        onPressed: cachedSoundFile == null
            ? null
            : () async {
                await Provider.of<SoundsProvider>(context, listen: false)
                    .add(cachedSoundFile: cachedSoundFile!, cachedImageFile: cachedImageFile, name: _controller.text);
                Navigator.pop(context);
              },
        label: const Text('Submit'),
        icon: const Icon(Icons.done),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12, right: 12, left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cachedImageFile == null
                    ? Container(color: Colors.red, width: 100, height: 100)
                    : Image.file(cachedImageFile!, width: 100, height: 100, fit: BoxFit.cover),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () async {
                      cachedImageFile = await pickFile(FileType.image, extensions: ['jpg', 'png']);
                      setState(() {});
                    },
                    child: const Text('Select image')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: cachedSoundFile == null
                        ? null
                        : () {
                            AudioPlayer().play(cachedSoundFile!.path, isLocal: true);
                          },
                    icon: const Icon(Icons.play_arrow)),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () async {
                      cachedSoundFile = await pickFile(FileType.audio);
                      setState(() {});
                    },
                    child: const Text('Select sound')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Future<File?> pickFile(FileType type, {List<String>? extensions}) async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: extensions == null ? type : FileType.custom, allowedExtensions: extensions);
  if (result == null) return null;
  File file = File(result.files.single.path!);
  if (type == FileType.image) {
    file = (await FlutterImageCompress.compressAndGetFile(file.path, '${file.path}compressed.jpg',
        quality: 60, minHeight: 600, minWidth: 400))!;
  }
  return file;
}
