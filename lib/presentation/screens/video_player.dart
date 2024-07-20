import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  final BehaviorSubject<Duration> _positionSubject =
      BehaviorSubject<Duration>();

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  void _initializeVideoController() {
    if (widget.videoPath.startsWith('http') ||
        widget.videoPath.startsWith('https')) {
      _controller = VideoPlayerController.network(widget.videoPath);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }

    _controller.initialize().then((_) {
      _controller.play();
      _controller.addListener(() {
        _positionSubject.add(_controller.value.position);
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _positionSubject.close();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
              top: 80,
              right: 32,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
             
              ),
          if (_controller.value.isInitialized)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.white,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<Duration>(
                        stream: _positionSubject.stream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration = _controller.value.duration;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                formatDuration(duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10,
                          color: Colors.white, size: 40),
                      onPressed: () {
                        _controller.seekTo(
                          _controller.value.position -
                              const Duration(seconds: 10),
                        );
                      },
                    ),
                    StreamBuilder<Duration>(
                      stream: _positionSubject.stream,
                      builder: (context, snapshot) {
                        return IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.red,
                            size: 85,
                          ),
                          onPressed: () {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10,
                          color: Colors.white, size: 40),
                      onPressed: () {
                        _controller.seekTo(
                          _controller.value.position +
                              const Duration(seconds: 10),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
