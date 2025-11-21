import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';

class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicPlayerProvider>();
    final track = provider.currentTrack;

    if (track == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'No track selected',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album art placeholder
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            size: 120,
            color: Colors.white54,
          ),
        ),

        const SizedBox(height: 32),

        // Track title
        Text(
          track.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Artist name
        Text(
          track.artist,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (track.album != null) ...[
          const SizedBox(height: 4),
          Text(
            track.album!,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
