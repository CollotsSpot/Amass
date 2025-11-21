import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/audio_track.dart';
import '../providers/music_player_provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  Future<void> _pickAudioFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final provider = context.read<MusicPlayerProvider>();
        final tracks = <AudioTrack>[];

        for (var i = 0; i < result.files.length; i++) {
          final file = result.files[i];
          if (file.path != null) {
            // Extract filename without extension
            final fileName = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');

            tracks.add(
              AudioTrack(
                id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
                title: fileName,
                artist: 'Unknown Artist',
                filePath: file.path!,
              ),
            );
          }
        }

        if (tracks.isNotEmpty) {
          await provider.setPlaylist(tracks);
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicPlayerProvider>();
    final playlist = provider.playlist;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text(
          'Playlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _pickAudioFiles(context),
            color: Colors.white,
          ),
        ],
      ),
      body: playlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.music_off_rounded,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tracks in playlist',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _pickAudioFiles(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Music'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1a1a1a),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: playlist.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final track = playlist[index];
                final isCurrentTrack = index == provider.currentIndex;

                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCurrentTrack
                          ? Colors.white
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCurrentTrack
                          ? Icons.play_arrow_rounded
                          : Icons.music_note_rounded,
                      color: isCurrentTrack
                          ? const Color(0xFF1a1a1a)
                          : Colors.white54,
                    ),
                  ),
                  title: Text(
                    track.title,
                    style: TextStyle(
                      color: isCurrentTrack ? Colors.white : Colors.white70,
                      fontWeight:
                          isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    track.artist,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                    ),
                    onPressed: () => provider.removeFromPlaylist(index),
                  ),
                  onTap: () async {
                    await provider.loadTrack(index);
                    await provider.play();
                  },
                );
              },
            ),
    );
  }
}
