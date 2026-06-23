import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/channel_model.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _loading = true;
  bool _error = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024,
        logLevel: MPVLogLevel.warn,
      ),
    );
    _controller = VideoController(_player);
    _player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _loading = buffering && _player.state.position == Duration.zero);
    });
    _player.stream.error.listen((err) {
      if (mounted && err.isNotEmpty) setState(() { _loading = false; _error = true; });
    });
    _player.stream.playing.listen((_) {
      if (mounted) setState(() { _loading = false; _error = false; });
    });
    _loadStream();
  }

  Future<void> _loadStream() async {
    setState(() { _loading = true; _error = false; });
    try {
      await _player.open(
        Media(widget.channel.streamUrl, httpHeaders: {
          'User-Agent': 'CricZ-TV/1.0 (Android)',
          'Referer': '',
        }),
      );
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildPlayer(fullscreen: true),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.channel.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
            child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(children: [
        AspectRatio(aspectRatio: 16 / 9, child: _buildPlayer()),
        Expanded(child: _buildInfo()),
      ]),
    );
  }

  Widget _buildPlayer({bool fullscreen = false}) {
    return Stack(children: [
      Video(
        controller: _controller,
        controls: (state) => _CustomControls(
          state: state,
          channel: widget.channel,
          onFullscreen: _toggleFullscreen,
          isFullscreen: fullscreen,
          onBack: fullscreen ? _toggleFullscreen : () => Navigator.pop(context),
        ),
      ),
      if (_loading)
        Container(
          color: Colors.black87,
          child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Color(0xFF00D2FF), strokeWidth: 3),
              SizedBox(height: 12),
              Text('Loading stream...', style: TextStyle(color: Colors.white60, fontSize: 14)),
              SizedBox(height: 6),
              Text('Connecting to server', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ),
      if (_error)
        Container(
          color: Colors.black,
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.signal_wifi_bad, color: Colors.redAccent, size: 56),
              const SizedBox(height: 14),
              const Text('Stream not available', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Server may be down. Try another channel.', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D2FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _loadStream,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ),
    ]);
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _badge(widget.channel.category, const Color(0xFF00D2FF)),
          const SizedBox(width: 8),
          _badge('● LIVE', Colors.red),
        ]),
        const SizedBox(height: 12),
        Text(widget.channel.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('CricZ TV • Live Streaming',
            style: TextStyle(color: Colors.white38, fontSize: 13)),
        const Spacer(),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white60,
                side: const BorderSide(color: Color(0xFF1A1A1A)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _toggleFullscreen,
              icon: const Icon(Icons.fullscreen, size: 18),
              label: const Text('Full Screen'),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      );
}

class _CustomControls extends StatefulWidget {
  final VideoState state;
  final Channel channel;
  final VoidCallback onFullscreen;
  final VoidCallback onBack;
  final bool isFullscreen;

  const _CustomControls({
    required this.state,
    required this.channel,
    required this.onFullscreen,
    required this.onBack,
    required this.isFullscreen,
  });

  @override
  State<_CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<_CustomControls> {
  bool _visible = true;

  void _toggleVisibility() => setState(() => _visible = !_visible);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleVisibility,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC000000), Colors.transparent, Colors.transparent, Color(0xCC000000)],
              stops: [0.0, 0.25, 0.75, 1.0],
            ),
          ),
          child: Stack(children: [
            // Top bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.channel.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                      const Row(children: [
                        Icon(Icons.circle, color: Colors.red, size: 8),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
            // Bottom controls
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  StreamBuilder<bool>(
                    stream: widget.state.widget.controller.player.stream.playing,
                    builder: (_, snap) {
                      final playing = snap.data ?? false;
                      return IconButton(
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
                        onPressed: () => widget.state.widget.controller.player.playOrPause(),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  StreamBuilder<double>(
                    stream: widget.state.widget.controller.player.stream.volume,
                    builder: (_, snap) {
                      final vol = snap.data ?? 100.0;
                      return IconButton(
                        icon: Icon(vol == 0 ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 24),
                        onPressed: () {
                          final p = widget.state.widget.controller.player;
                          p.setVolume(p.state.volume == 0 ? 100 : 0);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: widget.onFullscreen,
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
