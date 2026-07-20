import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SnapQuickTipsCard extends StatelessWidget {
  const SnapQuickTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.snap_widgets_quickTips,
            style: AppTextStyles.font(context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          ...[
            l.snap_widgets_tip1,
            l.snap_widgets_tip2,
            l.snap_widgets_tip3,
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '✓ $tip',
                  style: AppTextStyles.font(context,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Static placeholder (shown while camera initialises) ─────────────────────

class SnapCameraViewfinder extends StatelessWidget {
  final String hint;
  const SnapCameraViewfinder({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          const Positioned(top: 24, left: 24,
              child: _Corner(flipH: false, flipV: false)),
          const Positioned(top: 24, right: 24,
              child: _Corner(flipH: true, flipV: false)),
          const Positioned(bottom: 24, left: 24,
              child: _Corner(flipH: false, flipV: true)),
          const Positioned(bottom: 24, right: 24,
              child: _Corner(flipH: true, flipV: true)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, size: 40,
                    color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  hint,
                  style: AppTextStyles.font(context,
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Live camera preview with capture, flip, flash, gallery ──────────────────

class SnapCameraPreview extends StatefulWidget {
  /// Called with the captured image file path. Navigate away from this screen.
  final void Function(String imagePath) onCapture;
  final String nextRoute;

  const SnapCameraPreview({
    super.key,
    required this.onCapture,
    required this.nextRoute,
  });

  @override
  State<SnapCameraPreview> createState() => _SnapCameraPreviewState();
}

class _SnapCameraPreviewState extends State<SnapCameraPreview>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _flashOn = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() => _errorMessage =
              'No cameras found.\nMake sure camera permission is granted, then tap to retry.');
        }
        return;
      }
      await _startCamera(_cameraIndex);
    } catch (e) {
      if (mounted) {
        final message = e is CameraException && e.code == 'CameraAccessDenied'
            ? 'Camera permission was denied.\nTap to try again.'
            : 'Camera error: $e';
        setState(() => _errorMessage = message);
      }
    }
  }

  Future<void> _startCamera(int index) async {
    final old = _controller;
    _controller = null;
    await old?.dispose();

    for (final preset in [ResolutionPreset.medium, ResolutionPreset.low]) {
      final controller = CameraController(
        _cameras[index],
        preset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller = controller;
      try {
        await controller.initialize();
        await controller.setFlashMode(
            _flashOn ? FlashMode.torch : FlashMode.off);
        if (mounted) setState(() {});
        return;
      } catch (_) {
        await controller.dispose();
        _controller = null;
      }
    }
    if (mounted) {
      setState(() => _errorMessage = 'Could not open camera. Please restart the app.');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    await _controller?.dispose();
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameraIndex);
  }

  Future<void> _toggleFlash() async {
    _flashOn = !_flashOn;
    await _controller?.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off);
    if (mounted) setState(() {});
  }

  Future<void> _capture() async {
    if (_isCapturing || _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final file = await _controller!.takePicture();
      widget.onCapture(file.path);
    } catch (_) {
      // ignore capture errors
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) widget.onCapture(picked.path);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(_cameraIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    final ready = ctrl != null && ctrl.value.isInitialized;

    return Column(
      children: [
        // ── Live preview area ──────────────────────────────────────
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (ready)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: ctrl.value.previewSize!.height,
                      height: ctrl.value.previewSize!.width,
                      child: CameraPreview(ctrl),
                    ),
                  )
                else
                  Container(
                    color: const Color(0xFF1E2A3A),
                    child: Center(
                      child: _errorMessage != null
                          ? GestureDetector(
                              onTap: _initCamera,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : const CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                // Corner brackets overlay
                const Positioned(top: 24, left: 24,
                    child: _Corner(flipH: false, flipV: false)),
                const Positioned(top: 24, right: 24,
                    child: _Corner(flipH: true, flipV: false)),
                const Positioned(bottom: 24, left: 24,
                    child: _Corner(flipH: false, flipV: true)),
                const Positioned(bottom: 24, right: 24,
                    child: _Corner(flipH: true, flipV: true)),
                // Flash toggle top-right
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: _flashOn
                            ? AppColors.primary
                            : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Controls row ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gallery
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.textPrimary, size: 24),
                ),
              ),
              // Shutter
              GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _isCapturing
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _isCapturing
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
              // Flip
              GestureDetector(
                onTap: _flipCamera,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(Icons.flip_camera_ios_outlined,
                      color: AppColors.textPrimary, size: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Corner bracket painter ───────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  final bool flipH, flipV;
  const _Corner({required this.flipH, required this.flipV});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipH ? -1 : 1,
      scaleY: flipV ? -1 : 1,
      child: SizedBox(
        width: 28,
        height: 28,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const r = 10.0;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(r, 0)
      ..arcToPoint(Offset(0, r), radius: const Radius.circular(r), clockwise: false)
      ..lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

// ─── Action button ────────────────────────────────────────────────────────────

class SnapActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  const SnapActionButton({
    super.key,
    required this.label,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: filled
              ? const Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2.5))
              : Border.all(color: AppColors.primary, width: 2),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20,
                color: filled ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
