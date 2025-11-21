import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/player_controls.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicPlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Music Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaylistScreen(),
                ),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Now playing card
              const NowPlayingCard(),

              const Spacer(),

              // Progress bar
              const ProgressBar(),

              const SizedBox(height: 24),

              // Player controls
              const PlayerControls(),

              const SizedBox(height: 24),

              // Volume control
              StreamBuilder<double>(
                stream: provider.volumeStream,
                initialData: 1.0,
                builder: (context, snapshot) {
                  final volume = snapshot.data ?? 1.0;

                  return Row(
                    children: [
                      const Icon(
                        Icons.volume_down_rounded,
                        color: Colors.white70,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: volume,
                            onChanged: provider.setVolume,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white70,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
