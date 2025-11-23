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
  List<CameraDescription> _cameras = [];
  Uint8List? _imageBytes;
  bool _isInitialized = false;
  int _currentCameraIndex = 0; // 🔥 aquí guardamos cuál cámara está activa

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        debugPrint("No se encontraron cámaras");
        return;
      }

      await _initCamera(_currentCameraIndex);
    } catch (e) {
      debugPrint("ERROR AL CARGAR CÁMARAS: $e");
    }
  }

  Future<void> _initCamera(int index) async {
    try {
      _controller = CameraController(
        _cameras[index],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _currentCameraIndex = index;
        _imageBytes = null; // Reiniciar foto si cambia de cámara
      });
    } catch (e) {
      debugPrint("ERROR AL INICIAR CÁMARA: $e");
    }
  }

  // 🔄 Cambiar cámara
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solo hay una cámara disponible.")),
      );
      return;
    }

    final nextIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initCamera(nextIndex);
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
            color: Colors.white,
          ),
        ),
        actions: [
          // 🔁 BOTÓN PARA CAMBIAR CÁMARA
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, size: 30),
            onPressed: _switchCamera,
          ),
          const SizedBox(width: 10),
        ],
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
                  color:
                      isCaptured ? Colors.green.shade600 : Colors.green.shade300,
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
                            Positioned.fill(
                                child: CameraPreview(_controller!)),
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

            if (!isCaptured)
              _buttonPrimary("Tomar foto", Icons.camera_alt_rounded, _takePicture)
            else
              Column(
                children: [
                  _buttonPrimary(
                      "Validar reto ✓", Icons.check_circle, () {
                        Navigator.pop(context, _imageBytes);
                      }),
                  const SizedBox(height: 14),
                  _buttonSecondary(
                      "Reintentar", Icons.refresh_rounded, () {
                        setState(() => _imageBytes = null);
                      }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- BUTTONS ----------------

  Widget _buttonPrimary(
      String text, IconData icon, VoidCallback onTap) {
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
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonSecondary(
      String text, IconData icon, VoidCallback onTap) {
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
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
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
