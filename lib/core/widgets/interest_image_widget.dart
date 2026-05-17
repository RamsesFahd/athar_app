// ============================================================================
// Athar — Interest Image Widget
// ----------------------------------------------------------------------------
// A reusable widget that takes a Firebase Storage path (e.g.,
// 'taxonomy/heritage_sites.webp') and renders the image with:
//   - Disk + memory caching (so we hit Storage only once per device)
//   - Shimmer placeholder while loading
//   - Graceful fallback if the image fails to load
//   - URL resolution cached in-memory for the app session
//
// Usage:
//   InterestImage(
//     storagePath: 'taxonomy/heritage_sites.webp',
//     width: 120,
//     height: 120,
//   )
//
// Dependencies (add to pubspec.yaml if not already present):
//   firebase_storage: ^11.0.0
//   cached_network_image: ^3.3.0
// ============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class InterestImage extends StatefulWidget {
  final String storagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const InterestImage({
    super.key,
    required this.storagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<InterestImage> createState() => _InterestImageState();
}

class _InterestImageState extends State<InterestImage> {
  // Session-level cache: storagePath -> downloadUrl
  // This avoids re-resolving the URL every time the widget rebuilds.
  static final Map<String, String> _urlCache = {};

  late Future<String> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = _resolveUrl(widget.storagePath);
  }

  @override
  void didUpdateWidget(covariant InterestImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storagePath != widget.storagePath) {
      _urlFuture = _resolveUrl(widget.storagePath);
    }
  }

  Future<String> _resolveUrl(String path) async {
    if (_urlCache.containsKey(path)) {
      return _urlCache[path]!;
    }
    final url = await FirebaseStorage.instance.ref(path).getDownloadURL();
    _urlCache[path] = url;
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: radius,
      child: FutureBuilder<String>(
        future: _urlFuture,
        builder: (context, snapshot) {
          // Resolving the URL
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          }

          // Failed to resolve URL
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildFallback();
          }

          // URL resolved — load via cached_network_image
          return CachedNetworkImage(
            imageUrl: snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: (context, url) => _buildShimmer(),
            errorWidget: (context, url, error) => _buildFallback(),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }
}
