import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'camera_controller.g.dart';

@Injectable()
class CameraController = _CameraControllerBase with _$CameraController;

abstract class _CameraControllerBase with Store {
  @observable
  bool loading = false;

  @action
  void changeLoading() {
    loading = !loading;
  }
}
