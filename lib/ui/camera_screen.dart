import 'package:flutter/material.dart';

import '../model/screen_params.dart';
import '../widget/detector_widget.dart';

/// [CameraScreen] stacks [DetectorWidget]
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      key: GlobalKey(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        // title: Image.asset('assets/images/tfl_logo.png'),
        title: const Text("Drowning Detection"),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: const DetectorWidget(),
    );
  }
}
