import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/music_assistant_provider.dart';
import '../screens/artist_details_screen.dart';

class ArtistRow extends StatefulWidget {
  final String title;
  final Future<List<Artist>> Function() loadArtists;

  const ArtistRow({
    super.key,
    required this.title,
    required this.loadArtists,
  });

  @override
  State<ArtistRow> createState() => _ArtistRowState();
}

class _ArtistRowState extends State<ArtistRow> {
  late Future<List<Artist>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _artistsFuture = widget.loadArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: FutureBuilder<List<Artist>>(
            future: _artistsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final artists = snapshot.data ?? [];
              if (artists.isEmpty) {
                return const Center(
                  child: Text('No artists found'),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return _ArtistCard(artist: artist);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final Artist artist;

  const _ArtistCard({required this.artist});

  @override
  Widget build(BuildContext context) {
    final maProvider = context.read<MusicAssistantProvider>();
    final imageUrl = maProvider.api?.getImageUrl(artist, size: 200);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailsScreen(
              artist: artist,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Artist image - circular
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person_rounded, size: 60, color: Colors.white54)
                  : null,
            ),
            const SizedBox(height: 12),
            // Artist name
            Text(
              artist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
