// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/screens/new_sound_picker_screen.dart';
import 'package:soundbar/sounds_provider.dart';
import 'package:soundbar/widgets/custom_grid.dart';

class PadScreen extends StatefulWidget {
  @override
  State<PadScreen> createState() => _PadScreenState();
}

class _PadScreenState extends State<PadScreen> {
  @override
  Widget build(BuildContext context) {
    final soundProvider = Provider.of<SoundsProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Soundpad'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewSoundPickerScreen()));
              },
            )
          ],
        ),
        body: soundProvider.isNotEmpty
            ? CustomGrid(items: soundProvider.getSounds)
            : Center(
                child: Text(
                'No sounds added yet, start adding some!',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              )));
  }
}
