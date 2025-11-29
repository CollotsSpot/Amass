import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_assistant_provider.dart';
import 'expandable_player.dart';

/// A global key to access the player state from anywhere in the app
final globalPlayerKey = GlobalKey<ExpandablePlayerState>();

/// Wrapper widget that provides a global player overlay above all navigation.
///
/// This ensures the mini player and expanded player are consistent across
/// all screens (home, library, album details, artist details, etc.) without
/// needing separate player instances in each screen.
class GlobalPlayerOverlay extends StatelessWidget {
  final Widget child;

  const GlobalPlayerOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main app content (Navigator, screens, etc.)
        child,
        // Global player overlay - sits above everything
        Consumer<MusicAssistantProvider>(
          builder: (context, maProvider, _) {
            // Only show player if connected and has a track
            if (!maProvider.isConnected ||
                maProvider.currentTrack == null ||
                maProvider.selectedPlayer == null) {
              return const SizedBox.shrink();
            }
            return ExpandablePlayer(key: globalPlayerKey);
          },
        ),
      ],
    );
  }

  /// Collapse the player if it's expanded
  static void collapsePlayer() {
    globalPlayerKey.currentState?.collapse();
  }

  /// Check if the player is currently expanded
  static bool get isPlayerExpanded =>
      globalPlayerKey.currentState?.isExpanded ?? false;
}
