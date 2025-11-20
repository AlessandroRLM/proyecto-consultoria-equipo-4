import 'package:mobile/ports/credentials/driven/for_persisting_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialRequestPersistanceMockService implements ForPersistingRequest {
  static const String _key = 'credential_request_persisted';

  @override
  Future<bool> hasRequestBeenPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> persistRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
