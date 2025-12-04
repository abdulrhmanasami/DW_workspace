/// In-Memory Ride Repository Tests - Track B Ticket #242
/// Purpose: Unit tests for InMemoryRideRepository implementation
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04

import 'package:test/test.dart';
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  group('InMemoryRideRepository', () {
    late InMemoryRideRepository repository;
  late MobilityPlace pickup;
  late MobilityPlace dest;

  setUp(() {
    repository = InMemoryRideRepository();
    pickup = MobilityPlace.saved(
      id: 'pickup_1',
      label: 'Home',
      address: '123 Home St',
    );
    dest = MobilityPlace.saved(
      id: 'dest_1',
      label: 'Work',
      address: '456 Office Ave',
    );
  });

    tearDown(() {
      repository.clear();
    });

    group('createDraft', () {
      test('creates draft with initial pickup', () {
        final request = repository.createDraft(initialPickup: pickup);

        expect(request.id, isNotNull);
        expect(request.status, RideStatus.draft);
        expect(request.pickup, pickup);
        expect(request.destination, isNull);
        expect(request.createdAt, isNotNull);
        expect(request.updatedAt, isNull);
      });

      test('creates draft without initial pickup', () {
        final request = repository.createDraft();

        expect(request.id, isNotNull);
        expect(request.status, RideStatus.draft);
        expect(request.pickup, isNull);
        expect(request.destination, isNull);
        expect(request.createdAt, isNotNull);
        expect(request.updatedAt, isNull);
      });

      test('stores request in internal storage', () async {
        final request = repository.createDraft();
        final stored = await repository.getRideStatus(request.id!);

        expect(stored, request);
      });
    });

    group('updateLocations', () {
      test('updates pickup and destination', () {
        final draft = repository.createDraft();
        final testDest = MobilityPlace.saved(
          id: 'dest_1',
          label: 'Work',
          address: '456 Office Ave',
        );
        final updated = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: testDest,
        );

        expect(updated.pickup, pickup);
        expect(updated.destination, testDest);
        expect(updated.updatedAt, isNotNull);
      });

      test('populates pricing when both locations are set', () {
        final draft = repository.createDraft();
        final updated = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );

        expect(updated.estimatedPrice, 1800); // 18.00 SAR
        expect(updated.estimatedDurationSeconds, 600); // 10 minutes
        expect(updated.currencyCode, 'SAR');
      });

      test('does not populate pricing when locations are incomplete', () {
        final draft = repository.createDraft();
        final updated = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: null, // Missing destination
        );

        expect(updated.estimatedPrice, isNull);
        expect(updated.estimatedDurationSeconds, isNull);
        expect(updated.currencyCode, isNull);
      });

      test('preserves existing pricing when updating', () {
        final draft = repository.createDraft();
        final withPricing = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );

        // Update only pickup (should preserve pricing)
        final updated = repository.updateLocations(
          request: withPricing,
          pickup: MobilityPlace.saved(id: 'new_pickup', label: 'New Home'),
        );

        expect(updated.estimatedPrice, 1800);
        expect(updated.estimatedDurationSeconds, 600);
        expect(updated.currencyCode, 'SAR');
      });
    });

    group('requestQuote', () {
      test('succeeds for valid draft with complete locations', () async {
        final draft = repository.createDraft();
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );

        final quoted = await repository.requestQuote(withLocations);

        expect(quoted.status, RideStatus.quoteReady);
        expect(quoted.estimatedPrice, 1800);
        expect(quoted.estimatedDurationSeconds, 600);
        expect(quoted.currencyCode, 'SAR');
      });

      test('fails for non-draft status', () async {
        final draft = repository.createDraft();
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );

        // Manually set to invalid status (bypassing FSM for test)
        final invalidRequest = withLocations.copyWith(status: RideStatus.quoteReady);

        expect(
          () => repository.requestQuote(invalidRequest),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('fails for draft without complete locations', () async {
        final draft = repository.createDraft();
        final incomplete = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: null, // Missing destination
        );

        expect(
          () => repository.requestQuote(incomplete),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('goes through quoting state before quoteReady', () async {
        final draft = repository.createDraft();
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );

        // We can't easily test intermediate states with current API,
        // but we can verify the final state and that it took some time
        final startTime = DateTime.now();
        final quoted = await repository.requestQuote(withLocations);
        final endTime = DateTime.now();

        expect(quoted.status, RideStatus.quoteReady);
        expect(endTime.difference(startTime).inMilliseconds, greaterThanOrEqualTo(300));
      });
    });

    group('confirmRide', () {
      test('succeeds for quoteReady request', () async {
        final draft = repository.createDraft();
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );
        final quoted = await repository.requestQuote(withLocations);

        final confirmed = await repository.confirmRide(quoted);

        expect(confirmed.status, RideStatus.findingDriver);
      });

      test('fails for non-quoteReady status', () async {
        final draft = repository.createDraft();

        expect(
          () => repository.confirmRide(draft),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('cancelRide', () {
      test('cancels draft request', () {
        final draft = repository.createDraft();

        final cancelled = repository.cancelRide(draft);

        expect(cancelled.status, RideStatus.cancelled);
      });

      test('cancels quoting request', () async {
        final draft = repository.createDraft();
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );

        // Put in quoting state
        final quoting = withLocations.copyWith(status: RideStatus.quoting);
        repository.applyStatusUpdate(current: withLocations, newStatus: RideStatus.quoting);

        final cancelled = repository.cancelRide(quoting);

        expect(cancelled.status, RideStatus.cancelled);
      });

      test('fails to cancel from inProgress', () async {
        final draft = repository.createDraft();
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );
        final quoted = await repository.requestQuote(withLocations);
        final confirmed = await repository.confirmRide(quoted);

        // Create inProgress request manually for testing (bypass repository validation)
        final inProgress = confirmed.copyWith(status: RideStatus.inProgress);

      expect(
        () => repository.cancelRide(inProgress),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });
    });

    group('applyStatusUpdate', () {
      test('applies valid status transitions', () {
        final draft = repository.createDraft();

        final updated = repository.applyStatusUpdate(
          current: draft,
          newStatus: RideStatus.quoting,
        );

        expect(updated.status, RideStatus.quoting);
        expect(updated.updatedAt, isNotNull);
      });

      test('rejects invalid status transitions', () {
        final draft = repository.createDraft();

        expect(
          () => repository.applyStatusUpdate(
            current: draft,
            newStatus: RideStatus.driverAccepted,
          ),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });
    });

    group('getRideStatus', () {
      test('returns stored request', () async {
        final draft = repository.createDraft();

        final retrieved = await repository.getRideStatus(draft.id!);

        expect(retrieved, draft);
      });

      test('returns null for non-existent request', () async {
        final retrieved = await repository.getRideStatus('non-existent');

        expect(retrieved, isNull);
      });
    });

    group('Integration flow', () {
      test('complete booking flow works end-to-end', () async {
        // 1. Create draft
        final draft = repository.createDraft();
        expect(draft.status, RideStatus.draft);

        // 2. Set locations
        final withLocations = repository.updateLocations(
          request: draft,
          pickup: pickup,
          destination: dest,
        );
        expect(withLocations.hasValidLocations, isTrue);
        expect(withLocations.hasPricing, isTrue);

        // 3. Request quote
        final quoted = await repository.requestQuote(withLocations);
        expect(quoted.status, RideStatus.quoteReady);
        expect(quoted.hasPricing, isTrue);

        // 4. Confirm ride
        final confirmed = await repository.confirmRide(quoted);
        expect(confirmed.status, RideStatus.findingDriver);

        // 5. Cancel if needed
        final cancelled = repository.cancelRide(confirmed);
        expect(cancelled.status, RideStatus.cancelled);
      });
    });
  });
}
