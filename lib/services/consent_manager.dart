import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class ConsentManager {
  factory ConsentManager() => _instance;
  ConsentManager._internal();
  static final ConsentManager _instance = ConsentManager._internal();

  /// Requests the latest consent information and shows the consent form if required.
  Future<void> requestConsentUpdate() async {
    final params = ConsentRequestParameters();

    // In debug mode, you can force a specific consent status for testing
    // params = ConsentRequestParameters(
    //   debugSettings: ConsentDebugSettings(
    //     debugGeography: DebugGeography.debugGeographyEea,
    //     testDeviceIds: ['YOUR_DEVICE_ID'],
    //   ),
    // );

    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadAndShowConsentForm(completer);
        } else {
          completer.complete();
        }
      },
      (FormError error) {
        debugPrint('Consent error: ${error.message}');
        completer.complete();
      },
    );

    return completer.future;
  }

  void _loadAndShowConsentForm(Completer<void> completer) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) {
        consentForm.show((FormError? error) {
          if (error != null) {
            debugPrint('Consent form show error: ${error.message}');
          }
          completer.complete();
        });
      },
      (FormError error) {
        debugPrint('Consent form load error: ${error.message}');
        completer.complete();
      },
    );
  }

  /// Helper to check if ads can be initialized.
  Future<bool> canRequestAds() async {
    final status = await ConsentInformation.instance.getConsentStatus();
    return status == ConsentStatus.obtained ||
        status == ConsentStatus.notRequired;
  }
}
