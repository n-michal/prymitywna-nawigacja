import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigation/permissions_page.dart';
import 'package:navigation/map_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prymitywna nawigacja',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const PermissionsPage(),
      routes: {
        MapPage.routeName: (context) => const MapPage(),
      },
    );
  }
}
