import 'package:http/http.dart' as http;
import 'debug_logger.dart';

class StreamTester {
  final _logger = DebugLogger();

  Future<bool> testStreamUrl(String url) async {
    try {
      _logger.log('Testing stream URL: $url');

      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent': 'MusicAssistantMobile/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      _logger.log('Stream test response: ${response.statusCode}');
      _logger.log('Content-Type: ${response.headers['content-type']}');
      _logger.log('Content-Length: ${response.headers['content-length']}');
      _logger.log('Headers: ${response.headers}');

      if (response.statusCode == 200) {
        _logger.log('✓ Stream URL is accessible');
        return true;
      } else {
        _logger.log('✗ Stream URL returned status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.log('✗ Stream test failed: $e');
      return false;
    }
  }

  Future<void> testStreamContent(String url) async {
    try {
      _logger.log('Fetching first 1KB of stream content...');

      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = 'MusicAssistantMobile/1.0';
      request.headers['Range'] = 'bytes=0-1023';

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
      );

      _logger.log('Stream content response: ${streamedResponse.statusCode}');
      _logger.log('Content-Type: ${streamedResponse.headers['content-type']}');

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 206) {
        final bytes = await streamedResponse.stream.toBytes();
        _logger.log('✓ Received ${bytes.length} bytes');

        // Check if it looks like MP3 data
        if (bytes.length >= 3) {
          final header = '${bytes[0].toRadixString(16).padLeft(2, '0')}'
              '${bytes[1].toRadixString(16).padLeft(2, '0')}'
              '${bytes[2].toRadixString(16).padLeft(2, '0')}';
          _logger.log('Stream header: 0x$header');

          if (header.startsWith('fff') || header == '494433') {
            _logger.log('✓ Stream appears to be valid MP3 audio');
          } else {
            _logger.log('✗ Stream does not appear to be MP3 (header: 0x$header)');
          }
        }
      } else {
        _logger.log('✗ Stream content test failed with status ${streamedResponse.statusCode}');
      }
    } catch (e) {
      _logger.log('✗ Stream content test failed: $e');
    }
  }
}
