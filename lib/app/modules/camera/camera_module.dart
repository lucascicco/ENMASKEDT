import 'camera_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'camera_page.dart';

class CameraModule extends ChildModule {
  @override
  List<Bind> get binds => [Bind((i) => CameraController())];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute, child: (_, args) => CameraPage()),
      ];

  static Inject get to => Inject<CameraModule>.of();
}
