import 'dart:io';
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for base64 encoding

import '../model/detection.dart';
import '../service/object_detection.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_button.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final imagePicker = ImagePicker();
  ObjectDetection? objectDetection;

  Uint8List? image;
  DetectionData? detectionData;

  void detect(String path) {
    var (imageResult, detectionResult, durationResult) =
        objectDetection!.analyseImage(path);

    image = imageResult;
    detectionData = DetectionData(
      results: detectionResult,
      duration: durationResult.toString(),
      image: base64Encode(imageResult), // Convert image to base64
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    objectDetection = ObjectDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: detectionData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: InkWell(
                        onTap: () {
                          image = null;
                          detectionData = null;
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.chevron_left,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: Center(child: Image.memory(image!))),
                  const SizedBox(height: 10),
                  _statsWidget(),
                ],
              )
            : CameraAwesomeBuilder.custom(
                builder: (cameraState, previewSize, previewRect) {
                  return cameraState.when(
                    onPreparingCamera: (state) =>
                        const Center(child: CircularProgressIndicator()),
                    onPhotoMode: (state) => Column(
                      children: [
                        const Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Center(
                                  child: AwesomeCameraSwitchButton(
                                    state: state,
                                  ),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  state.takePhoto().then((value) {
                                    //
                                    print(value);
                                    detect(value);
                                  });
                                },
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Transform.scale(
                                    scale: 1,
                                    child: CustomPaint(
                                      painter: state.when(
                                        onPhotoMode: (_) =>
                                            CameraButtonPainter(),
                                        onPreparingCamera: (_) =>
                                            CameraButtonPainter(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: AwesomeCameraGalleryButton(
                                    state: state,
                                    onSwitchTap: (p0) async {
                                      final result =
                                          await imagePicker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (result != null) {
                                        detect(result.path);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                saveConfig: SaveConfig.photo(
                  pathBuilder: () async {
                    final Directory extDir = await getTemporaryDirectory();
                    final testDir = await Directory('${extDir.path}/test')
                        .create(recursive: true);
                    final String filePath =
                        '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                    return filePath;
                  },
                ),
              ),
        // CameraAwesomeBuilder.awesome(
        //   saveConfig: SaveConfig.photoAndVideo(
        //     photoPathBuilder: () async {
        //       final Directory extDir = await getTemporaryDirectory();
        //       final testDir = await Directory('${extDir.path}/test')
        //           .create(recursive: true);
        //       final String filePath =
        //           '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        //       return filePath;
        //     },
        //     videoPathBuilder: () {
        //       return Future.value("");
        //     },
        //     initialCaptureMode: CaptureMode.photo,
        //   ),
        //   enablePhysicalButton: true,
        //   mirrorFrontCamera: true,

        //   // filter: AwesomeFilter.AddictiveRed,
        //   // flashMode: FlashMode.auto,
        //   aspectRatio: CameraAspectRatios.ratio_16_9,
        //   previewFit: CameraPreviewFit.fitWidth,

        //   onMediaTap: (mediaCapture) async {
        //     // OpenFile.open(mediaCapture.filePath);
        //     var (imageResult, detectionResult, durationResult) =
        //         objectDetection!.analyseImage(mediaCapture.filePath);

        //     image = imageResult;
        //     detectionData = DetectionData(
        //       results: detectionResult,
        //       duration: durationResult.toString(),
        //       image: base64Encode(imageResult), // Convert image to base64
        //     );
        //     setState(() {});
        //   },
        // ),
      ),
    );
  }

  Widget _statsWidget() {
    return (image != null && detectionData != null)
        ? Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jumlah Deteksi (${detectionData!.results.length})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: detectionData!.results.length,
                      itemBuilder: (context, index) {
                        final e = detectionData!.results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 25.0,
                            animationDuration: 1000,
                            percent: e.score,
                            leading: Text(e.object, textAlign: TextAlign.start),
                            center: Text(
                                "${(e.score * 100).toStringAsFixed(1)}%",
                                textAlign: TextAlign.center),
                            barRadius: const Radius.circular(10),
                            progressColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Durasi: ${detectionData!.duration} ms",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: _saveData,
                    text: "Simpan Data",
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> _saveData() async {
    if (detectionData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonData = jsonEncode(detectionData!.toJson());
      List<String>? existingResults =
          prefs.getStringList('detectionResults_v2') ?? [];
      existingResults.add(jsonData);
      await prefs
          .setStringList('detectionResults_v2', existingResults)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil disimpan!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      });

      // Show a simple snackbar notification
    }
  }
}

class TakePhotoUI extends StatelessWidget {
  final PhotoCameraState state;

  const TakePhotoUI(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const Expanded(child: SizedBox()),
          Container(
            margin: const EdgeInsets.only(bottom: 32.0),
            child: MaterialButton(
              onPressed: () {
                state.takePhoto().then((value) {
                  print(value);
                });
              },
              color: Colors.blue,
              textColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.camera_alt,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AwesomeCameraGalleryButton extends StatelessWidget {
  final CameraState state;
  final AwesomeTheme? theme;
  final Widget Function() iconBuilder;
  final void Function(CameraState) onSwitchTap;

  AwesomeCameraGalleryButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function()? iconBuilder,
    void Function(CameraState)? onSwitchTap,
    double scale = 1.3,
  })  : iconBuilder = iconBuilder ??
            (() {
              return AwesomeCircleWidget.icon(
                theme: theme,
                icon: Icons.image,
                scale: scale,
              );
            }),
        onSwitchTap = onSwitchTap ?? ((state) => state.switchCameraSensor());

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? AwesomeThemeProvider.of(context).theme;

    return AwesomeOrientedWidget(
      rotateWithDevice: theme.buttonTheme.rotateWithCamera,
      child: theme.buttonTheme.buttonBuilder(
        iconBuilder(),
        () => onSwitchTap(state),
      ),
    );
  }
}
