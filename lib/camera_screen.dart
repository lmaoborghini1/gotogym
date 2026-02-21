import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();

    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _cameras!.length;

    await _controller.dispose();

    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameras == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          await _initializeControllerFuture;
                          final image =
                              await _controller.takePicture();
                          Navigator.pop(
                              context, image.path);
                        },
                        child: const Icon(
                          Icons.camera,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
