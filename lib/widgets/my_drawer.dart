// ignore_for_file: use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/online_mode_provider.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          if (FirebaseAuth.instance.currentUser != null)
            TextButton(
              child: Row(
                children: const [
                  Icon(Icons.logout),
                  Text('Logout'),
                ],
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          if (FirebaseAuth.instance.currentUser == null)
            TextButton(
              child: Row(
                children: const [
                  Icon(Icons.login),
                  Text('Sign in'),
                ],
              ),
              onPressed: () {
                Provider.of<OnlineModeProvider>(context, listen: false).setMode(true);
              },
            ),
        ],
      )),
    );
  }
}
