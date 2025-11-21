import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_track.dart';
import '../services/audio_player_service.dart';

class MusicPlayerProvider with ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();

  AudioPlayerService get audioService => _audioService;

  List<AudioTrack> get playlist => _audioService.playlist;
  AudioTrack? get currentTrack => _audioService.currentTrack;
  int get currentIndex => _audioService.currentIndex;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<PlayerState> get playerStateStream => _audioService.playerStateStream;
  Stream<double> get volumeStream => _audioService.volumeStream;

  bool get isPlaying => _audioService.isPlaying;
  Duration get position => _audioService.position;
  Duration? get duration => _audioService.duration;

  Future<void> setPlaylist(List<AudioTrack> tracks, {int initialIndex = 0}) async {
    await _audioService.setPlaylist(tracks, initialIndex: initialIndex);
    notifyListeners();
  }

  Future<void> loadTrack(int index) async {
    await _audioService.loadTrack(index);
    notifyListeners();
  }

  Future<void> play() async {
    await _audioService.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
    notifyListeners();
  }

  Future<void> next() async {
    await _audioService.next();
    notifyListeners();
  }

  Future<void> previous() async {
    await _audioService.previous();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  Future<void> addToPlaylist(AudioTrack track) async {
    await _audioService.addToPlaylist(track);
    notifyListeners();
  }

  Future<void> removeFromPlaylist(int index) async {
    await _audioService.removeFromPlaylist(index);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
