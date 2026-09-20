import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

abstract class BiometricAuthService {
  /// Checks if biometric authentication is supported and enabled on the hardware.
  Future<bool> isBiometricAvailable();

  /// Prompts the user for biometric authentication.
  Future<bool> authenticate({required String localizedReason});

  /// Retrieves the list of enrolled biometrics (e.g. fingerprint, face).
  Future<List<BiometricType>> getAvailableBiometrics();
}

@LazySingleton(as: BiometricAuthService)
class BiometricAuthServiceImpl implements BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthServiceImpl(this._auth);

  @override
  Future<bool> isBiometricAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    return canCheck && isSupported;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }
}
