import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gatherly/core/constants/style.dart';
import 'package:gatherly/data/models/data_stall.dart';
import 'dart:io';

import 'package:gatherly/presentation/bloc/stall_page_bloc.dart';
import 'package:gatherly/presentation/screens/image_viewer.dart';
import 'package:gatherly/presentation/screens/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:video_thumbnail/video_thumbnail.dart';

class StallDetailScreen extends StatefulWidget {
  final String stallName;
  final String stallDate;
  final String companyName;
  final String files;
  final int stallIndex;
  final bool useFirestore;

  const StallDetailScreen({
    super.key,
    required this.stallIndex,
    required this.stallName,
    required this.stallDate,
    required this.companyName,
    required this.files,
    required this.useFirestore,
  });

  @override
  State<StallDetailScreen> createState() => _StallDetailScreenState();
}

class _StallDetailScreenState extends State<StallDetailScreen> {
  PageController? _pageController;
  StallBloc? stallBloc;
  int _currentPageIndex = 0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController?.addListener(() {
      setState(() {
        _currentPageIndex = _pageController?.page?.round() ?? 0;
      });
    });
    stallBloc = StallBloc('mediaBox_${widget.stallIndex}',
        useFirestore: widget.useFirestore);
  }

  void _addMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        setState(() {
          _isUploading = true;
        });

        bool isVideo = filePath.endsWith('.mp4') ||
            filePath.endsWith('.avi') ||
            filePath.endsWith('.mov');
        final newMedia = DataStall(path: filePath, isVideo: isVideo);

        await stallBloc?.addMedia(newMedia);

        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    stallBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<DataStall>>(
                  stream: stallBloc?.mediaPathsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      final mediaPaths = snapshot.data ?? [];
                      if (mediaPaths.isEmpty) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("No data, please upload"),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Back",
                                    style: CustomTextStyles.bodyText1,
                                  )),
                            ],
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: mediaPaths.length,
                            itemBuilder: (context, index) {
                              if (mediaPaths.isNotEmpty) {
                                final media = mediaPaths[index];
                                return GestureDetector(
                                  onTap: () {
                                    if (media.isVideo!) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => NativeVideoView(
                                            videoPath: media.path ?? ""),
                                      ));
                                    } else {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ImageViewer(
                                            imagePath: media.path ?? ""),
                                      ));
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      media.isVideo!
                                          ? VideoThumbnailShow(
                                              videoPath: media.path ?? "")
                                          : ImageView(
                                              imagePath: media.path ?? ""),
                                      if (media.isVideo!)
                                        const Positioned(
                                          bottom: 40,
                                          left: 20,
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.red,
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          if (snapshot.data != null &&
                              snapshot.data!.isNotEmpty)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  snapshot.data!.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.all(4.0),
                                    width: 12.0,
                                    height: 3.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: _currentPageIndex == index
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                Positioned(
                  top: 55,
                  left: 24,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      padding: const EdgeInsets.only(left: 5),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Positioned(
                    top: 55,
                    right: 30,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      child: IconButton(
                        icon: const Icon(
                          Icons.ios_share_outlined,
                          color: Colors.black,
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                    )),
                if (_isUploading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.stallName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  widget.companyName,
                  style: CustomTextStyles.bodyGreyText1,
                ),
                const SizedBox(
                  height: 4,
                ),
                StreamBuilder<List<DataStall>>(
                  stream: stallBloc?.mediaPathsStream,
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return Text(
                      '$count Files',
                      style: CustomTextStyles.bodyGreyText1,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _addMedia,
              child: DottedBorder(
                color: Colors.grey,
                dashPattern: const [6, 3],
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.attach_file),
                        SizedBox(height: 10),
                        Text('Attach file'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  final String imagePath;

  const ImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    bool isOnline =
        imagePath.startsWith('http') || imagePath.startsWith('https');

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: isOnline
          ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Center(
                  child: Text('Failed to load image'),
                );
              },
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Center(
                  child: Text('Failed to load image'),
                );
              },
            ),
    );
  }
}

class VideoThumbnailShow extends StatelessWidget {
  final String videoPath;

  const VideoThumbnailShow({super.key, required this.videoPath});

  Future<Uint8List?> _generateThumbnail() async {
    return await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 75,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load thumbnail'));
        } else {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
          );
        }
      },
    );
  }
}
