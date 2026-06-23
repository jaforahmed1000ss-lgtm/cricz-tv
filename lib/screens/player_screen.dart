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
  String _errorMsg = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 64 * 1024 * 1024,
        logLevel: MPVLogLevel.warn,
      ),
    );
    _controller = VideoController(_player);

    _player.stream.buffering.listen((buffering) {
      if (!mounted) return;
      if (buffering && _player.state.position == Duration.zero) {
        setState(() => _loading = true);
      } else if (!buffering && _player.state.playing) {
        setState(() => _loading = false);
      }
    });

    _player.stream.playing.listen((playing) {
      if (!mounted) return;
      if (playing) setState(() { _loading = false; _error = false; });
    });

    _player.stream.error.listen((err) {
      if (!mounted || err.isEmpty) return;
      setState(() { _loading = false; _error = true; _errorMsg = err; });
      if (_retryCount < _maxRetries) _scheduleRetry();
    });

    _loadStream();
  }

  void _scheduleRetry() {
    final delay = Duration(seconds: 2 * (_retryCount + 1));
    Future.delayed(delay, () {
      if (mounted && _error) {
        _retryCount++;
        _loadStream();
      }
    });
  }

  Future<void> _loadStream() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = false; });
    try {
      await _player.stop();
      await _player.setProperty('cache', 'yes');
      await _player.setProperty('cache-secs', '30');
      await _player.setProperty('demuxer-max-bytes', '128MiB');
      await _player.setProperty('demuxer-readahead-secs', '20');
      await _player.setProperty('stream-buffer-size', '64MiB');
      await _player.setProperty('hls-bitrate', 'max');
      await _player.open(
        Media(widget.channel.streamUrl, httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 Chrome/114.0 Mobile Safari/537.36',
          'Referer': 'https://cricztv.com/',
          'Origin': 'https://cricztv.com',
          'Accept': '*/*',
        }),
      );
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = true; _errorMsg = e.toString(); });
    }
  }

  void _manualRetry() {
    _retryCount = 0;
    _loadStream();
  }

  void _setFullscreen(bool full) {
    setState(() => _isFullscreen = full);
    if (full) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
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
        body: _buildPlayerBox(fullscreen: true),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.channel.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis),
          Text(widget.channel.category,
              style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 11)),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, color: Colors.white, size: 7),
              SizedBox(width: 5),
              Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ]),
          ),
        ],
      ),
      body: Column(children: [
        AspectRatio(aspectRatio: 16 / 9, child: _buildPlayerBox()),
        Expanded(child: _buildInfoPanel()),
      ]),
    );
  }

  Widget _buildPlayerBox({bool fullscreen = false}) {
    return Stack(children: [
      Video(
        controller: _controller,
        controls: (state) => _CricZControls(
          state: state,
          channel: widget.channel,
          isFullscreen: fullscreen,
          onFullscreen: () => _setFullscreen(!fullscreen),
          onBack: fullscreen
              ? () => _setFullscreen(false)
              : () => Navigator.pop(context),
        ),
      ),
      if (_loading && !_error)
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                    color: Color(0xFF00D2FF), strokeWidth: 3),
              ),
              const SizedBox(height: 14),
              const Text('Loading stream...',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Connecting to server${_retryCount > 0 ? ' (retry $_retryCount/$_maxRetries)' : ''}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ),
      if (_error)
        Container(
          color: Colors.black,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4,
                    color: Color(0xFFFF4444), size: 60),
                const SizedBox(height: 16),
                const Text('Stream Unavailable',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('This stream may be offline or geo-restricted.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D2FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _manualRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← Back to channels', style: TextStyle(color: Colors.white54)),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }

  Widget _buildInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _chip(widget.channel.category, const Color(0xFF00D2FF)),
          const SizedBox(width: 8),
          _chip('● LIVE', Colors.red),
          const Spacer(),
          _chip('HD', const Color(0xFF4CAF50)),
        ]),
        const SizedBox(height: 14),
        Text(widget.channel.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('CricZ TV • Live Sports Streaming',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        const Spacer(),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white60,
                side: const BorderSide(color: Color(0xFF1E1E1E)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              label: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D2FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _setFullscreen(true),
              icon: const Icon(Icons.fullscreen_rounded, size: 20),
              label: const Text('Full Screen', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}

class _CricZControls extends StatefulWidget {
  final VideoState state;
  final Channel channel;
  final bool isFullscreen;
  final VoidCallback onFullscreen;
  final VoidCallback onBack;

  const _CricZControls({
    required this.state,
    required this.channel,
    required this.isFullscreen,
    required this.onFullscreen,
    required this.onBack,
  });

  @override
  State<_CricZControls> createState() => _CricZControlsState();
}

class _CricZControlsState extends State<_CricZControls> {
  bool _visible = true;

  void _toggle() => setState(() => _visible = !_visible);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xBB000000), Colors.transparent, Colors.transparent, Color(0xBB000000)],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 12, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: widget.onBack,
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.channel.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      const Row(children: [
                        Icon(Icons.circle, color: Colors.red, size: 7),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
            Center(
              child: StreamBuilder<bool>(
                stream: widget.state.widget.controller.player.stream.playing,
                builder: (_, snap) {
                  final playing = snap.data ?? false;
                  return GestureDetector(
                    onTap: () => widget.state.widget.controller.player.playOrPause(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 2),
                      ),
                      child: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(children: [
                  StreamBuilder<bool>(
                    stream: widget.state.widget.controller.player.stream.playing,
                    builder: (_, snap) {
                      final playing = snap.data ?? false;
                      return IconButton(
                        icon: Icon(
                          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white, size: 28,
                        ),
                        onPressed: () => widget.state.widget.controller.player.playOrPause(),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const Spacer(),
                  StreamBuilder<double>(
                    stream: widget.state.widget.controller.player.stream.volume,
                    builder: (_, snap) {
                      final muted = (snap.data ?? 100) == 0;
                      return IconButton(
                        icon: Icon(
                          muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: Colors.white, size: 22,
                        ),
                        onPressed: () {
                          final p = widget.state.widget.controller.player;
                          p.setVolume(p.state.volume == 0 ? 100 : 0);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                      color: Colors.white, size: 26,
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
