import 'dart:math' as math;

import 'package:design_system_components/design_system_components.dart';
import 'package:flutter/material.dart';
import 'package:mobility_shims/mobility_shims.dart';

class RideDestinationSearchResult {
  const RideDestinationSearchResult(this.place);
  final MobilityPlace place;
}

class RideDestinationSearchScreen extends StatefulWidget {
  const RideDestinationSearchScreen({super.key});

  @override
  State<RideDestinationSearchScreen> createState() =>
      _RideDestinationSearchScreenState();
}

class _RideDestinationSearchScreenState
    extends State<RideDestinationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<MobilityPlace> _mockResults() {
    final seed = _query.isEmpty ? 'default' : _query;
    final hash = seed.codeUnits.fold<int>(0, (p, c) => p + c);
    final rnd = math.Random(hash);
    const baseLat = 24.7136; // Riyadh
    const baseLng = 46.6753;
    List<MobilityPlace> results = [
      MobilityPlace(
        id: 'home',
        label: 'Home',
        address: 'King Fahd Rd',
        location: LocationPoint(
          latitude: baseLat + rnd.nextDouble() * 0.02,
          longitude: baseLng + rnd.nextDouble() * 0.02,
        ),
        type: MobilityPlaceType.saved,
      ),
      MobilityPlace(
        id: 'work',
        label: 'Work',
        address: 'Olaya St',
        location: LocationPoint(
          latitude: baseLat - rnd.nextDouble() * 0.02,
          longitude: baseLng - rnd.nextDouble() * 0.02,
        ),
        type: MobilityPlaceType.saved,
      ),
      MobilityPlace(
        id: 'airport',
        label: 'Airport',
        address: 'RUH Terminal',
        location: LocationPoint(
          latitude: baseLat + rnd.nextDouble() * 0.05,
          longitude: baseLng + rnd.nextDouble() * 0.05,
        ),
        type: MobilityPlaceType.searchResult,
      ),
    ];
    // Filter by query
    if (_query.isNotEmpty) {
      results = results
          .where((p) =>
              p.label.toLowerCase().contains(_query.toLowerCase()) ||
              (p.address?.toLowerCase().contains(_query.toLowerCase()) ??
                  false))
          .toList();
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _mockResults();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Where to?'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DwInput(
              controller: _controller,
              label: 'Search destination',
              hint: 'City, place, or address',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final place = results[index];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(place.label),
                    subtitle:
                        place.address != null ? Text(place.address!) : null,
                    onTap: () {
                      Navigator.of(context)
                          .pop(RideDestinationSearchResult(place));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

