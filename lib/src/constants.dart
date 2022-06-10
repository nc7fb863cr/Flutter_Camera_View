import 'package:flutter/services.dart';

class Constants {
  static const iosChannel = "nan.native_camera_view";
  static const viewType = "camera-view";
  static const channel = MethodChannel(Constants.iosChannel);

  // Call Method
  static const setDimension = "setDimension";
  static const switchCamera = "switchCamera";
  static const takePhoto = "takePhoto";
  static const canToggleFlash = "canToggleFlash";
  static const toggleFlash = "toggleFlash";
}
