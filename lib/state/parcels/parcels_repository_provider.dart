/// Parcels Repository Provider.
/// Created by: Track C - Ticket #49
/// Purpose: Riverpod provider for injecting ParcelsRepository into state.
/// Last updated: 2025-11-28

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'app_parcels_repository.dart';

/// Track C - ParcelsRepository provider.
///
/// Currently injects AppParcelsRepository (in-memory stub).
/// Can be overridden in tests or swapped for a backend implementation.
final parcelsRepositoryProvider = Provider<ParcelsRepository>((ref) {
  return AppParcelsRepository();
});

