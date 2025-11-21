import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebcamCaptureWeb extends StatefulWidget {
  const WebcamCaptureWeb({super.key});

  @override
  State<WebcamCaptureWeb> createState() => _WebcamCaptureWebState();
}

class _WebcamCaptureWebState extends State<WebcamCaptureWeb> {
  CameraController? _controller;
  Uint8List? _imageBytes;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("ERROR AL INICIAR CÁMARA: $e");
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final file = await _controller!.takePicture();
    final bytes = await file.readAsBytes();

    setState(() => _imageBytes = bytes);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCaptured = _imageBytes != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        title: const Text(
          "Validar Reto",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // CAMERA BOX
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  width: 5,
                  color: isCaptured ? Colors.green.shade600 : Colors.green.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: !_isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : isCaptured
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : Stack(
                          children: [
                            Positioned.fill(child: CameraPreview(_controller!)),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.15),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),

            const SizedBox(height: 28),

            // Status text
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1,
              child: Text(
                isCaptured
                    ? "Foto capturada correctamente 📸"
                    : "Asegúrate de enfocar bien el objeto 🌿",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isCaptured ? Colors.green.shade800 : Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BUTTONS
            if (!isCaptured)
              _beautifulCaptureButton(onTap: _takePicture)
            else
              Column(
                children: [
                  _beautifulValidateButton(
                    onTap: () => Navigator.pop(context, true),
                  ),
                  const SizedBox(height: 14),
                  _beautifulRetryButton(
                    onTap: () => setState(() => _imageBytes = null),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BUTTON: TAKE PICTURE (PREMIUM)
  // ---------------------------------------------------------------------
  Widget _beautifulCaptureButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF43A047),
              Color(0xFF66BB6A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
            SizedBox(width: 10),
            Text(
              "Tomar foto",
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 0.7,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BUTTON: VALIDATE
  // ---------------------------------------------------------------------
  Widget _beautifulValidateButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.green.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 26),
            SizedBox(width: 10),
            Text(
              "Validar reto ✓",
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 0.7,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BUTTON: RETRY
  // ---------------------------------------------------------------------
  Widget _beautifulRetryButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.refresh_rounded, color: Color(0xFF2E7D32), size: 24),
            SizedBox(width: 10),
            Text(
              "Reintentar",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
