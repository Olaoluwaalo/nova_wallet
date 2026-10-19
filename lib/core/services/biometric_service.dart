import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> confirmHighValueSend(BuildContext context) async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        return await _showStubDialog(context);
      }
      return await _auth.authenticate(
        localizedReason: 'Confirm this transfer with biometrics',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
    } catch (_) {
      return await _showStubDialog(context);
    }
  }

  Future<bool> _showStubDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm transfer'),
        content: const Text('Biometric unavailable on this device. Confirm to proceed.'),
        actions: [
          TextButton(onPressed: () => Get.back<bool>(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back<bool>(result: true), child: const Text('Confirm')),
        ],
      ),
    );
    return result ?? false;
  }
}
