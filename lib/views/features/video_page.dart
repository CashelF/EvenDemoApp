import 'package:flutter/material.dart';
import 'package:demo_ai_even/services/video_player_service.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  // Adjust these based on your frames and assets location.
  final VideoPlayerService videoPlayer = VideoPlayerService(
    totalFrames: 365, // e.g., 365 frames in your video
    frameFolder: 'assets/output_bmps',
    frameRate: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video on Glasses')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Start Video'),
              onPressed: () {
                videoPlayer.startVideo();
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Stop Video'),
              onPressed: () {
                videoPlayer.stopVideo();
              },
            ),
          ],
        ),
      ),
    );
  }
}
