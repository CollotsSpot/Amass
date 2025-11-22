# Music Assistant Mobile - Architecture Documentation

## Overview

Music Assistant Mobile is a Flutter application that connects to a [Music Assistant](https://music-assistant.io/) server to browse and control music playback across various devices and players.

## Architecture Pattern

The app follows the **Provider pattern** for state management with a **layered architecture**:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (Screens, Widgets, UI Logic)     │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│         State Management            │
│    (Providers - Business Logic)     │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│         Service Layer               │
│  (API, Auth, Audio, Settings, etc)  │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│         Data Layer                  │
│      (Models, DTOs)                 │
└─────────────────────────────────────┘
```

## Key Components

### 1. Providers (`lib/providers/`)

**MusicAssistantProvider** - Central state manager
- Manages WebSocket connection to Music Assistant server
- Handles authentication and auto-login
- Maintains library state (artists, albums, tracks)
- Manages player selection and playback state
- Implements player list caching (5-minute cache)
- Polls selected player state every 2 seconds

**MusicPlayerProvider** - Local audio playback (deprecated)
- Legacy local playback using just_audio
- Being phased out in favor of server-side playback control

### 2. Services (`lib/services/`)

**MusicAssistantAPI** - WebSocket API client
- Connects to Music Assistant server via WebSocket
- Implements JSON-RPC message protocol
- Handles server info, events, and command responses
- Provides methods for:
  - Library browsing (artists, albums, tracks, playlists)
  - Search functionality
  - Player control and queue management
  - Built-in player registration
  - Stream URL generation

**AuthService** - Authentication management
- Handles Authelia authentication (separate auth domain)
- Stores and retrieves session cookies
- Auto-login with saved credentials

**SettingsService** - Persistent settings
- Uses `shared_preferences` for local storage
- Stores:
  - Server URL and WebSocket port
  - Username and password (encrypted)
  - Built-in player ID
  - Authentication token

**AudioPlayerService** - Local audio playback
- Wraps `just_audio` for audio playback
- Handles play, pause, stop, seek operations
- Currently used for built-in player mode

**BuiltinPlayerService** - Server push events
- Listens to built-in player events from server
- Handles QUEUE_ITEMS, PLAY_MEDIA, STOP, etc.
- Coordinates with AudioPlayerService

**DebugLogger** - Logging utility
- Prints timestamped debug logs
- Helps troubleshooting and development

### 3. Models (`lib/models/`)

**MediaItem** - Base class for media entities
- `Artist` - Artist metadata
- `Album` - Album metadata with artists
- `Track` - Track metadata with artists and album
- All include provider mappings and metadata

**Player** - Music Assistant player
- Player ID, name, state (idle/playing/paused)
- Availability and power status
- Derived `isPlaying` getter

**PlayerQueue** - Player queue state
- List of `QueueItem`
- Current index/item
- Player ID

**QueueItem** - Item in player queue
- Queue item ID
- Track metadata
- Stream details (sample rate, bit depth, content type)

**BuiltinPlayerEvent** - Server push events
- Event type (QUEUE_ITEMS, PLAY_MEDIA, etc.)
- Event data payload

### 4. Screens (`lib/screens/`)

**Navigation Flow:**
```
MainLayout (Bottom Navigation)
├── NewHomeScreen
│   ├── LibraryStats
│   ├── AlbumRow (Recent, Random, All)
│   └── SearchScreen (via app bar)
├── NewLibraryScreen
│   ├── LibraryArtistsScreen (with pull-to-refresh)
│   ├── LibraryAlbumsScreen (with pull-to-refresh)
│   └── LibraryTracksScreen
└── SettingsScreen
```

**Detail Screens:**
- `ArtistDetailsScreen` - Artist albums
- `AlbumDetailsScreen` - Album tracks with play button
- `PlayerScreen` - Full player view
- `QueueScreen` - Queue management (reorder, remove)
- `SearchScreen` - Global search (artists, albums, tracks)

### 5. Widgets (`lib/widgets/`)

**Reusable Components:**
- `MiniPlayer` - Bottom now playing bar
- `PlayerSelector` - Device/player picker
- `AlbumRow` - Horizontal scrolling album list
- `LibraryStats` - Library statistics card
- `PlayerControls` - Playback controls (deprecated)

## Data Flow

### Player Selection & Control

```
User selects player → PlayerSelector widget
                    ↓
        MusicAssistantProvider.selectPlayer()
                    ↓
        Starts player state polling (every 2s)
                    ↓
        Fetches queue via getQueue()
                    ↓
        Updates currentTrack
                    ↓
        MiniPlayer displays track info
```

### Music Playback

```
User plays album → AlbumDetailsScreen._playAlbum()
                ↓
        MusicAssistantProvider.playTracks()
                ↓
        API: player_queues/play_media
                ↓
        Server queues tracks on selected player
                ↓
        Player state polling updates UI
```

### Library Loading

```
App connects → MusicAssistantProvider._initialize()
             ↓
         connectToServer()
             ↓
         WebSocket connection established
             ↓
         loadLibrary() (auto-triggered)
             ↓
         Fetches artists, albums, tracks (limit: 100 each)
             ↓
         notifyListeners() → UI updates
```

## API Integration

### WebSocket Commands

The app uses Music Assistant's WebSocket JSON-RPC API:

**Library:**
- `music/artists/library_items` - Get artists
- `music/albums/library_items` - Get albums
- `music/tracks/library_items` - Get tracks
- `music/search` - Search all media types

**Playback Control:**
- `player_queues/play_media` - Queue and play tracks
- `player_command/play` - Resume playback
- `player_command/pause` - Pause playback
- `player_command/next` - Next track
- `player_command/previous` - Previous track

**Queue Management:**
- `player_queues/items` - Get queue items (returns List, not object)

**Players:**
- `players/all` - Get all available players

**Built-in Player:**
- `builtin_player/register` - Register device as player
- `builtin_player/update_state` - Update player state

### Event Subscriptions

The WebSocket connection receives real-time events:
- `player_updated` - Player state changed
- `queue_updated` - Queue modified
- `queue_items_updated` - Queue items changed
- `media_item_played` - Track started playing
- `builtin_player` - Built-in player event (QUEUE_ITEMS, PLAY_MEDIA, etc.)

## Performance Optimizations

### 1. Player List Caching
- Cache player list for 5 minutes
- Reduces API calls on player selector opens
- Force refresh available via `refreshPlayers()`

### 2. Debounced Search
- 500ms debounce on search input
- Prevents excessive API calls while typing

### 3. Pagination
- Library loads with limit (default: 100)
- Can be extended for infinite scroll

### 4. Image Loading
- NetworkImage with error handling
- Fallback to icon on load failure
- Size parameter for different image resolutions

## State Management Pattern

```dart
// Provider pattern example
class MusicAssistantProvider with ChangeNotifier {
  List<Album> _albums = [];

  List<Album> get albums => _albums;

  Future<void> loadAlbums() async {
    _albums = await _api.getAlbums();
    notifyListeners(); // Triggers UI rebuild
  }
}

// Widget consumption
class AlbumList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicAssistantProvider>();
    return ListView(
      children: provider.albums.map((album) => AlbumTile(album)).toList(),
    );
  }
}
```

## Authentication Flow

### Authelia Integration

Music Assistant Mobile supports Authelia authentication on separate domains:

```
1. User enters credentials in SettingsScreen
           ↓
2. AuthService.login(serverUrl, username, password)
           ↓
3. POST to auth.serverscloud.org
           ↓
4. Extract authelia_session cookie
           ↓
5. Store cookie in SettingsService
           ↓
6. Include cookie in WebSocket handshake
           ↓
7. WebSocket: headers['Cookie'] = 'authelia_session=...'
```

### Auto-Login

On app startup:
1. Check for saved credentials
2. If found, attempt silent login
3. On success, connect to Music Assistant server
4. On failure, user can re-enter credentials

## Error Handling

### API Errors
- Try-catch blocks around all API calls
- Errors logged via DebugLogger
- UI shows error states (empty states, snackbars)

### WebSocket Reconnection
- Auto-reconnect on disconnect (3-second delay)
- Connection state tracked via Stream
- UI reflects connection status

### Queue Parsing Errors
- Defensive parsing with try-catch per item
- Failed items skipped, parsing continues
- Debug logging for troubleshooting

## Testing Strategy

### Unit Tests (TODO)
- API service methods
- Model parsing (fromJson/toJson)
- State management logic

### Widget Tests (TODO)
- Screen rendering
- User interactions
- Navigation flows

### Integration Tests (TODO)
- End-to-end user flows
- WebSocket communication
- Authentication

## Future Enhancements

### Planned Features
1. **Playlists** - Browse and play playlists
2. **Favorites** - Mark/unmark favorites, filter by favorites
3. **Lyrics** - Display lyrics for current track
4. **Sleep Timer** - Auto-stop playback
5. **Crossfade** - Smooth transitions between tracks
6. **Equalizer** - Audio customization
7. **Offline Mode** - Cached playback
8. **Android Auto / CarPlay** - In-car integration

### Technical Improvements
1. **Retry Logic** - Exponential backoff for failed requests
2. **Better Error Messages** - User-friendly error descriptions
3. **Loading States** - Skeleton screens, shimmer effects
4. **Infinite Scroll** - Lazy load library items
5. **Image Caching** - Reduce network usage
6. **WebSocket Reconnection** - Smarter reconnection strategy

## Development Guidelines

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### File Organization
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management
├── screens/                  # Full-screen views
├── widgets/                  # Reusable components
└── services/                 # Business logic, API, utilities
```

### Adding New Features

1. **Define Model** (if needed) - Add to `lib/models/`
2. **Create API Method** - Add to `MusicAssistantAPI`
3. **Update Provider** - Add state and methods to relevant provider
4. **Build UI** - Create screen/widget in `lib/screens/` or `lib/widgets/`
5. **Wire Navigation** - Update navigation logic
6. **Test** - Write unit/widget tests
7. **Document** - Update this file and add code comments

### Debugging Tips

1. **Enable Debug Logging** - DebugLogger prints to console
2. **Check WebSocket Messages** - Logs show all WS traffic
3. **Inspect Provider State** - Use Flutter DevTools
4. **Network Debugging** - Check API responses
5. **Test Authentication** - Verify session cookies

## Dependencies

### Core
- `flutter` - UI framework
- `provider` - State management
- `web_socket_channel` - WebSocket client

### Audio
- `just_audio` - Audio playback
- `audio_service` - Background playback

### Networking
- `http` - HTTP requests
- `uuid` - Unique ID generation

### Storage
- `shared_preferences` - Local key-value storage

### UI
- `flutter_launcher_icons` - App icons

## Resources

- **Music Assistant**: https://music-assistant.io/
- **Music Assistant API Docs**: https://music-assistant.io/integration/websocket/
- **Flutter Docs**: https://docs.flutter.dev/
- **Provider Package**: https://pub.dev/packages/provider
- **just_audio Package**: https://pub.dev/packages/just_audio
