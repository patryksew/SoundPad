import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soundbar/screens/auth_screen.dart';
import 'package:soundbar/screens/loading_screen.dart';

import 'package:soundbar/screens/pad_screen.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/sounds_provider.dart';

import 'online_mode_provider.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SoundAdapter());
  await Hive.openBox('sounds');
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnlineModeProvider()),
        ChangeNotifierProxyProvider<OnlineModeProvider, SoundsProvider>(
          create: (_) => SoundsProvider(() => Future(() => false)),
          update: (_, onlineModeProvider, __) => SoundsProvider(onlineModeProvider.getMode),
        ),
      ],
      builder: (context, _) => MaterialApp(
        title: 'Soundpad',
        home: FutureBuilder(
          future: Provider.of<OnlineModeProvider>(context).getMode(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return LoadingScreen();
            //In offline mode there is no need to auth
            //snapshot.data being isOnlineMode
            if (!(snapshot.data as bool)) return PadScreen();
            //Online mode:
            return FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingScreen();
                }
                return StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) return PadScreen();
                    return AuthScreen();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
