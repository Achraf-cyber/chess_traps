import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class AppLinkService {
  static final _appLinks = AppLinks();
  
  // Update this to your deployed Vercel/Website domain
  static const String _host = 'chess-traps.vercel.app';

  static Future<void> init(GoRouter router) async {
    // 1. Handle initial link (opened when app was closed)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, router);
      }
    } catch (e) {
      debugPrint('Failed to get initial app link: $e');
    }

    // 2. Listen for incoming links while app is running
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, router);
    }).onError((err) {
      debugPrint('App Link Error: $err');
    });
  }

  static void _handleUri(Uri uri, GoRouter router) {
    debugPrint('Received App Link: $uri');
    
    // Check if the link belongs to our domain
    // In release mode, uri.host must match _host exactly.
    final hostMatches = uri.host == _host || (kDebugMode && uri.host.isEmpty);
    
    if (hostMatches) {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty && segments.first == 'trap') {
        try {
          final idString = segments.length > 1 ? segments[1] : null;
          if (idString != null) {
            final id = int.tryParse(idString);
            if (id != null) {
              // Use push replacement or push depending on history needs
              router.push('/trap/$id');
            } else {
              debugPrint('Invalid trap ID format: $idString');
            }
          }
        } catch (e) {
          debugPrint('Error parsing trap ID from App Link: $e');
        }
      }
    }
  }

  static String buildTrapLink(int trapIndex) {
    // This generates a link to your website that Android will intercept
    return 'https://$_host/trap/$trapIndex';
  }
}
