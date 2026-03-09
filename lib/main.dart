import 'package:flutter/material.dart';

import 'app.dart';
import 'repositories/items_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ItemsRepository.instance.initialize();
  runApp(const NidoApp());
}
