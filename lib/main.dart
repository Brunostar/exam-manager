import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notify_me/screens/authentication/bluetooth_connection.dart';
import 'package:notify_me/screens/settings/settings.dart';

import 'database/database.dart';

void main() {
  // Make android status bar transparent for all the pages
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  WidgetsFlutterBinding.ensureInitialized();
  // create the database if it does not exist
  try {
    createDatabase();
  } catch (err) {
    print(err);
  } finally {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notify Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SettingsScreen(),
    );
  }
}
