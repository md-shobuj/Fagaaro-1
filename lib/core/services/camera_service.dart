import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';

abstract class CameraService {
  /// Retrieves a list of available cameras on the device.
  Future<List<CameraDescription>> getAvailableCameras();

  /// Initializes and returns a [CameraController] for the chosen camera.
  Future<CameraController> initializeController({
    required CameraDescription camera,
    ResolutionPreset preset = ResolutionPreset.medium,
    bool enableAudio = false,
  });

  /// Captures an image and returns the file path payload as an [XFile].
  Future<XFile> takePicture(CameraController controller);
}

@LazySingleton(as: CameraService)
class CameraServiceImpl implements CameraService {
  @override
  Future<List<CameraDescription>> getAvailableCameras() {
    return availableCameras();
  }

  @override
  Future<CameraController> initializeController({
    required CameraDescription camera,
    ResolutionPreset preset = ResolutionPreset.medium,
    bool enableAudio = false,
  }) async {
    final controller = CameraController(
      camera,
      preset,
      enableAudio: enableAudio,
    );
    await controller.initialize();
    return controller;
  }

  @override
  Future<XFile> takePicture(CameraController controller) async {
    if (!controller.value.isInitialized) {
      throw StateError('Camera is not initialized. Call initializeController first.');
    }
    if (controller.value.isTakingPicture) {
      throw StateError('A picture capture is already in progress.');
    }
    return await controller.takePicture();
  }
}
