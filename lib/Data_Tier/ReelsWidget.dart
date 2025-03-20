import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelWidget extends StatefulWidget {
  final String videoUrl;
  final PageController pageController;
  final int currentIndex;
  final int totalVideos;

  const ReelWidget({
    Key? key,
    required this.videoUrl,
    required this.pageController,
    required this.currentIndex,
    required this.totalVideos,
  }) : super(key: key);

  @override
  _ReelWidgetState createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _isPlaying = true;
        });

        _controller.addListener(() {
          setState(() {});
          if (_controller.value.position >= _controller.value.duration) {
            _goToNextVideo();
          }
        });
      });
  }

  void _goToNextVideo() {
    if (widget.currentIndex < widget.totalVideos - 1) {
      widget.pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
      _showControls = true;
    });

    // Auto-hide controls after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video Player
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),

                // Play/Pause Icon Overlay
                if (_showControls)
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled_outlined
                          : Icons.play_circle,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                // Progress Bar
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _controller.value.isInitialized
                        ? _controller.value.position.inMilliseconds /
                            _controller.value.duration.inMilliseconds
                        : 0,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
  }
}
