import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/music_assistant_provider.dart';
import '../screens/album_details_screen.dart';
import '../constants/hero_tags.dart';

class AlbumRow extends StatefulWidget {
  final String title;
  final Future<List<Album>> Function() loadAlbums;

  const AlbumRow({
    super.key,
    required this.title,
    required this.loadAlbums,
  });

  @override
  State<AlbumRow> createState() => _AlbumRowState();
}

class _AlbumRowState extends State<AlbumRow> {
  late Future<List<Album>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = widget.loadAlbums();
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
          height: 200,
          child: FutureBuilder<List<Album>>(
            future: _albumsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final albums = snapshot.data ?? [];
              if (albums.isEmpty) {
                return const Center(
                  child: Text('No albums found'),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                physics: const BouncingScrollPhysics(),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return RepaintBoundary(
                    child: _AlbumCard(album: album),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final maProvider = context.read<MusicAssistantProvider>();
    final imageUrl = maProvider.api?.getImageUrl(album, size: 200);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailsScreen(
              album: album,
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album artwork with Hero animation
            Hero(
              tag: HeroTags.albumCover + (album.uri ?? album.itemId),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        cacheHeight: 300,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[800],
                            child: const Icon(Icons.album, size: 64),
                          );
                        },
                      )
                    : Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[800],
                        child: const Icon(Icons.album, size: 64),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Album title with Hero animation
            Hero(
              tag: HeroTags.albumTitle + (album.uri ?? album.itemId),
              child: Material(
                color: Colors.transparent,
                child: Text(
                  album.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            // Artist name with Hero animation
            if (album.artists != null && album.artists!.isNotEmpty)
              Hero(
                tag: HeroTags.artistName + (album.uri ?? album.itemId),
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    album.artists!.first.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
