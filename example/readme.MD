# Flutter Native View Example

Demonstrates how to use the native_view plugin.

## iOS Support

Info.plist

- Configure ```NSBonjourServices``` for iOS 14+. (```On iOS 14 and higher, enable the Dart multicast DNS service in the Debug version of your app to add debugging functionalities such as hot-reload and DevTools via flutter attach.```)

  ```
  <key>NSBonjourServices</key>
  <array>
    <string>_dartobservatory._tcp</string>
  </array>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>This app needs permission to access photo library.</string>
  <key>NSCameraUsageDescription</key>
  <string>This app needs permission to access camera.</string>
  ```

## Example

main.dart

```
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_camera/native_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void takePhoto() async {
    final Uint8List data = await NativeCamera.takePhoto();
    print("Success");
  }

  Widget _buildTakePhotoButton() => GestureDetector(
      onTap: takePhoto,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(width: 4, color: Colors.grey),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const IOSCameraView(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildTakePhotoButton(),
    );
  }
}
```