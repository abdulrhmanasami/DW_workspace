// Uplink Endpoints - API endpoint management
// Created by: Cursor B-mobility
// Purpose: Centralized endpoint construction for tracking uplink
// Last updated: 2025-11-14

/// API endpoints for mobility uplink
class UplinkEndpoints {
  final Uri baseUri;

  UplinkEndpoints(Uri? base)
      : baseUri = base ?? Uri.parse('https://uplink.local');

  /// Upload batch of location points for a session
  Uri uploadPointsBatch(String sessionId) {
    return baseUri.resolve('/tracking/sessions/$sessionId/points:batch');
  }

  /// Create new tracking session on server
  Uri createSession() {
    return baseUri.resolve('/tracking/sessions');
  }

  /// Get session status
  Uri getSessionStatus(String sessionId) {
    return baseUri.resolve('/tracking/sessions/$sessionId');
  }
}
