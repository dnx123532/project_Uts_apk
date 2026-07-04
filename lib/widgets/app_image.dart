import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget gambar universal — otomatis pakai network jika URL, asset jika path lokal.
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.borderRadius,
  });

  bool get _isNetwork => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final img = _isNetwork ? _networkImage() : _assetImage();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _networkImage() {
    return CachedNetworkImage(
      imageUrl: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: (ctx, url) => _shimmer(),
      errorWidget: (ctx, url, err) => errorWidget ?? _defaultError(),
    );
  }

  Widget _assetImage() {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultError(),
    );
  }

  Widget _shimmer() {
    return SizedBox(
      width: width,
      height: height,
      child: const _ShimmerBox(),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1A237E).withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, child) => Container(
        color: Color.lerp(
          Colors.grey.shade200,
          Colors.grey.shade300,
          _anim.value,
        ),
      ),
    );
  }
}
