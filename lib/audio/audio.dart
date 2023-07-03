import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  factory AudioManager() => _instance;

  AudioManager._();

  static final AudioManager _instance = AudioManager._();

  String? _currentBgm;

  static const _titlePath = 'Menu_-_Floating_Point.wav';
  static const _gamePath = 'Action_-_Midnight_Cruisers.wav';

  void stopBgm() {
    FlameAudio.bgm.stop();
    _currentBgm = null;
  }

  void playTitle() => _play(_titlePath);

  void playGame() => _play(_gamePath);

  void introSfx() {
    FlameAudio.play('LightRunners.wav');
  }

  void _play(String path) {
    if (_currentBgm == path) {
      return;
    }
    FlameAudio.bgm.play(path);
    _currentBgm = path;
  }
}
