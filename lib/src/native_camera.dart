import 'dart:typed_data';
import 'package:native_camera/native_camera.dart';
import 'package:native_camera/src/constants.dart';

class NativeCamera {
  static Future<CameraPosition> switchCamera() async {
    final String cameraPosition = await Constants.channel.invokeMethod(Constants.switchCamera);
    return cameraPosition.position;
  }

  static Future<Uint8List> takePhoto() async {
    final Uint8List data = await Constants.channel.invokeMethod(Constants.takePhoto);
    return data;
  }

  static Future<bool> canToggleFlashlight(CameraPosition position) async {
    final result = await Constants.channel.invokeMethod(Constants.canToggleFlash);
    return result;
  }

  static Future<bool> toggleFlashlight() async {
    final result = await Constants.channel.invokeMethod(Constants.toggleFlash);
    return result;
  }
}
