import 'package:flutter_riverpod/flutter_riverpod.dart';

// Using static content since remoteConfigProvider is not available in foundation_shims
// This follows the principle of not adding domain logic to UI layer
final privacyMarkdownProvider = Provider<String>((ref) {
  return '''# Privacy Policy

This application respects your privacy and is committed to protecting your personal data.

## Data Collection
We collect minimal data necessary for app functionality.

## Data Usage
Your data is used solely for providing app services.

## Contact
For privacy concerns, please contact support.
''';
});

final termsMarkdownProvider = Provider<String>((ref) {
  return '''# Terms of Service

Welcome to our application. By using this app, you agree to these terms.

## Usage
This app is provided as-is for personal use.

## Liability
We are not liable for any damages arising from app usage.

## Changes
Terms may be updated at any time.
''';
});
