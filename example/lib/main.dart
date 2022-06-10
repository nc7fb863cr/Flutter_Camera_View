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
