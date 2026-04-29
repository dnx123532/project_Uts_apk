// ─── TRAILER SCREEN ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrailerScreen extends StatefulWidget {
  final String trailerPath;
  const TrailerScreen({super.key, required this.trailerPath});

  @override
  State<TrailerScreen> createState() => TrailerScreenState();
}

class TrailerScreenState extends State<TrailerScreen> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;
  double? _dragValue; // null = tidak sedang drag

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.asset(widget.trailerPath);
      await _controller.initialize();
      if (!mounted) return;
      _controller.setLooping(false);
      _controller.setVolume(1.0);
      _controller.addListener(() {
        if (mounted && _dragValue == null) setState(() {});
      });
      setState(() => _ready = true);
      _controller.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Trailer'),
        ),
        body: const Center(
          child: Text(
            'Trailer tidak tersedia',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    if (!_ready) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Trailer'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final totalSec = _controller.value.duration.inSeconds.toDouble();
    final currentSec =
        _dragValue ?? _controller.value.position.inSeconds.toDouble();
    final safeMax = totalSec <= 0 ? 1.0 : totalSec;
    final safeVal = currentSec.clamp(0.0, safeMax);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Trailer', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // ── Video ──
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // ── Play/pause icon tengah ──
          if (!_controller.value.isPlaying)
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _controller.play()),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),

          // ── Progress bar bawah ──
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fmt(Duration(seconds: safeVal.toInt())),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _fmt(_controller.value.duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: safeVal,
                    min: 0,
                    max: safeMax,
                    activeColor: const Color(0xFF1A237E),
                    inactiveColor: Colors.white30,

                    // Mulai drag → pause & simpan posisi drag
                    onChangeStart: (_) {
                      _controller.pause();
                    },

                    // Geser → HANYA update _dragValue, JANGAN seekTo di sini
                    onChanged: (val) {
                      setState(() => _dragValue = val);
                    },

                    // Lepas → baru seekTo sekali lalu play
                    onChangeEnd: (val) async {
                      _dragValue = null;
                      await _controller.seekTo(Duration(seconds: val.toInt()));
                      await _controller.play();
                      setState(() {});
                    },
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
