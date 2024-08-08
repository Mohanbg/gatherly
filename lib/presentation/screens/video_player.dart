import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeVideoView extends StatefulWidget {
  final String videoPath;

  NativeVideoView({required this.videoPath});

  @override
  _NativeVideoViewState createState() => _NativeVideoViewState();
}

class _NativeVideoViewState extends State<NativeVideoView> {
  late MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AndroidView(
            viewType: 'native_video_view',
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: <String, dynamic>{
              'videoPath': widget.videoPath,
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _togglePlayPause,
            child: Text('Toggle Play/Pause'),
          ),
        ),
      ],
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('native_video_view_$id');
  }

  void _togglePlayPause() {
    _channel.invokeMethod('togglePlayPause');
  }
}
