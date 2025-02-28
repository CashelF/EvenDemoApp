import 'dart:async';
import 'dart:typed_data';
import 'package:demo_ai_even/controllers/bmp_update_manager.dart';
import 'package:demo_ai_even/utils/utils.dart';

class VideoPlayerService {
  bool isPlaying = false;
  Timer? _timer;
  int currentFrame = 0;
  final int totalFrames; // total number of frames in your video
  final String frameFolder; // folder in assets, e.g. "assets/video_frames"
  final int frameRate; // frames per second

  VideoPlayerService({
    required this.totalFrames,
    required this.frameFolder,
    this.frameRate = 1,
  });

  Future<void> startVideo() async {
    if (isPlaying) return;
    isPlaying = true;
    currentFrame = 0;
    int frameIntervalMs = (5000 / frameRate).round();

    _timer =
        Timer.periodic(Duration(milliseconds: frameIntervalMs), (timer) async {
      if (!isPlaying) {
        timer.cancel();
        return;
      }
      // Build the path. Assumes frames are named like "frame_0000.bmp", "frame_0001.bmp", etc.
      String frameNumber = currentFrame.toString().padLeft(4, '0');
      String framePath = '$frameFolder/frame_$frameNumber.bmp';

      // Load BMP data from assets.
      Uint8List bmpData = await Utils.loadBmpImage(framePath);
      if (bmpData.isEmpty) {
        print("Frame $framePath not found or empty; restarting video.");
        currentFrame = 0;
        return;
      }
      // Send the BMP to both glasses.
      bool leftSuccess =
          await BmpUpdateManager().updateBmp("L", bmpData, seq: 0);
      bool rightSuccess =
          await BmpUpdateManager().updateBmp("R", bmpData, seq: 0);
      if (!leftSuccess || !rightSuccess) {
        print("Error sending frame $currentFrame");
      }
      currentFrame++;
      if (currentFrame >= totalFrames) {
        // Loop the video. If you don’t want looping, call stopVideo() here.
        currentFrame = 0;
      }
    });
  }

  void stopVideo() {
    isPlaying = false;
    _timer?.cancel();
    _timer = null;
  }
}
