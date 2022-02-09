// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/sounds_provider.dart';

class CustomGrid extends StatelessWidget {
  final List items;
  final List<GridItem> tiles = [];

  CustomGrid({required this.items}) {
    for (Sound item in items) {
      tiles.add(GridItem(
        id: item.id,
        soundFile: item.soundFile,
        name: item.name,
        imageFile: item.imageFile,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) => GridView(
        padding: const EdgeInsets.all(10),
        children: tiles,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final File? imageFile;
  final File soundFile;
  final String name;
  final int id;

  const GridItem({this.imageFile, required this.soundFile, required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          AudioPlayer().play(soundFile.path, isLocal: true);
        },
        child: GridTile(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Are you sure you want to delete $name?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('No')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Provider.of<SoundsProvider>(context, listen: false).delete(id);
                              },
                              child: const Text('Yes'))
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, color: Colors.white)),
            ],
          ),
          child: imageFile == null
              ? Container(color: Colors.red)
              : Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Center(
              child: Text(name),
            ),
          ),
        ),
      ),
    );
  }
}
