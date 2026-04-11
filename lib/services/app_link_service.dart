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
    if (uri.host == _host || (kDebugMode && uri.host.isEmpty)) {
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'trap') {
        try {
          final idString = uri.pathSegments.elementAtOrNull(1);
          if (idString != null) {
            final id = int.parse(idString);
            // Navigate via GoRouter
            router.push('/trap/$id');
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
