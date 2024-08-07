import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class Costom_Player extends StatefulWidget {
  /// Path from where to play recorded audio
  final String source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  const Costom_Player({
    super.key,
    required this.source,
    required this.onDelete,
  });

  @override
  State<Costom_Player> createState() => _Costom_PlayerState();
}

class _Costom_PlayerState extends State<Costom_Player> {
  static const double _controlSize = 30;
  static const double _deleteBtnSize = 24;

  final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.onPlayerComplete.listen((state) async {
          await stop();
        });
    _positionChangedSubscription = _audioPlayer.onPositionChanged.listen(
          (position) => setState(() {
        _position = position;
      }),
    );
    _durationChangedSubscription = _audioPlayer.onDurationChanged.listen(
          (duration) => setState(() {
        _duration = duration;
      }),
    );

    _audioPlayer.setSource(_source);

    super.initState();
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildControl(),
                _buildSlider(constraints.maxWidth),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.red, size: _deleteBtnSize),
                  onPressed: () {
                    if (_audioPlayer.state == ap.PlayerState.playing) {
                      stop().then((value) => widget.onDelete());
                    } else {
                      widget.onDelete();
                    }
                  },
                ),
              ],
            ),
            Text('${_duration ?? 0.0}'),
          ],
        );
      },
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.state == ap.PlayerState.playing) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child:
          SizedBox(width: _controlSize, height: _controlSize, child: icon),
          onTap: () {
            if (_audioPlayer.state == ap.PlayerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(double widgetWidth) {
    bool canSetValue = false;
    final duration = _duration;
    final position = _position;

    if (duration != null && position != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    double width = widgetWidth - _controlSize - _deleteBtnSize;
    width -= _deleteBtnSize;

    return SizedBox(
      width: 200,
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).colorScheme.secondary,
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null && position != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() => _audioPlayer.play(_source);

  Future<void> pause() async {
    await _audioPlayer.pause();
    setState(() {});
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    setState(() {});
  }

  Source get _source =>
      kIsWeb ? ap.UrlSource(widget.source) : ap.DeviceFileSource(widget.source);
}


class Costom_PlayerForplayonly extends StatefulWidget {
  final String source;

  const Costom_PlayerForplayonly({
    super.key,
    required this.source,
  });

  @override
  State<Costom_PlayerForplayonly> createState() => _Costom_PlayerForplayonlyState();
}

class _Costom_PlayerForplayonlyState extends State<Costom_PlayerForplayonly> {
  static const double _controlSize = 30;
  final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.onPlayerComplete.listen((_) async {
          await stop();
        });
    _positionChangedSubscription = _audioPlayer.onPositionChanged.listen(
          (position) => setState(() {
        _position = position;
      }),
    );
    _durationChangedSubscription = _audioPlayer.onDurationChanged.listen(
          (duration) => setState(() {
        _duration = duration;
      }),
    );

    _audioPlayer.setSource(_source).catchError((error) {
      print('Error setting source: $error');
    });

    super.initState();
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _controlSize,
        height: _controlSize,
        child: _buildControl(),
      ),
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.state == ap.PlayerState.playing) {
      icon = const Icon(Icons.pause, color: Colors.red, size: _controlSize * 0.6);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: _controlSize * 0.6);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: Center(
            child: SizedBox(width: _controlSize * 0.8, height: _controlSize * 0.8, child: icon),
          ),
          onTap: () {
            if (_audioPlayer.state == ap.PlayerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play(_source).catchError((error) {
      print('Error playing audio: $error');
    });
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    setState(() {});
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    setState(() {});
  }

  Source get _source =>
      kIsWeb ? ap.UrlSource(widget.source) : ap.DeviceFileSource(widget.source);
}
