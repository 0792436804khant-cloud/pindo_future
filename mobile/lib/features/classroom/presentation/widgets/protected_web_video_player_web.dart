import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ProtectedWebVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final bool isPlaying;

  const ProtectedWebVideoPlayer({
    super.key,
    required this.streamUrl,
    this.isPlaying = true,
  });

  @override
  State<ProtectedWebVideoPlayer> createState() => _ProtectedWebVideoPlayerState();
}

class _ProtectedWebVideoPlayerState extends State<ProtectedWebVideoPlayer> {
  late final String _viewType;
  web.HTMLVideoElement? _videoElement;

  @override
  void initState() {
    super.initState();
    _viewType = 'pindo-video-${DateTime.now().microsecondsSinceEpoch}-${widget.streamUrl.hashCode}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.src = widget.streamUrl;
      video.controls = true;
      video.autoplay = widget.isPlaying;
      video.playsInline = true;
      video.setAttribute('controlsList', 'nodownload');
      video.setAttribute('disablePictureInPicture', 'true');
      video.style.width = '100%';
      video.style.height = '100%';
      video.style.backgroundColor = 'black';
      video.style.objectFit = 'contain';
      _videoElement = video;
      return video;
    });
  }

  @override
  void didUpdateWidget(covariant ProtectedWebVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_videoElement != null) {
      if (oldWidget.streamUrl != widget.streamUrl) {
        _videoElement!.src = widget.streamUrl;
      }
      if (oldWidget.isPlaying != widget.isPlaying) {
        if (widget.isPlaying) {
          _videoElement!.play();
        } else {
          _videoElement!.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _videoElement?.pause();
    _videoElement = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.streamUrl.startsWith('http://') && !widget.streamUrl.startsWith('https://')) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'رابط الفيديو غير متاح حالياً.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    return HtmlElementView(viewType: _viewType);
  }
}
