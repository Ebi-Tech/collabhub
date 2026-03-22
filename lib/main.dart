import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:collabhub/firebase_options.dart';
import 'package:collabhub/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CollabHubApp());
}
