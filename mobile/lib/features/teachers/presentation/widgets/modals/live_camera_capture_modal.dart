import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class LiveCameraCaptureResult {
  final Uint8List bytes;
  final String name;

  const LiveCameraCaptureResult({
    required this.bytes,
    required this.name,
  });
}

/// Instagram-style live camera viewfinder modal that streams live webcam/phone camera
/// and snaps a real photo with a shutter button.
class LiveCameraCaptureModal extends StatefulWidget {
  const LiveCameraCaptureModal({super.key});

  static Future<LiveCameraCaptureResult?> show(BuildContext context) {
    return showGeneralDialog<LiveCameraCaptureResult>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => const LiveCameraCaptureModal(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

  @override
  State<LiveCameraCaptureModal> createState() => _LiveCameraCaptureModalState();
}

class _LiveCameraCaptureModalState extends State<LiveCameraCaptureModal> {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'لم يتم العثور على كاميرا متصلة بالجهاز.';
        });
        return;
      }

      _cameras = cameras;
      await _startCamera(_selectedCameraIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'تعذر تشغيل الكاميرا: $e\nيرجى التأكد من منح الإذن للمتصفح.';
      });
    }
  }

  Future<void> _startCamera(int index) async {
    final oldController = _controller;
    if (oldController != null) {
      await oldController.dispose();
    }

    final camera = _cameras[index];
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _selectedCameraIndex = index;
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'تعذر تجهيز معاينة الكاميرا: $e';
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2 || _isCapturing) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() {
      _isInitializing = true;
    });
    await _startCamera(nextIndex);
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await controller.takePicture();
      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).pop(LiveCameraCaptureResult(
        bytes: bytes,
        name: photo.name.isNotEmpty ? photo.name : 'camera_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر التقاط الصورة: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview or Loading / Error State
            _buildCameraBody(),

            // Top Control Bar (Close + Camera Flip)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(null),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),

                  // Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.cyanAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'الكاميرا الحية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flip Camera (if multiple cameras available)
                  if (_cameras.length > 1)
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 26),
                      onPressed: _toggleCamera,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Bottom Shutter Bar
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller != null && _controller!.value.isInitialized)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'اضغط على الزر لالتقاط الصورة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Text Button
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ),

                      // Instagram Style Shutter Button
                      GestureDetector(
                        onTap: (_controller != null && _controller!.value.isInitialized && !_isCapturing)
                            ? _takePicture
                            : null,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing ? Colors.redAccent : Colors.white,
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Placeholder for symmetric layout
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded, color: Colors.orangeAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initCameras,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitializing || _controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00E5FF)),
            SizedBox(height: 16),
            Text(
              'جارٍ تشغيل الكاميرا...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Live Camera Stream Preview
    return ClipRRect(
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }
}
