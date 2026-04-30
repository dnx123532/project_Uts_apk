// SPLASH SCREEN
import 'package:flutter/material.dart';
import 'package:project_uts_apk/screens/homes/home_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // GANTI nama file jika berbeda
      _controller = VideoPlayerController.asset(
        'assets/videos/splash_screen.mp4',
      );
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _videoReady = true);
      _controller.setLooping(false);
      _controller.setVolume(1.0); // ganti 0.0 jika mau tanpa suara
      _controller.play();
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration &&
            _controller.value.duration > Duration.zero) {
          _goToHome();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _videoFailed = true);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) _goToHome();
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoFailed) return const _FallbackSplash();
    if (!_videoReady) return const _FallbackSplash(showLoading: true);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}

// FALLBACK SPLASH (jika video gagal atau masih loading)
class _FallbackSplash extends StatelessWidget {
  final bool showLoading;
  const _FallbackSplash({this.showLoading = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_filter_rounded,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tixio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tiket bioskop mudah & cepat',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (showLoading) ...[
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
