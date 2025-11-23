import 'dart:typed_data';
import 'package:camera/camera.dart';
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
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
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
        _imageBytes = null;
      });
    } catch (e) {
      debugPrint("ERROR AL INICIAR CÁMARA: $e");
    }
  }

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
      backgroundColor: const Color(0xFFF3F5ED),

      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 26),

            // -------- TITULO / GUIA --------
            Text(
              "Validación del reto",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Captura el objeto solicitado para confirmar tu reto",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 26),

            // -------- CAMERA BOX --------
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                border: Border.all(
                  width: 4,
                  color: isCaptured
                      ? Colors.green.shade600
                      : const Color(0xFFB7D6B1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
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
                            // sombreado sutil
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.12),
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

            const SizedBox(height: 24),

            // -------- TEXTO DE ESTADO --------
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1,
              child: Text(
                isCaptured
                    ? "Foto capturada correctamente 🌿"
                    : "Asegúrate de enfocar el objeto solicitado 📸",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCaptured ? Colors.green.shade700 : Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // -------- BOTONES --------
            if (!isCaptured)
              Column(
                children: [
                  _buttonPrimary("Tomar foto", Icons.camera_alt_rounded, _takePicture),
                  const SizedBox(height: 12),
                  _buttonSecondary("Cambiar cámara", Icons.cameraswitch, _switchCamera),
                ],
              )
            else
              Column(
                children: [
                  _buttonPrimary(
                      "Validar reto", Icons.check_circle_rounded, () {
                    Navigator.pop(context, _imageBytes);
                  }),
                  const SizedBox(height: 12),
                  _buttonSecondary("Reintentar", Icons.refresh, () {
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color(0xFF2E7D32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
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
