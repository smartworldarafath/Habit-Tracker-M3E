import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashVideoScreen extends StatefulWidget {
  const SplashVideoScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _splashCompleted = false;
  Timer? _fallbackTimer;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    // Fallback timer: in case video fails or platform takes too long,
    // guarantee app enters after 3.5 seconds with butter-smooth transition.
    _fallbackTimer = Timer(const Duration(milliseconds: 3500), () {
      _completeSplash();
    });

    try {
      final controller = VideoPlayerController.asset(
        'assets/splash_animation.mp4',
      );
      _controller = controller;

      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();

      if (!mounted) return;

      setState(() {
        _isVideoInitialized = true;
      });

      controller.addListener(() {
        if (!mounted || _splashCompleted) return;
        final value = controller.value;
        if (value.isInitialized &&
            value.duration > Duration.zero &&
            (value.position >= value.duration ||
                (value.duration - value.position).inMilliseconds <= 100)) {
          _completeSplash();
        }
      });
    } catch (e) {
      debugPrint('Video splash could not initialize: $e');
      _completeSplash();
    }
  }

  void _completeSplash() {
    if (_splashCompleted) return;
    _splashCompleted = true;
    _fallbackTimer?.cancel();

    if (!mounted) return;

    _fadeController.forward().then((_) {
      _controller?.pause();
      _controller?.dispose();
      _controller = null;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _fadeController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeController.isCompleted) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // The underlying main app, prepared and revealed smoothly
        AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
            );
          },
        ),

        // Splash video layer that fades out when finished
        if (!_fadeController.isCompleted)
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              final splashOpacity = (1.0 - _fadeAnimation.value).clamp(0.0, 1.0);
              if (splashOpacity <= 0) return const SizedBox.shrink();

              return Opacity(
                opacity: splashOpacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _completeSplash,
                  child: ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: _isVideoInitialized && _controller != null
                          ? AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
