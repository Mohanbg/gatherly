import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class NativeVideoView extends StatefulWidget {
  final String videoPath;

const NativeVideoView({super.key,required this.videoPath});
  @override
  State<NativeVideoView> createState() => _NativeVideoViewState();
}

class _NativeVideoViewState extends State<NativeVideoView> {
  bool isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AndroidView(
            viewType: 'native_video_view',
            key: ValueKey(isPlaying),  // Force re-create when playing/pausing
            creationParams: <String, dynamic>{
              'videoPath': widget.videoPath,
              'play': isPlaying,
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _togglePlayPause,
            child: Text(isPlaying ? 'Pause' : 'Play'),
          ),
        ),
      ],
    );
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
