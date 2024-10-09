import 'package:flutter/material.dart';

import '../model/screen_params.dart';
import '../widget/custom_app_bar.dart';
import '../widget/detector_widget.dart';

/// [CameraScreen] stacks [DetectorWidget]
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Deteksi Dengan Gambar",
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: DetectorWidget(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
