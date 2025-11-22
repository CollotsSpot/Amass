import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/player.dart';
import '../services/music_assistant_api.dart';
import '../services/settings_service.dart';
import '../services/builtin_player_service.dart';
import '../services/audio_player_service.dart';
import '../services/auth_service.dart';
import '../services/debug_logger.dart';

class MusicAssistantProvider with ChangeNotifier {
  MusicAssistantAPI? _api;
  BuiltinPlayerService? _builtinPlayer;
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  final AuthService _authService = AuthService();
  final DebugLogger _logger = DebugLogger();
  MAConnectionState _connectionState = MAConnectionState.disconnected;
  String? _serverUrl;

  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<Track> _tracks = [];
  bool _isLoading = false;
  String? _error;

  // Player selection
  Player? _selectedPlayer;
  List<Player> _availablePlayers = [];
  Track? _currentTrack; // Current track playing on selected player
  Timer? _playerStateTimer;

  MAConnectionState get connectionState => _connectionState;
  String? get serverUrl => _serverUrl;
  List<Artist> get artists => _artists;
  List<Album> get albums => _albums;
  List<Track> get tracks => _tracks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _connectionState == MAConnectionState.connected;

  // Player selection getters
  Player? get selectedPlayer => _selectedPlayer;
  List<Player> get availablePlayers => _availablePlayers;
  Track? get currentTrack => _currentTrack;

  MusicAssistantProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _serverUrl = await SettingsService.getServerUrl();
    if (_serverUrl != null && _serverUrl!.isNotEmpty) {
      // Auto-login if credentials are saved
      final username = await SettingsService.getUsername();
      final password = await SettingsService.getPassword();

      if (username != null && password != null && username.isNotEmpty && password.isNotEmpty) {
        _logger.log('🔐 Auto-login with saved credentials...');
        try {
          final token = await _authService.login(_serverUrl!, username, password);
          if (token != null) {
            _logger.log('✓ Auto-login successful');
          } else {
            _logger.log('⚠️ Auto-login failed - session cookie may be expired');
          }
        } catch (e) {
          _logger.log('⚠️ Auto-login error: $e');
        }
      }

      await connectToServer(_serverUrl!);
    }
  }

  Future<void> connectToServer(String serverUrl) async {
    try {
      _error = null;
      _serverUrl = serverUrl;
      await SettingsService.setServerUrl(serverUrl);

      // Disconnect existing connection
      await _api?.disconnect();

      _api = MusicAssistantAPI(serverUrl);

      // Listen to connection state changes
      _api!.connectionState.listen((state) {
        _connectionState = state;
        notifyListeners();

        if (state == MAConnectionState.connected) {
          // Start built-in player service
          _builtinPlayer = BuiltinPlayerService(_api!, _audioPlayer);
          _builtinPlayer!.start();

          // Load available players and auto-select
          _loadAndSelectPlayers();

          // Auto-load library when connected
          loadLibrary();
        } else if (state == MAConnectionState.disconnected) {
          // Stop built-in player service
          _builtinPlayer?.stop();
          _builtinPlayer = null;
          _availablePlayers = [];
          _selectedPlayer = null;
        }
      });

      await _api!.connect();
      notifyListeners();
    } catch (e) {
      _error = 'Connection failed: $e';
      _connectionState = MAConnectionState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _builtinPlayer?.stop();
    _builtinPlayer = null;
    _playerStateTimer?.cancel();
    _playerStateTimer = null;
    await _api?.disconnect();
    _connectionState = MAConnectionState.disconnected;
    _artists = [];
    _albums = [];
    _tracks = [];
    _currentTrack = null;
    notifyListeners();
  }

  /// Get the built-in player ID (the ID of this mobile app as a player)
  String? get builtinPlayerId => _api?.builtinPlayerId;

  Future<void> loadLibrary() async {
    if (!isConnected) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load artists, albums, and tracks in parallel
      final results = await Future.wait([
        _api!.getArtists(limit: 100),
        _api!.getAlbums(limit: 100),
        _api!.getTracks(limit: 100),
      ]);

      _artists = results[0] as List<Artist>;
      _albums = results[1] as List<Album>;
      _tracks = results[2] as List<Track>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load library: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArtists({int? limit, int? offset, String? search}) async {
    if (!isConnected) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _artists = await _api!.getArtists(
        limit: limit,
        offset: offset,
        search: search,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load artists: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlbums({
    int? limit,
    int? offset,
    String? search,
    String? artistId,
  }) async {
    if (!isConnected) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _albums = await _api!.getAlbums(
        limit: limit,
        offset: offset,
        search: search,
        artistId: artistId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load albums: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Track>> getAlbumTracks(String provider, String itemId) async {
    if (!isConnected) return [];

    try {
      return await _api!.getAlbumTracks(provider, itemId);
    } catch (e) {
      print('Failed to load album tracks: $e');
      return [];
    }
  }

  Future<Map<String, List<MediaItem>>> search(String query) async {
    if (!isConnected) {
      return {'artists': [], 'albums': [], 'tracks': []};
    }

    try {
      return await _api!.search(query);
    } catch (e) {
      print('Search failed: $e');
      return {'artists': [], 'albums': [], 'tracks': []};
    }
  }

  String getStreamUrl(String provider, String itemId, {String? uri, List<ProviderMapping>? providerMappings}) {
    return _api?.getStreamUrl(provider, itemId, uri: uri, providerMappings: providerMappings) ?? '';
  }

  String? getImageUrl(MediaItem item, {int size = 256}) {
    return _api?.getImageUrl(item, size: size);
  }

  // ============================================================================
  // PLAYER AND QUEUE MANAGEMENT
  // ============================================================================

  Future<List<Player>> getPlayers() async {
    return await _api?.getPlayers() ?? [];
  }

  Future<PlayerQueue?> getQueue(String playerId) async {
    return await _api?.getQueue(playerId);
  }

  Future<void> playTrack(String playerId, Track track) async {
    await _api?.playTrack(playerId, track);
  }

  Future<void> playTracks(String playerId, List<Track> tracks, {int? startIndex}) async {
    await _api?.playTracks(playerId, tracks, startIndex: startIndex);
  }

  Future<String?> getCurrentStreamUrl(String playerId) async {
    return await _api?.getCurrentStreamUrl(playerId);
  }

  Future<void> pausePlayer(String playerId) async {
    await _api?.pausePlayer(playerId);
  }

  Future<void> resumePlayer(String playerId) async {
    await _api?.resumePlayer(playerId);
  }

  Future<void> nextTrack(String playerId) async {
    await _api?.nextTrack(playerId);
  }

  Future<void> previousTrack(String playerId) async {
    await _api?.previousTrack(playerId);
  }

  Future<void> stopPlayer(String playerId) async {
    await _api?.stopPlayer(playerId);
  }

  // ============================================================================
  // END PLAYER AND QUEUE MANAGEMENT
  // ============================================================================

  // ============================================================================
  // PLAYER SELECTION
  // ============================================================================

  /// Load available players and auto-select one
  Future<void> _loadAndSelectPlayers() async {
    try {
      _availablePlayers = await getPlayers();
      _logger.log('Loaded ${_availablePlayers.length} players');

      // Log each player for debugging
      for (final player in _availablePlayers) {
        _logger.log('  - ${player.name} (${player.playerId}) - available: ${player.available}, state: ${player.state}');
      }

      if (_availablePlayers.isNotEmpty) {
        // Auto-select the built-in player if available
        final builtinPlayer = _availablePlayers.firstWhere(
          (p) => p.playerId == builtinPlayerId,
          orElse: () => _availablePlayers.first,
        );
        selectPlayer(builtinPlayer);
      } else {
        _logger.log('⚠️ No players available');
      }

      notifyListeners();
    } catch (e) {
      _logger.log('Error loading players: $e');
    }
  }

  /// Select a player for playback
  void selectPlayer(Player player) {
    _selectedPlayer = player;
    _logger.log('Selected player: ${player.name} (${player.playerId})');

    // Start polling for player state
    _startPlayerStatePolling();

    notifyListeners();
  }

  /// Start polling for selected player's current state
  void _startPlayerStatePolling() {
    _playerStateTimer?.cancel();

    if (_selectedPlayer == null) return;

    // Poll every 2 seconds
    _playerStateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updatePlayerState();
    });

    // Also update immediately
    _updatePlayerState();
  }

  /// Update the selected player's current state
  Future<void> _updatePlayerState() async {
    if (_selectedPlayer == null || _api == null) return;

    try {
      // Get the player's queue
      final queue = await getQueue(_selectedPlayer!.playerId);

      if (queue != null && queue.currentItem != null) {
        _currentTrack = queue.currentItem!.track;
        notifyListeners();
      } else if (_currentTrack != null) {
        // Clear current track if queue is empty
        _currentTrack = null;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - don't spam logs
    }
  }

  /// Control the selected player
  Future<void> playPauseSelectedPlayer() async {
    if (_selectedPlayer == null) return;

    if (_selectedPlayer!.isPlaying) {
      await pausePlayer(_selectedPlayer!.playerId);
    } else {
      await resumePlayer(_selectedPlayer!.playerId);
    }

    // Refresh player state immediately
    await refreshPlayers();
  }

  Future<void> nextTrackSelectedPlayer() async {
    if (_selectedPlayer == null) return;
    await nextTrack(_selectedPlayer!.playerId);
    await Future.delayed(const Duration(milliseconds: 500));
    await _updatePlayerState();
  }

  Future<void> previousTrackSelectedPlayer() async {
    if (_selectedPlayer == null) return;
    await previousTrack(_selectedPlayer!.playerId);
    await Future.delayed(const Duration(milliseconds: 500));
    await _updatePlayerState();
  }

  /// Refresh the list of available players
  Future<void> refreshPlayers() async {
    await _loadAndSelectPlayers();
  }

  // ============================================================================
  // END PLAYER SELECTION
  // ============================================================================

  @override
  void dispose() {
    _playerStateTimer?.cancel();
    _builtinPlayer?.dispose();
    _audioPlayer.dispose();
    _api?.dispose();
    super.dispose();
  }
}
