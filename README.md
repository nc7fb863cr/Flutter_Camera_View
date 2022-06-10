# Native Camera View Plugin for Flutter

## Introduction

This plugin allows you to render camera overlay view on Flutter. Native platform functions like switching cameras, taking photos, toggling flashlight are included. The camera view will take the maximum space available by reading the value of ```MediaQuery.of(context).size```, and the UIView in Swift builds up its CGRect frame based on the value.

## Support Platform

- This plugin only support iOS (11+) currently.

## Add Dependency to Flutter

- Since the plugin has yet been published to [pub.dev](https://pub.dev/), add github repository to your pubspec.yaml as dependency.

  - url: Github Repo Url

  - ref: add branch name (**main**) or commit id (**6943abb**) 

  ```
  dependencies:
  ...
  flutter:
    sdk: flutter
  
  native_camera:
    git:
      url: https://github.com/nc7fb863cr/Flutter_Camera_View
      ref: <ref>
  ...
  ```

## IOS Platform Installation

- This plugin requires iOS 11.0 or higher.

- Add the following keys to **Info.plist**:

  * `NSPhotoLibraryUsageDescription` - Describe why this app needs permission for photo library

  * `NSCameraUsageDescription` - Describe why this app needs permission to access camera

    ```
    <key>NSPhotoLibraryUsageDescription</key>
    <string>add description here</string>
    <key>NSCameraUsageDescription</key>
    <string>add description here</string>
    ```

- **Note that the camera view works on real device only, the simulator won't show the overlay view.**

## How To Use

1. Switch Camera Position

  ```
  // returns an enum { front, rear, none }
  CameraPosition position = await NativeCamera.switchCamera();
  ```

2. Take Photos

  ```
  Uint8List result = await NativeCamera.takePhoto();
  Image image = Image.memory(result);
  ```

3. Toggle Flashlight (Rear Camera)

  ```
  bool isFlashlightTurnedOn = await NativeCamera.toggleFlashlight();
  ```

## Example

- [Flutter Camera View Example](example/readme.MD)