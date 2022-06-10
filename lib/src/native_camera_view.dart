import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_camera/src/constants.dart';

class IOSCameraView extends StatefulWidget {
  const IOSCameraView();

  @override
  State<IOSCameraView> createState() => _IOSCameraViewState();
}

class _IOSCameraViewState extends State<IOSCameraView> {
  final Map<String, dynamic> creationParams = {};

  void setDimension() async {
    final screenSize = MediaQuery.of(context).size;
    await Constants.channel.invokeMethod(Constants.setDimension, {
      'width': screenSize.width,
      'height': screenSize.height,
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) => setDimension());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: Constants.viewType,
      creationParams: creationParams,
      layoutDirection: TextDirection.ltr,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
