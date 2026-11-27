import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import 'city_chooser.dart';

class CityPickerScreen extends StatelessWidget {
  const CityPickerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Bi((l) => l.chooseCity, style: Theme.of(context).textTheme.titleLarge)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CityChooser(onChosen: () => Navigator.pop(context)),
      ]),
    );
  }
}
