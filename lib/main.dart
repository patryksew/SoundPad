import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:soundbar/screens/pad_screen.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/sounds_provider.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SoundAdapter());
  await Hive.openBox('sounds');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SoundsProvider(),
      child: MaterialApp(
        title: 'Soundpad',
        home: PadScreen(),
      ),
    );
  }
}
