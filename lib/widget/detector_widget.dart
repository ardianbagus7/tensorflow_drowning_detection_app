import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_ssd_mobilenet_v2/screen/old_photo_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../model/recognition.dart';
import '../model/screen_params.dart';
import '../service/detector_service.dart';
import '../service/object_detection.dart';
import 'box_widget.dart';
import 'stats_widget.dart';

/// [DetectorWidget] sends each frame for inference
class DetectorWidget extends StatefulWidget {
  /// Constructor
  const DetectorWidget({super.key});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? _cameraController;

  // use only when initialized, so - not null
  get _controller => _cameraController;

  /// Object Detector is running on a background [Isolate]. This is nullable
  /// because acquiring a [Detector] is an asynchronous operation. This
  /// value is `null` until the detector is initialized.
  Detector? _detector;
  StreamSubscription? _subscription;

  /// Results to draw bounding boxes
  List<Recognition>? results;

  List<ObjectResult> detectionResults = [];

  /// Realtime stats
  Map<String, String>? stats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {
    // initialize preview and CameraImage stream
    _initializeCamera();
    // Spawn a new isolate
    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        _subscription = instance.resultsStream.stream.listen((values) {
          setState(() {
            results = values['recognitions'];
            stats = values['stats'];
            detectionResults = values['results'];
          });
        });
      });
    });
  }

  /// Initializes the camera by setting [_cameraController]
  void _initializeCamera() async {
    cameras = await availableCameras();
    // cameras[0] for back-camera
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.low,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});

        /// previewSize is size of each image frame captured by controller
        ///
        /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // var aspect = 1 / _controller.value.aspectRatio;
    var aspect = 9 / 16;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: aspect,
                child: CameraPreview(_controller),
              ),
              // Stats

              // Bounding boxes
              AspectRatio(
                aspectRatio: aspect,
                child: _boundingBoxes(),
              ),
            ],
          ),
        ),
        Expanded(child: _statsWidget()),
      ],
    );
  }

  Widget _statsWidget() => (stats != null)
      ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white.withAlpha(150),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Jumlah Deteksi (${detectionResults.length})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: detectionResults.length,
                      itemBuilder: (context, index) {
                        final e = detectionResults[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 25.0,
                            animationDuration: 0,
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
                  ...stats!.entries
                      .map<Widget>((e) => StatsWidget(e.key, e.value))
                      .toList()
                ],
              ),
            ),
          ),
        )
      : const SizedBox.shrink();

  /// Returns Stack of bounding boxes
  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
        children:
            results!.map<Widget>((box) => BoxWidget(result: box)).toList());
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
