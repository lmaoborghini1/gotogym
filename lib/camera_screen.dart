import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();

    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    await _controller.initialize();

    setState(() {
      _isReady = true;
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _cameras.length;

    await _controller.dispose();

    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    await _controller.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Beweisfoto')),
      body: CameraPreview(_controller),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'switch',
            onPressed: _switchCamera,
            child: const Icon(Icons.cameraswitch),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'capture',
            onPressed: () async {
              final image = await _controller.takePicture();
              Navigator.pop(context, image.path);
            },
            child: const Icon(Icons.camera),
          ),
        ],
      ),
    );
  }
}
