import 'package:flutter/material.dart';
import 'package:navigation/map_page.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Do uzycia sensorow konieczne sa uprawnienia lokalizacji',
              ),
            ),
            ElevatedButton(
              child: const Text('Przyznaj uprawnienia'),
              onPressed: () {
                Permission.locationWhenInUse.request().then((ignored) {
                  _fetchPermissionStatus(context);
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Otworz ustawienia'),
              onPressed: () {
                openAppSettings().then((opened) {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _fetchPermissionStatus(BuildContext context) {
    Permission.locationWhenInUse.status.then((status) {
      if (status.isGranted) {
        Navigator.pushReplacementNamed(context, MapPage.routeName);
      }
    });
  }
}
