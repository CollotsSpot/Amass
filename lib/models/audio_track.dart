class AudioTrack {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;

  AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
  });

  factory AudioTrack.fromMap(Map<String, dynamic> map) {
    return AudioTrack(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String?,
      filePath: map['filePath'] as String,
      duration: map['duration'] != null
          ? Duration(milliseconds: map['duration'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
    };
  }

  @override
  String toString() => '$title - $artist';
}
