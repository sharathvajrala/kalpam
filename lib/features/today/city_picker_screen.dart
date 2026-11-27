import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/cities.dart';

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});
  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final q = _q.toLowerCase();
    final list = cities.where((c) => q.isEmpty || c.name.en.toLowerCase().contains(q) || c.name.of('te').contains(_q)).toList();
    return Scaffold(
      appBar: AppBar(title: Bi((l) => l.chooseCity, style: Theme.of(context).textTheme.titleLarge)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l.search, border: const OutlineInputBorder()),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: ListView(children: [
            for (final c in list)
              ListTile(
                title: Text(context.t(c.name)),
                subtitle: Text(context.t2(c.name)),
                trailing: app.cityId == c.id ? const Icon(Icons.check, color: K.maroon) : null,
                onTap: () async {
                  await app.setProfile(city: c.id);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
          ]),
        ),
      ]),
    );
  }
}
