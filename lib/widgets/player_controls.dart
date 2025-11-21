import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicPlayerProvider>();

    return StreamBuilder(
      stream: provider.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;
        final processingState = playerState?.processingState;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded),
              iconSize: 48,
              onPressed: provider.currentIndex > 0 ? provider.previous : null,
              color: Colors.white,
            ),

            const SizedBox(width: 16),

            // Play/Pause button
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF1a1a1a),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      iconSize: 36,
                      onPressed: provider.togglePlayPause,
                      color: const Color(0xFF1a1a1a),
                    ),
            ),

            const SizedBox(width: 16),

            // Next button
            IconButton(
              icon: const Icon(Icons.skip_next_rounded),
              iconSize: 48,
              onPressed: provider.currentIndex < provider.playlist.length - 1
                  ? provider.next
                  : null,
              color: Colors.white,
            ),
          ],
        );
      },
    );
  }
}
