import 'package:camera/camera.dart';
import 'package:face_make_detector/main.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraImage? _cameraImage;
  CameraController? _cameraController;
  bool isOn = false;
  String result = "";

  initCamera() {
    _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    _cameraController!.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        _cameraController!.startImageStream((image) {
          if (!isOn) {
            isOn = true;
            _cameraImage = image;
            runModelonLoad();
          }
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  runModelonLoad() async {
    if (_cameraImage != null) {
      var recongnitions = await Tflite.runModelOnFrame(
          bytesList: _cameraImage!.planes.map((e) => e.bytes).toList(),
          imageHeight: _cameraImage!.height,
          imageMean: 127.5,
          imageStd: 127.5,
          imageWidth: _cameraImage!.width,
          rotation: 90,
          numResults: 1,
          asynch: true,
          threshold: 0.1);

      result = "";
      for (var element in recongnitions!) {
        result += element["label"] + "\n";
      }
    }
    setState(() {
      result;
    });
    isOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Positioned(
            child: (!_cameraController!.value.isInitialized)
                ? Container()
                : AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
          ),
          result != "" ? Text(result) : const Text("Not Active"),
        ],
      ),
    );
  }
}
