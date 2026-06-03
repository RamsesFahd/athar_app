import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageAssetImage extends StatefulWidget {
  final String storagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;

  const StorageAssetImage({
    super.key,
    required this.storagePath,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
  });

  static final Map<String, Future<String>> _urlCache = {};

  static Future<String> _resolveUrl(String path) {
    return _urlCache.putIfAbsent(
      path,
      () => FirebaseStorage.instance.ref(path).getDownloadURL(),
    );
  }

  /// Pre-fetches Firebase Storage download URLs and warms Flutter's image cache
  /// for [paths]. Call during startup so these images render instantly on first
  /// display instead of showing a placeholder while the URL resolves.
  static Future<void> precacheAll(
      BuildContext context, List<String> paths) async {
    await Future.wait(
      paths.map((path) async {
        try {
          final url = await _resolveUrl(path);
          if (context.mounted) {
            await precacheImage(CachedNetworkImageProvider(url), context);
          }
        } catch (_) {}
      }),
    );
  }

  @override
  State<StorageAssetImage> createState() => _StorageAssetImageState();
}

class _StorageAssetImageState extends State<StorageAssetImage> {
  late Future<String> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = StorageAssetImage._resolveUrl(widget.storagePath);
  }

  @override
  void didUpdateWidget(covariant StorageAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storagePath != widget.storagePath) {
      _urlFuture = StorageAssetImage._resolveUrl(widget.storagePath);
    }
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _urlFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildPlaceholder();
        }

        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          placeholder: (_, __) => _buildPlaceholder(),
          errorWidget: (_, __, ___) => _buildPlaceholder(),
        );
      },
    );
  }
}
