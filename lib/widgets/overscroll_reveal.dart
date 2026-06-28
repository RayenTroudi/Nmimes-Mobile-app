import 'package:flutter/material.dart';

class OverscrollReveal extends StatefulWidget {
  final Widget child;
  final bool childIsScrollable;

  const OverscrollReveal({
    super.key,
    required this.child,
    this.childIsScrollable = false,
  });

  @override
  State<OverscrollReveal> createState() => _OverscrollRevealState();
}

class _OverscrollRevealState extends State<OverscrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _scale;

  double _pullProgress = 0.0;
  bool _peeking = false;

  static const double _maxPull = 80.0;
  static const double _imageSize = 72.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Called by both scroll-based and gesture-based paths ───────────────────

  void _onPull(double amount) {
    if (_peeking) return;
    final pull = (amount / _maxPull).clamp(0.0, 1.0);
    setState(() => _pullProgress = pull);
    if (pull >= 1.0) _triggerPeek();
  }

  void _onRelease() {
    if (!_peeking && _pullProgress > 0) {
      setState(() => _pullProgress = 0);
    }
  }

  void _triggerPeek() {
    if (_peeking) return;
    setState(() {
      _peeking = true;
      _pullProgress = 0;
    });
    _ctrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _ctrl.reverse().then((_) {
          if (mounted) setState(() => _peeking = false);
        });
      });
    });
  }

  // ── Scroll notification handler (for screens that already scroll) ─────────

  bool _handleNotification(ScrollNotification n) {
    if (n is OverscrollNotification && n.overscroll < 0) {
      _onPull(-n.overscroll);
    } else if (n is ScrollEndNotification) {
      _onRelease();
    }
    return false;
  }

  // ── Gesture handler (for non-scrollable screens) ──────────────────────────

  double _dragAccum = 0.0;

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy > 0) {
      _dragAccum += d.delta.dy;
      _onPull(_dragAccum);
    } else {
      _dragAccum = 0;
      _onRelease();
    }
  }

  void _onDragEnd(DragEndDetails _) {
    _dragAccum = 0;
    _onRelease();
  }

  // ── Peek overlay ──────────────────────────────────────────────────────────

  Widget? _buildPeek() {
    if (_peeking) {
      return ScaleTransition(
        scale: _scale,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.5),
            end: Offset.zero,
          ).animate(_slide),
          child: const _PeekImage(),
        ),
      );
    }
    if (_pullProgress > 0) {
      return Opacity(
        opacity: _pullProgress.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -_imageSize * (1 - _pullProgress)),
          child: const _PeekImage(),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final peek = _buildPeek();

    Widget body;

    if (widget.childIsScrollable) {
      // Screens that already scroll — just listen for overscroll notifications
      body = NotificationListener<ScrollNotification>(
        onNotification: _handleNotification,
        child: widget.child,
      );
    } else {
      // Non-scrollable screens — detect downward drag with a GestureDetector
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        onVerticalDragCancel: () {
          _dragAccum = 0;
          _onRelease();
        },
        child: widget.child,
      );
    }

    return Stack(
      children: [
        body,
        if (peek != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: peek,
              ),
            ),
          ),
      ],
    );
  }
}

class _PeekImage extends StatelessWidget {
  const _PeekImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/nmimes_surprised2.png',
      width: 72,
      height: 72,
      fit: BoxFit.contain,
    );
  }
}
