import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/panchangam/panchangam.dart';
import '../../data/cities.dart';

/// City selection by GPS or search. Used in onboarding and from the Today
/// header. GPS is a one-time detection of the nearest listed city; only that
/// city is stored, never coordinates or location history.
class CityChooser extends StatefulWidget {
  const CityChooser({super.key, this.onChosen, this.autofocus = false});
  final VoidCallback? onChosen;
  final bool autofocus;

  @override
  State<CityChooser> createState() => _CityChooserState();
}

City nearestCity(double lat, double lon) {
  double d(City c) {
    final dLat = (c.lat - lat) * math.pi / 180, dLon = (c.lon - lon) * math.pi / 180;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat * math.pi / 180) * math.cos(c.lat * math.pi / 180) * math.pow(math.sin(dLon / 2), 2);
    return 2 * math.asin(math.sqrt(a));
  }

  return cities.reduce((a, b) => d(a) <= d(b) ? a : b);
}

class _CityChooserState extends State<CityChooser> {
  String _q = '';
  bool _locating = false;
  String? _gpsError;

  Future<void> _useGps() async {
    final app = AppScope.read(context);
    setState(() {
      _locating = true;
      _gpsError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw 'off';
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) throw 'denied';
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 15)));
      // One-time detection: only the nearest city's name is kept, never the
      // coordinates (approved data model).
      final near = nearestCity(pos.latitude, pos.longitude);
      await app.setProfile(city: near.id);
      widget.onChosen?.call();
    } catch (_) {
      if (mounted) setState(() => _gpsError = context.l.gpsFailed);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final q = _q.toLowerCase();
    final list = cities
        .where((c) => q.isEmpty || c.name.en.toLowerCase().contains(q) || c.name.of('te').contains(_q))
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      OutlinedButton.icon(
        key: const ValueKey('use-gps'),
        onPressed: _locating ? null : _useGps,
        icon: _locating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location),
        label: Text(context.l.useMyLocation),
      ),
      if (_gpsError != null)
        Padding(padding: const EdgeInsets.only(top: 6), child: Text(_gpsError!, style: const TextStyle(color: K.saffron))),
      const SizedBox(height: 12),
      TextField(
        key: const ValueKey('city-search'),
        autofocus: widget.autofocus,
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l.search, border: const OutlineInputBorder()),
        onChanged: (v) => setState(() => _q = v),
      ),
      const SizedBox(height: 6),
      for (final c in list)
        ListTile(
          key: ValueKey('city-${c.id}'),
          title: Text(context.t(c.name)),
          subtitle: Text(context.t2(c.name)),
          trailing: app.cityId == c.id ? const Icon(Icons.check, color: K.maroon) : null,
          onTap: () async {
            await app.setProfile(city: c.id);
            widget.onChosen?.call();
          },
        ),
    ]);
  }
}
